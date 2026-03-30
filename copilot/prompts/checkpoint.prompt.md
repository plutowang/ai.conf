---
agent: agent
description: Save session progress summary for continuity
---

Summarize the current session progress. Run the following git commands and substitute their output into the template:

1. Run `git branch --show-current` → use as `branch`
2. Run `git log --oneline -1` → use as `last_commit`
3. Run `git diff --stat` → use as `diff_stat`

Output the filled-in template:

```yaml
## Session Checkpoint
goal: "<one-line description of the task>"
branch: "<output of git branch --show-current>"
last_commit: "<output of git log --oneline -1>"
diff_stat: |
  <output of git diff --stat>

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
