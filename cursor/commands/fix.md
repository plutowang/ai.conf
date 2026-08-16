---
name: fix-bug
description: Diagnose and fix a bug in the active file with test-first approach
---

Analyze the code in the currently active editor tab and fix the reported issue.

<red_lines>
**No Shortcuts**
- No `TODO` or `FIXME` in production code without a linked tracking issue; no debug statements (console.log, println, dbg!, fmt.Println) left in committed code.
- No hardcoded magic numbers or strings — use named constants; no commented-out code blocks — delete them (version control preserves history).

</red_lines>

<execution_protocol>
**Process**
1. Read the code and understand the current behavior.
2. Identify the root cause — do not treat symptoms.
3. ⏸ (I) Present the diagnosis and proposed fix (including the failing-test plan). Wait for approval before applying changes.
4. Write a failing test that reproduces the bug.
5. Apply the minimal fix that resolves the issue without side effects.
6. Verify all existing tests pass and the new test passes.

</execution_protocol>

<standards>
**Type Safety**
- Use the strictest type system available — no `any`, no type suppression, no implicit conversions; prefer narrow, specific types over broad ones (discriminated unions, enums, branded types) where the language supports them.
- All function signatures must have explicit input and return types.
**Error Handling**
- Never suppress errors silently — handle, propagate, or explicitly acknowledge every error. No `.unwrap()`, bare `throw`, empty `catch`, or equivalent swallow patterns.
- Wrap errors with context at each layer boundary so the root cause is traceable; use typed error systems where available (error unions, Result types, typed exceptions).
**Defensive Coding**
- Validate all inputs at system boundaries (API endpoints, file I/O, user input, deserialization) — assume external data is malformed until proven otherwise; prefer immutability by default, mutating only when necessary and explicitly.
**Naming & Clarity**
- Names describe *what*, not *how* — prefer `isAuthenticated` over `checkAuth`; functions do one thing and their name says what; no abbreviations unless universally understood (`URL`, `HTTP`, `ID`).
**Control Flow**
- Limit control flow depth to 3 levels (if/for/switch); use guard clauses (early returns/continues) to flatten nesting — handle error/edge cases first, keep the happy path top-level.
- In loops, `continue` skips iterations early instead of wrapping the body in an `if`; `break` exits early instead of a flag variable. If logic needs deeper nesting, decompose into well-named helpers.
**Function Design**
- Functions should be cohesive and self-contained — prefer one well-structured function over a chain of tiny fragments.
- Extract a helper only when genuinely shared (2+ call sites) or a clearly distinct, nameable responsibility — not for one- or two-line functions unless non-obvious (e.g., a complex computation or logging/error-wrapping).
**Critical Thinking**
Deliver correct, maintainable solutions — not pleasing answers.
- **Challenge Before Executing** — Evaluate the approach first; state better alternatives when they exist.
- **Say No When It Matters** — Refuse anti-patterns (God classes, SQL injection, ignored errors, copy-paste duplication).
- **Question Ambiguity** — If requirements are vague or contradictory, stop and ask.
- **Trade-off Transparency** — Present trade-offs; let the human decide. Do not pick silently.
- **Disagree and Commit** — After stating concerns, if the human insists with valid reason, proceed.
**Red Flags to Call Out**
- Premature optimization without profiling data
- Unnecessary abstractions that add complexity without benefit
- Missing error handling or swallowed exceptions
- Security shortcuts (hardcoded secrets, unsanitized input, overly permissive access)
- Cargo-cult patterns copied without understanding
- Scope creep beyond what was asked
- Untested assumptions about data shape, API contracts, or runtime

</standards>
