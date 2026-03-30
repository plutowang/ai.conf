---
agent: code-reviewer
description: Review branch changes or critique specific files
---

Determine the review scope from the arguments:

- **Specific file, function, or code snippet**: load the `code-critic` skill and critique that target.
- **Branch, MR, or no specific target**: load the `code-review` skill and perform a full branch review.

Load only ONE skill — never both. Present findings directly to the user. Do not re-evaluate the code yourself.

$ARGUMENTS
