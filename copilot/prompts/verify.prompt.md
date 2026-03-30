---
agent: agent
description: Run full verification suite: types, lint, tests, security
---

Run full project verification. Detect the project type and run the appropriate commands:

| Check | TypeScript/Node | Go | Rust | Python |
|---|---|---|---|---|
| Type check | `tsc --noEmit` | `go build ./...` | `cargo check` | `mypy .` |
| Lint | `pnpm lint` | `go vet ./...` | `cargo clippy` | `ruff check .` |
| Tests | `pnpm test` | `go test ./...` | `cargo test` | `pytest` |

For Nx workspaces: `pnpm nx affected -t typecheck,lint,test`

Also check:
4. `console.log`, `dbg!`, `fmt.Println` debug statements in changed files
5. Hardcoded secrets, API keys, or credentials
6. Error handling — no bare throws, no swallowed errors

Report results as PASS/FAIL for each check. If any FAIL, list the specific file:line issues.

$ARGUMENTS
