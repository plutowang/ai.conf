---
agent: build-error-resolver
description: Run build, parse errors, fix them systematically until clean
---

Run the project build command. Parse all errors. Fix them systematically in dependency
order (types/imports first, then logic errors). After each fix batch, re-run the build to verify. Use manage_todo_list to track
each error. Do NOT stop until the build passes cleanly.

$ARGUMENTS
