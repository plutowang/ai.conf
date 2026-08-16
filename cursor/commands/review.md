---
name: review-code
description: Delegate code review to the code-reviewer agent. Use "/review" to auto-detect the base branch. Use "/review against <branch>" to specify it.
---

Delegate to `/code-reviewer` to review the current branch against a base branch.

If the user specifies "against <branch>", pass <branch> as the target base.

Otherwise, instruct the code-reviewer to auto-detect the default branch (main or master) as the base.
