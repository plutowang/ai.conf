---
agent: code-reviewer
description: Review branch changes or critique specific files
---

Hand off this task to the `code-reviewer` agent. Determine the review scope from the arguments. If a specific file,
function, or code snippet is targeted, load the `code-critic` skill and critique that target. If no specific target is
given or a branch/MR is referenced, load the `code-review` skill and perform a full branch review. Load only ONE skill,
never both. When the code-reviewer returns its report, present the findings to the user. Do not re-evaluate the code
yourself. $ARGUMENTS
