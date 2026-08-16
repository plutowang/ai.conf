// Injects synthetic mode reminders for the custom `design` <-> `build`/`debug`
// agents, mirroring OpenCode's built-in SessionReminders (PROMPT_PLAN / BUILD_SWITCH).
//
// Hook: experimental.chat.messages.transform — fired once per model-loop step
// on a fresh in-memory copy of the session history, so injected parts are
// transient (never persisted) and cannot accumulate across steps.

const DESIGN_REMINDER = [
  "<system-reminder>",
  "CRITICAL OPERATIONAL MODE: DESIGN",
  "- You are currently running in DESIGN mode.",
  "- You are permitted to read the codebase and write/edit specification files strictly inside `docs/`.",
  "- DO NOT edit or modify source code files outside `docs/`.",
  "- Prefer the `explore` subagent to scan files. Read directly only when necessary.",
  "</system-reminder>",
].join("\n")

const BUILD_REMINDER = [
  "<system-reminder>",
  "CRITICAL OPERATIONAL MODE: BUILD",
  "- Your operational mode has changed to BUILD.",
  "- Any previous `design` mode constraints or read-only limitations in the conversation history are NOW INACTIVE.",
  "- You are permitted to modify files across the entire codebase as requested.",
  "</system-reminder>",
].join("\n")

const DEBUG_REMINDER = [
  "<system-reminder>",
  "CRITICAL OPERATIONAL MODE: DEBUG",
  "- Your operational mode has changed to DEBUG.",
  "- Any previous `design` mode constraints or read-only limitations in the conversation history are NOW INACTIVE.",
  "- You are permitted to modify files across the entire codebase as requested.",
  "- Debugging constraints apply: gate every code change on user approval and remove all instrumented trace logs before declaring done.",
  "</system-reminder>",
].join("\n")

// Replicates @opencode-ai/schema identifier.ts `ascending()`: sortable
// "prt_" + 12 hex chars (timestamp*0x1000 + counter) + 14 random chars.
let counter = 0
function partID() {
  counter++
  const current = BigInt(Date.now()) * 0x1000n + BigInt(counter)
  const time = Array.from({ length: 6 }, (_, index) =>
    Number((current >> BigInt(40 - 8 * index)) & 0xffn)
      .toString(16)
      .padStart(2, "0"),
  ).join("")
  const chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  const bytes = crypto.getRandomValues(new Uint8Array(14))
  return "prt_" + time + Array.from(bytes, (byte) => chars[byte % 62]).join("")
}

function reminderPart(info, text) {
  return {
    id: partID(),
    messageID: info.id,
    sessionID: info.sessionID,
    type: "text",
    text,
    synthetic: true,
  }
}

export default async function DesignRemindersPlugin() {
  return {
    "experimental.chat.messages.transform": async (input, output) => {
      const messages = output?.messages
      if (!Array.isArray(messages) || messages.length === 0) return

      const lastUser = messages.findLast((msg) => msg?.info?.role === "user")
      if (!lastUser?.info || !lastUser.parts) return

      const agent = lastUser.info.agent
      if (agent === "design") {
        lastUser.parts.push(reminderPart(lastUser.info, DESIGN_REMINDER))
        return
      }

      if (agent !== "build" && agent !== "debug") return

      const wasDesign = messages.some(
        (msg) =>
          msg?.info?.role === "assistant" && msg?.info?.agent === "design",
      )
      if (!wasDesign) return

      const reminder = agent === "debug" ? DEBUG_REMINDER : BUILD_REMINDER
      lastUser.parts.push(reminderPart(lastUser.info, reminder))
    },
  }
}
