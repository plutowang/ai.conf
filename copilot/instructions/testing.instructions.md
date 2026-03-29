---
applyTo: '**'
---

# Testing Standards

## Philosophy

- Tests document intent. Every test should answer: "what behavior does this protect?"
- Prefer integration tests over unit tests for business logic; unit tests for pure functions and edge cases.
- Never mock what you don't own — wrap external dependencies behind interfaces, then mock the interface.

## When to Write Tests

- New public functions/methods: always.
- Bug fixes: write a failing test that reproduces the bug BEFORE fixing it.
- Refactors: verify existing tests pass before AND after. Add tests if coverage gaps exist.
- Skip tests only for: generated code, trivial getters/setters, one-off scripts.

## Test Structure

- Follow Arrange-Act-Assert (AAA) or Given-When-Then pattern.
- One logical assertion per test. Multiple assertions are acceptable only when verifying a single behavior.
- Test names describe the scenario: `TestPaymentProcessor_RefundExceedingBalance_ReturnsError`.

## Language-Specific

- **Go**: Use `testing` stdlib + `testify` for assertions. Table-driven tests for multiple inputs. `t.Parallel()` by
  default.
- **Rust**: `#[cfg(test)]` module in same file. Use `#[should_panic]` for error cases. Property testing with `proptest`
  for complex invariants.
- **TypeScript**: Vitest or Jest. Use `describe/it` blocks. Mock with `vi.mock()` or `jest.mock()`. Prefer `toEqual`
  over `toBe` for objects.
- **Python**: pytest. Fixtures over setup/teardown. Parametrize for data-driven tests. `pytest.raises` for exceptions.

## Coverage

- **80% minimum** line coverage on critical paths (auth, payments, data processing).
- Run coverage checks: `go test -cover`, `cargo tarpaulin`, `vitest --coverage`, `pytest --cov`.
- Do not chase 100% — diminishing returns past 85%.
- Coverage is a metric, not a goal. Untested edge cases matter more than high percentages.

## Anti-Patterns to Avoid

- Tests that test the implementation rather than behavior.
- Flaky tests dependent on timing, network, or filesystem state.
- Test files that import from `node_modules` or external services directly.
- Snapshot tests for anything other than serialized output (never for UI components).
