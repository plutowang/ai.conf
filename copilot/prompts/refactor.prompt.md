---
agent: refactor
description: Guided refactoring with test verification at each step
---

Load the `workflow-env` skill. Analyze the specified code for refactoring opportunities. Before any changes:

1. Identify code smells (duplication, long methods, deep nesting, god objects)
2. Verify test coverage exists — write tests first if missing
3. Plan small, atomic refactoring steps
4. Execute each step and verify tests still pass
5. Never change external behavior

Target: $ARGUMENTS
