# Agent Constraints

<red_lines>
**No File Reading via Shell**

Never use shell commands with `cat`, `head`, `tail`, or similar to read file contents. Use the read tool if you have it; otherwise delegate to the explore agent.

**Web Access Intent**

Web fetching is restricted to the explore agent; every other agent must not fetch web content. MCP documentation tools are held to the same intent: **no arbitrary browsing.** Fetch library, API, and CLI documentation — not general web content.

**Code Execution**

`python` and `python3` are blocked at the permission level — Python can silently exfiltrate secrets through network calls, environment reads, or file access, even for tasks as innocent as JSON validation.

- **JSON**: use `jq` (`jq . file.json`, `jq '.key' file.json`).
- **Anything else**: if Python is genuinely unavoidable, run it inline in a throwaway network-less sandbox. The exact invocation is in the Runtime Safety rules of the global instructions — never write a `.py` file first, and never mount a directory that could contain secrets.
- NEVER install global dependencies in any language — no `pip install`, `npm i -g`, `pnpm add -g`, `cargo install`, `go install`, `gem install`, `brew install`, `apt install`. If a tool is genuinely necessary, install it inside a docker container (network allowed for that step only) and run it inside the network-isolated container.

**Privacy & Secret Handling**

ALWAYS load the `privacy-guard` skill before:

- Reading any user-provided file
- Outputting or sharing file contents that may contain secrets, credentials, or PII
- Processing `.env`, config, credential, or key files of any kind

This applies even when the task appears unrelated to secrets — user-provided files may contain sensitive data that is not immediately obvious. Skipping this step is a critical protocol violation.

</red_lines>

<standards>
**Capability Model**

Two invariants govern every agent:

1. **Discovery and web retrieval belong to the retrieval agent alone.** Search, pattern matching, and web fetching are denied to most agents at the permission level — the debugging agent may search directly (its permission block allows it) but prefers delegating discovery to the retrieval agent; every other agent delegates all searching and documentation fetching to the retrieval agent.
2. **Reading is available to agents that edit or plan.** Reading is not a privilege reserved for one agent — it is granted wherever a file's exact contents are load-bearing.

| Agent | read | edit scope | Delegates to |
| --- | --- | --- | --- |
| Retrieval agent | ✅ | none — read-only | nothing (cannot delegate) |
| Implementation agent | ✅ | anything except `.env*`, `*.key`, `*.pem`, `secrets.*` | 7 subagents |
| Planning agent | ✅ — under the Read Budget below | docs only | retrieval, architect, refactoring agents |
| Documentation agent | ✅ | `*.md`, `*.txt` only | retrieval agent |
| Build-error agent | ✅ | anything (prompted) | retrieval agent |
| Debugging agent | ✅ | prompted edits only (user-invoked) | retrieval agent |
| Evolution agent (disabled — kept for future re-arm) | ✅ | none — proposes changes only | nothing |
| Architect, code review, verifier, refactoring, security review agents | ❌ | none | retrieval agent where permitted |

**Reading Before Editing**

Edits enforce a **per-session freshness check** — the *primary* agent must have read a file after its last modification, or the edit is rejected. Subagent reads do NOT satisfy this check. Every write-enabled agent must read the file itself immediately before editing.

**Read Budget**

Reading is for files whose contents are load-bearing — ones you will quote, edit, or verify. If you are reading to *find* something, delegate instead; the test is whether you could name the file before opening it. Pattern: delegate for discovery → read the specific file → edit.

**Agents Without Read Access**

The architect, code-review, verifier, refactoring, and security review agents work from **parent-provided context**. The dispatching agent must include complete file contents in the dispatch. If context is missing, report the gap to the parent — do not guess, and do not attempt a denied tool.

**The Retrieval Agent Is Exempt**

These delegation rules bind *callers* of the retrieval agent. The retrieval agent itself is exempt and must use its own tools directly — it cannot delegate to itself.

</standards>
