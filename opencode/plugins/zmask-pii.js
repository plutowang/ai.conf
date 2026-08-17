// Masks PII in every outgoing LLM message list using the vendored zmask rule
// engine (rule mode only — never passes --ai/--consent/--config).
//
// Batching: all unique strings per hook call are joined with "\n" and masked
// in ONE zmask spawn. zmask is line-faithful (1 input line -> 1 output line,
// EOL preserved), so the output splits back by each string's original line
// count — byte-exact, no delimiter collisions, with a per-text line-count
// verification on every batch. Cross-step repeats hit the cache (history is
// re-sent every step), keeping per-step cost at ~3 ms.
//
// Failure model: fail-open. Missing/broken binary, non-zero exit, empty
// stdout, timeout, or any line-mismatch → original text is sent unmasked.
// A spawn-level failure disables masking for the rest of the process
// (one user toast + one server-log entry) — no repeated per-string spawns.
//
// Hooks:
// - experimental.chat.messages.transform — per model-loop step on the same
//   array opencode serializes next; mutations are transient (DB-hydrated
//   copies, never written back). Masks text parts, tool state strings
//   (output, title, input), and system strings.
// - experimental.chat.system.transform — per request after system assembly;
//   masks instruction strings in place.
import { spawnSync } from "node:child_process"

const CACHE_MAX = 500
const MAX_STDOUT = 64 * 1024 * 1024
const SPAWN_TIMEOUT_MS = 10000
const cache = new Map() // original text -> masked text
let warned = false
let disabled = false
let sdkClient = null

// NOTE: opencode's plugin sandbox rejects node:fs/node:url imports, so the
// path is derived with plain URL parsing only. Bun resolves module symlinks
// to their real path by default, so `../bin` resolves to
// ~/.config/opencode/bin — the sibling of ~/.config/opencode/plugins, where
// this plugin file itself loads from. The vendored binary is stored per
// platform+arch (zmask-darwin-arm64, zmask-linux-x64, ...); unsupported
// platforms fail open via the normal failure model.
function bundledBinary() {
  const name = `zmask-${process.platform}-${process.arch}`
  return decodeURIComponent(new URL(`../bin/${name}`, import.meta.url).pathname)
}

function resolveBinary(options) {
  if (options?.path) {
    const home = process.env.HOME
    if (!home) return bundledBinary()
    return options.path.replace(/^~/, home)
  }
  return bundledBinary()
}

function warnOnce(err) {
  if (!warned) {
    const message = `masking skipped: ${err?.message ?? err}`
    // console.warn is intentionally NOT used: plugin stdout/stderr writes
    // corrupt the TUI render (opencode issue #8639). Toast = user-visible;
    // app.log = structured server log.
    sdkClient?.app
      ?.log?.({
        body: { service: "zmask-pii", level: "warn", message },
      })
      ?.catch(() => {})
    sdkClient?.tui
      ?.showToast?.({
        body: { title: "zmask-pii", message, variant: "warning" },
      })
      ?.catch(() => {})
    warned = true
  }
}

function lineCount(text) {
  let count = 1
  for (let i = 0; i < text.length; i++) if (text.charCodeAt(i) === 10) count++
  return count
}

function spawnZmask(binary, input) {
  const result = spawnSync(binary, [], {
    input,
    encoding: "utf8",
    maxBuffer: MAX_STDOUT,
    timeout: SPAWN_TIMEOUT_MS,
  })
  if (result.error) throw result.error
  if (result.status !== 0)
    throw new Error(`zmask exited with status ${result.status}`)
  if (typeof result.stdout !== "string" || result.stdout.length === 0) {
    throw new Error("zmask produced empty stdout")
  }
  return result.stdout
}

// Masks a batch in ONE zmask invocation. zmask preserves line structure, so
// the output splits back by each string's original line count. Both the
// total and per-text line counts are verified; any mismatch throws so the
// caller falls back to per-string masking.
function maskBatch(binary, texts) {
  const counts = texts.map(lineCount)
  const stdout = spawnZmask(binary, texts.join("\n"))
  const segments = stdout.split("\n")
  const total = counts.reduce((a, b) => a + b, 0)
  if (segments.length !== total)
    throw new Error(
      `zmask line mismatch: got ${segments.length}, want ${total}`,
    )
  const out = []
  let idx = 0
  for (const count of counts) {
    out.push(segments.slice(idx, idx + count).join("\n"))
    idx += count
  }
  for (let j = 0; j < texts.length; j++) {
    if (lineCount(out[j]) !== counts[j])
      throw new Error(`zmask per-text line mismatch for string ${j}`)
  }
  return out
}

