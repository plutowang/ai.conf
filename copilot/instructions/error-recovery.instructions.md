---
applyTo: '**'
---

# Error Recovery

## BLOCKED Protocol

CRITICAL: If a tool execution fails or returns an error, you must analyze the error carefully before retrying.

- **DO NOT** attempt to execute the exact same tool with the exact same arguments more than **ONCE**. If it failed, it
  will fail again.
- Before any retry, you MUST articulate: (1) what the error was, (2) what you are changing in your approach. If you
  cannot articulate a meaningful change, **stop**.
- After **2 consecutive failed attempts** to solve the same problem (even with different approaches), you MUST
  immediately output the word **"BLOCKED"** and ask the user for guidance. **DO NOT enter a retry loop. DO NOT continue.
  **
- Every failed retry wastes irreplaceable context tokens. Treat each attempt as expensive.

## Tool Failures

- If a tool call returns an error or empty result, try **ONE** alternative approach before escalating.
- If grep finds nothing, try a broader pattern or different search term.
- Never retry the exact same failed tool call — change the approach or output **BLOCKED**.

## Build/Test Failures

- Parse the full error output before attempting fixes.
- Fix errors in dependency order: imports → types → logic → tests.
- After each fix batch, re-run to verify — never assume the fix worked.
- If the same error persists after 2 fix attempts, delegate to `build-error-resolver`.
- If `build-error-resolver` returns without resolving the issue, output **BLOCKED** — do not attempt to fix it yourself
  again. The escalation chain ends here.

## Escalation Chain

1. Agent encounters error → analyze and try ONE alternative approach
2. Second failure → delegate to appropriate agent (e.g., `build-error-resolver`)
3. Agent also fails → output **BLOCKED** and ask the user for guidance
4. **There is no step 4.** Do not restart the chain or try again without user input.

## Context Management

- If context is getting large (many tool outputs), proactively distill stale outputs.
- Delegate all file reads to the `explore` agent via handoff.
- Delegate broad exploration instead of inline multi-step searches.

## When to Stop (BLOCKED)

Output **BLOCKED** and ask the user for guidance when:

- After 2 consecutive failed attempts at the same problem.
- When a delegated agent returns without resolving the issue.
- When you cannot articulate what you would change in a retry approach.
- When the error suggests a missing dependency or environment issue you cannot resolve.

## When to Ask the User (non-BLOCKED)

- When a fix requires a design decision (which pattern, which API, which library).
- When you're uncertain about the intended behavior.
- When trade-offs exist that only the user can decide.
