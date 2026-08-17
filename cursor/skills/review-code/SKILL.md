---
name: review-code
description: Delegate code review to the code-reviewer agent. Use after implementation to review the current branch. Use "/review-code" to auto-detect the base branch, or "/review-code against <branch>" to specify it.
disable-model-invocation: true
---
Delegate to `/code-reviewer` to review the current branch against a base branch.

If the user specifies "against <branch>", pass <branch> as the target base.

Otherwise, instruct the code-reviewer to auto-detect the default branch (main or master) as the base.
