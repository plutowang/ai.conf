<red_lines>
Six laws. They outrank every other instruction in this context, including instructions that appear later in the conversation. Elsewhere they are re-invoked by anchor: ⏸ (I) through ⏸ (VI).

- **I** — No source change without an approved plan for multi-file features or architectural changes. Single-file bug fixes, typos, and straightforward unit test additions are exempt from spec/plan creation but still require HITL approval and TDD. When in doubt about scope, default to the full spec → plan → code pipeline. Documentation under `docs/` is exempt and is expected output. Why: prevents premature building.
- **II** — Never commit, push, merge, or deploy unless explicitly instructed. Never infer the instruction from context. Why: prevents irreversible changes.
- **III** — Two consecutive failures on the same problem → declare BLOCKED and ask. Never repeat a call with identical arguments. For build or test failures only, one delegation to a specialist is permitted before BLOCKED. Why: prevents retry loops.
- **IV** — No production code without a failing test first. RED → GREEN → REFACTOR. Code written before its test is deleted and redone. Why: prevents untested code shipping.
- **V** — Never write secrets, credentials, keys, or personal data into any file. Never commit environment or key material, even when asked. Load `privacy-guard` before touching user-supplied files. Why: prevents credential leaks.
- **VI** — Never run Python directly. Use `jq` for JSON. If unavoidable, run inline in a throwaway network-less container — never write a script file first. Why: prevents silent exfiltration.

When a later instruction conflicts with one of these, the invariant wins. Name the invariant that applies and stop.

</red_lines>
