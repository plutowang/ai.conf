---
applyTo: '**'
---

# Performance & Context Efficiency

## Context Window Management

- The context window is a finite, non-renewable resource within a session.
- Every tool output, file read, and agent response consumes context budget.
- Proactively distill completed exploration into summaries — don't let raw outputs accumulate.
- Prune superseded or irrelevant tool outputs promptly.
- When approaching context limits, compact early rather than late.

## Tool Call Efficiency

- **Batch independent calls**: When multiple tool calls don't depend on each other, run them in parallel in a single response. Never serialize what can parallelize.
- **Delegate discovery**: Use the `explore` agent for file discovery and pattern searches. Do not inline multi-step searches in the main conversation.
- **Read directly for known paths**: When you already know the exact file path, use `read` directly rather than delegating to `explore`.
- **Never re-read files you just wrote**: You already have the content. Exception: re-read after critical edits that change signatures, APIs, or imports.
- **Prefer `edit` over `write`**: Targeted edits consume less context than full file rewrites.

## Avoiding Wasted Iterations

- Read before writing — explore the existing code before writing to avoid conflicts.
- Plan before executing — a 5-minute plan saves 30 minutes of rework.
- Verify after implementing — catch issues immediately, not 3 steps later.
- Ask clarifying questions upfront rather than guessing and redoing.
- Fix errors in dependency order: imports → types → logic → tests. Don't fix symptoms before root causes.

## Loop Prevention

- Never execute the exact same tool call with the same arguments more than once. If it failed, it will fail again.
- After 2 consecutive failed attempts at the same problem, delegate to the appropriate agent or output **BLOCKED**.
- If your reasoning repeats the same sequence 3+ times without a tool call, you are in a thinking loop — stop and act.
- Read-only commands (`git status`, `git diff`, `ls`) are always safe. Execute them without deliberation.
