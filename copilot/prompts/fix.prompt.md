---
agent: builder
description: Apply a targeted fix for a specific error, bug, or issue
---

Apply a targeted fix for the following issue. This is a focused single-fix operation — do NOT refactor unrelated code or expand scope.

1. Understand the issue from `$ARGUMENTS` — read the error message or description carefully
2. Locate the root cause (not just the symptom) — use `explore` if you need to find the relevant file
3. Read the target file directly before editing
4. Apply the minimal fix that resolves the issue
5. Verify the fix: run the relevant test or build command to confirm it works
6. Report: what was wrong, what was changed (`file:line`), and the verification result

Issue: $ARGUMENTS
