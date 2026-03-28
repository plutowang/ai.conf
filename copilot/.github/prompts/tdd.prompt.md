---
agent: agent
description: Implement a feature using strict TDD red-green-refactor
---

Follow strict Test-Driven Development for the following task. Load the `workflow-env` skill first.

1. RED: Write a failing test that defines the desired behavior
2. GREEN: Write the minimal code to make the test pass
3. REFACTOR: Clean up while keeping tests green

Repeat for each unit of functionality. Never write implementation before a failing test exists. Use TodoWrite to track
each red-green-refactor cycle.

After each GREEN phase, run coverage to verify critical paths stay at 80%+: `go test -cover`, `cargo tarpaulin`,
`vitest --coverage`, `pytest --cov`.

Task: $ARGUMENTS
