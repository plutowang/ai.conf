---
agent: build-error-resolver
description: Run build, parse errors, fix them systematically until clean
---

First, detect the build system by checking for:
- `nx.json` → `pnpm nx run-many -t build --all`
- `Cargo.toml` → `cargo build`
- `go.mod` → `go build ./...`
- `package.json` → `pnpm build` or `bun run build`

Run the build command. Parse all errors. Fix them systematically in dependency order (imports/types first, then logic errors). After each fix batch, re-run the build to verify. Use manage_todo_list to track each error group. Do NOT stop until the build passes cleanly.

$ARGUMENTS
