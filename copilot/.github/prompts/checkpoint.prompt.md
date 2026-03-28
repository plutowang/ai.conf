---
agent: agent
description: Save session progress summary for continuity
---

Summarize the current session progress using this structured format. Run git commands to capture exact repo state.

Output using this template:

```yaml
## Session Checkpoint
goal: "<one-line description of the task>"
branch: "!`git branch --show-current`"
last_commit: "!`git log --oneline -1`"
diff_stat: "!`git diff --stat`"

completed:
  - "<file:line — what was done>"

remaining:
  - "<step — what still needs to be done>"

blockers:
  - "<blocker or open question>"

context: |
  <key architectural decisions, patterns used, gotchas discovered>
```

This checkpoint can be pasted into a `/continue` prompt to resume work in a new session.
