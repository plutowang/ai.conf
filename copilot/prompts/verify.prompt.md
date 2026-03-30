---
agent: agent
description: Run full verification suite: types, lint, tests, security
---

Run full project verification:

1. Type checking / compilation
2. Linting
3. Unit tests
4. Check for console.log/debug statements in changed files
5. Check for hardcoded secrets or credentials
6. Verify error handling (no bare throws, no swallowed errors)

Report results as PASS/FAIL for each check. If any FAIL, list specific issues.

$ARGUMENTS
