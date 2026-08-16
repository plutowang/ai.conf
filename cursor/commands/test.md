---
name: generate-tests
description: Generate unit tests for the active file using the AAA pattern
---

Analyze the code in the currently active editor tab and generate comprehensive unit tests.

<red_lines>
- **NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.** Write code before a test? Delete it. Start over.
- **Violating the letter is violating the spirit.** "Tests after achieve the same result" is not a technical argument — it is rationalization. A test that never failed proves nothing.
- Red Flags — Stop and Restart — any of these means: delete the code and restart with TDD.
- Production code written before a test; test passes on first run (you tested existing behavior).
- Can't explain why the test failed; rationalizing "just this once".
- Tests added after implementation "to catch up".
**Rationalizations (Do Not Use)**
- "Too simple to test" — Simple code breaks. Test takes seconds.
- "I'll test after" / "Tests after do the same" — Tests-after verify only the code you remembered to check; passing immediately proves nothing.
- "Already manually tested" / "Manual test is faster" — Manual testing is ad-hoc: no record, can't be re-run, proves no edge cases.
- "Deleting code is wasteful" — Sunk cost fallacy. Untested code is technical debt.
- "Need to explore first" / "Keep it as reference" — Throw away exploration; keeping pre-test code is testing after. Delete means delete.
- "TDD will slow me down" — Debugging without tests is slower than TDD.
- "Existing code has no tests" — You are improving it — start with the new code.
**Anti-Patterns to Avoid**
- Tests that test the implementation rather than behavior; flaky tests dependent on timing, network, or filesystem state.
- Snapshot tests for anything other than serialized output (never for UI components); test files that import directly from external packages or services.

</red_lines>

<execution_protocol>
**Process**
0. **Invariant ⏸ (IV) exception** — This command generates characterization tests for code that already exists. Writing tests here is the command's purpose, not a test-after violation. Do not modify production code in this command; any production-code change follows RED-first discipline separately.
1. Identify all public functions, methods, and edge cases.
2. Generate tests using the Arrange → Act → Assert pattern.
3. Include both happy-path and failure-mode coverage.
4. Use table-driven tests when testing the same logic with multiple inputs.
5. ⏸ (I) Present the proposed test plan to the user before writing any test files.

**RED → GREEN → REFACTOR**
- **RED — Write Failing Test**: one minimal test showing expected behavior (clear name, real code, minimal mocks); verify it fails for the expected reason (feature missing, not a typo).
- **GREEN — Minimal Code to Pass**: only enough code to pass — no extra features, no unrelated refactors.
- **REFACTOR — Clean Up**: remove duplication, improve names — keep tests green, never add behavior.
**Order Matters**
Tests written after code prove nothing — they pass immediately and may test the wrong thing. Test-first forces discovery of edge cases before implementation, prevents regressions, and documents behavior.
**When Stuck**
- Don't know how to test → write the wished-for API and the assertion first; ask the human if still stuck.
- Test too complicated → the design is too complicated. Simplify the interface.
- Must mock everything → the code is too coupled. Use dependency injection.
- Test setup is huge → extract helpers; still complex? Simplify the design.
**When to Write Tests**
- New public functions/methods: always (test-first).
- Bug fixes: a failing test that reproduces the bug BEFORE fixing it.
- Refactors: verify existing tests pass before AND after; add tests if coverage gaps exist.
- Skip only: generated code, trivial getters/setters, one-off scripts.

</execution_protocol>

<standards>
**Philosophy**
- Tests document intent — answer: "what behavior does this protect?"
- Prefer **integration tests** for business logic; unit tests for pure functions and edge cases.
- Never mock what you don't own — wrap external dependencies behind interfaces, then mock the interface.
**Test Structure**
- Follow **Arrange → Act → Assert** (AAA); one logical assertion per test — test one behavior, not one function.
- Test names describe scenario + expected outcome: `should_return_404_when_user_not_found`.
**Coverage & Priority**
- Target **80% minimum coverage** on critical paths (authentication, payment, data mutations) — don't chase 100%; diminishing returns past 85%.
- Coverage is a metric, not a goal — untested edge cases matter more than high percentages.
**Table-Driven Tests**
- When testing the same logic with multiple inputs, use parameterized/table-driven tests to reduce duplication.

</standards>

<pre_flight_check>
Before marking TDD work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail for the expected reason (feature missing, not a typo)
- [ ] Wrote minimal code to pass (no extra features, no unrelated refactors)
- [ ] All tests pass, output pristine (no errors or warnings); edge cases and error paths covered

</pre_flight_check>
