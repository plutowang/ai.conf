---
name: go
description: Auto-apply when working with Go (Golang). Trigger this skill when the user asks to create, modify, or debug Go code, HTTP handlers, middleware, CLI tools, or Go tests.
---

# Lang: Go

<red_lines>

1. **Errors:** Wrap with `fmt.Errorf("...: %w", err)`. Never ignore.
2. **Context:** `ctx context.Context` MUST be 1st arg.
3. **DB:** Use **SQLBoiler** models/executors. NO GORM/Raw SQL.
</red_lines>

<standards>
**Rules**

1. **Tests:** Group tests for the same function into a single test function. Use table-driven tests (`struct` slice) for multiple input scenarios, or `t.Run` for logically distinct test cases. Use `testify/require` for assertions.
2. **Layout:** Use `skill nx-monorepo` if `nx.json` exists. Otherwise use standard `cmd/`, `internal/`, `pkg/`.
3. **Libs:** Log=`log/slog`, Conc=`errgroup`.

**Docs**: Context7 `/golang/go` · Fallback: <https://go.dev/doc>
</standards>

<execution_protocol>
**Workflow**

- Use `skill workflow-env` before build/run commands.
- Build: `go build ./cmd/<app>`
- Test: `go test -v ./...`
- Format: `gofmt -w .`
</execution_protocol>
