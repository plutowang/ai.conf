---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development

Announce at the start: "I'm using the TDD skill. Enforcing TDD Iron Law."

<red_lines>
**Iron Law**

**No production code without a failing test first.** If you didn't watch the test fail, you don't know if it tests the right thing.

**Enforcement**

1. **Code before test → delete it and start over.** Don't keep it as reference, don't adapt it. No test, no code.
2. **Test passes on first run → wrong test.** You tested existing behaviour. Fix the test and re-run until it fails for the right reason.
3. **Any rationalization → red flag.** "Just this once", "too simple", "already spent hours" — every one means restart with TDD.

**Final Rule**

Production code → test exists and failed first. Otherwise → not TDD.
</red_lines>

<execution_protocol>
**Seams — Where Tests Go**

Tests verify behaviour through public interfaces, not implementation details. A **seam** is the public boundary where you observe behaviour without reaching inside. Test only at pre-agreed seams — confirm them with the user before writing any test.

Ask: "What's the public interface, and which seams should we test?"

**The Loop**

1. **Red** — Write one failing test at an agreed seam. Run it. Watch it fail for the right reason (feature missing, not a typo).
2. **Green** — Write only enough code to pass the test. No extra features, no unrelated refactors.

Refactoring (removing duplication, improving names) belongs to the review stage — outside the red → green implementation cycle. Do not restructure code during green.

**Bug Fixes**

Bug found? Write a failing test reproducing it BEFORE fixing. The test proves the fix and prevents regression. If no correct seam exists to test at, note it — the architecture needs improvement.
</execution_protocol>

<standards>
**Anti-Patterns**

- **Implementation-coupled** — mocks internal collaborators, tests private methods, or verifies through side channels. The tell: the test breaks when you refactor but behaviour hasn't changed.
- **Tautological** — the assertion recomputes the expected value the same way the code does, so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth.
- **Horizontal slicing** — writing all tests first, then all implementation. Tests verify imagined behaviour; work in **vertical slices** instead — one test, one implementation, repeat — so each test responds to what the last cycle taught you.

</standards>
