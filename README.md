# ai.conf

AI tooling configuration — a polyglot config repo for AI-assisted development tools.

Follows the `*.conf` naming convention from [`term.conf`](https://github.com/plutowang/term.conf.git).

## Structure

```text
ai.conf/
├── opencode/     # opencode (terminal AI) config — agents, commands, skills, rules
├── cursor/       # Cursor config — agents, commands, rules, MCP, sandbox
└── copilot/      # GitHub Copilot (VS Code) configuration & migration guide
```

## Contents

### `opencode/`

Configuration for [opencode](https://opencode.ai):

- `agents/` — subagents (architect, build, code-reviewer, security-reviewer, verifier, ...)
- `commands/` — slash commands (commit, review, test, fix, ...)
- `skills/` — language and workflow skills (Go, Rust, TDD, code review, ...)
- `rules/` — global instructions (`AGENTS.md`, critical invariants, agent constraints)
- `plugins/`, `bin/` — PII-masking plugin and `zmask` binaries
- `opencode.json` — permissions, MCP servers, model providers, LSP configuration

### `cursor/`

Configuration for Cursor:

- `agents/`, `commands/` — agents and slash commands
- `rules/` — `.mdc` rules (code standards, testing, security, API design, ...)
- `skills/` — shared skill set (mirrors `opencode/skills/`)
- `mcp.json`, `sandbox.json` — MCP servers and sandbox network policy
- `settings.json`, `cli-config.json`, `extensions.json` — editor, CLI permissions, and recommended extensions

### `copilot/`

Configuration for GitHub Copilot in VS Code: custom agents, prompts, skills, and file-based instructions.

## Philosophy

Each subfolder is self-contained and tool-specific. The goal is **parity of intent** across tools — the same coding standards, agent behaviors, and workflow automation, expressed in each tool's native configuration format.
