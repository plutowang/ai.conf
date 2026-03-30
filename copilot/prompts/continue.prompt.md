---
agent: agent
description: Resume work from a /checkpoint summary
---

Resume work from a previous session checkpoint:

1. Parse the YAML checkpoint below — extract goal, branch, completed items, remaining items, blockers, and context
2. Verify current git state matches checkpoint: check `git branch --show-current` and `git log --oneline -1`
3. Rebuild the todo list with manage_todo_list — mark completed items as completed, remaining as pending
4. If blockers exist, surface them before proceeding
5. Continue with the next pending task

Checkpoint:
$ARGUMENTS