// Per-string spawn; returns the original text on any failure. Spawn-level
// failures disable masking for the rest of the process (fail-open, no
// repeated spawning).
function maskTextFallback(binary, text) {
  try {
    return spawnZmask(binary, text)
  } catch (err) {
    disabled = true
    warnOnce(err)
    return text
  }
}

// Cache-aware masking: unique strings go in one batch spawn; any batch
// failure falls back to per-string masking (fail-open per string).
function maskMany(binary, texts) {
  if (disabled) return texts
  const result = new Array(texts.length)
  const pending = []
  const pendingIdx = []
  for (let i = 0; i < texts.length; i++) {
    if (texts[i].length === 0) {
      result[i] = texts[i]
      continue
    }
    const cached = cache.get(texts[i])
    if (cached !== undefined) {
      result[i] = cached
      continue
    }
    pending.push(texts[i])
    pendingIdx.push(i)
  }
  if (pending.length === 0) return result

  try {
    const masked = maskBatch(binary, pending)
    for (let j = 0; j < pending.length; j++) {
      if (cache.size >= CACHE_MAX) cache.delete(cache.keys().next().value)
      cache.set(pending[j], masked[j])
      result[pendingIdx[j]] = masked[j]
    }
  } catch (err) {
    for (let j = 0; j < pending.length; j++) {
      result[pendingIdx[j]] = maskTextFallback(binary, pending[j])
      if (disabled) {
        for (let k = j + 1; k < pending.length; k++)
          result[pendingIdx[k]] = pending[k]
        break
      }
    }
  }
  return result
}

// Collects {parent, key} references to every non-empty string inside an
// arbitrary nested structure (arrays + objects, in-place safe).
function collectRefs(value, refs, parent, key) {
  if (typeof value === "string") {
    if (value.length > 0) refs.push({ parent, key })
  } else if (Array.isArray(value)) {
    for (let i = 0; i < value.length; i++) collectRefs(value[i], refs, value, i)
  } else if (value && typeof value === "object") {
    for (const k of Object.keys(value)) collectRefs(value[k], refs, value, k)
  }
}

export default async function ZmaskPiiPlugin(input, options = {}) {
  sdkClient = input?.client
  const binary = resolveBinary(options)
  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      const messages = output?.messages
      if (!Array.isArray(messages) || messages.length === 0) return

      // Collect references to every non-empty string in traversal order.
      const refs = []
      for (const msg of messages) {
        const parts = msg?.parts
        if (!Array.isArray(parts)) continue
        for (const part of parts) {
          if (
            part?.type === "text" &&
            typeof part.text === "string" &&
            part.text.length > 0
          ) {
            refs.push({ parent: part, key: "text" })
          } else if (part?.type === "tool" && part.state) {
            if (
              typeof part.state.output === "string" &&
              part.state.output.length > 0
            ) {
              refs.push({ parent: part.state, key: "output" })
            } else if (part.state.output !== undefined) {
              collectRefs(part.state.output, refs, part.state, "output")
            }
            if (
              typeof part.state.title === "string" &&
              part.state.title.length > 0
            ) {
              refs.push({ parent: part.state, key: "title" })
            }
            if (part.state.input !== undefined) {
              collectRefs(part.state.input, refs, part.state, "input")
            }
          }
        }
      }
      if (refs.length === 0) return

      const values = refs.map((r) => r.parent[r.key])
      const masked = maskMany(binary, values)
      refs.forEach((r, i) => {
        r.parent[r.key] = masked[i]
      })
    },
    "experimental.chat.system.transform": async (_input, output) => {
      const system = output?.system
      if (!Array.isArray(system)) return
      const refs = []
      system.forEach((s, i) => {
        if (typeof s === "string" && s.length > 0)
          refs.push({ parent: system, key: i })
      })
      if (refs.length === 0) return
      const values = refs.map((r) => r.parent[r.key])
      const masked = maskMany(binary, values)
      refs.forEach((r, i) => {
        r.parent[r.key] = masked[i]
      })
    },
  }
}

// Test-only: resets module-level state between test runs. Attached to the
// default export (not a named export) — opencode's plugin loader treats
// every module export as a plugin definition.
ZmaskPiiPlugin._resetForTests = function () {
  cache.clear()
  warned = false
  disabled = false
}
