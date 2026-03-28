# ai.conf

AI tooling configuration — a polyglot config repo for AI-assisted development tools.

Follows the `*.conf` naming convention from [`term.conf`](https://github.com/plutowang/term.conf.git).

## Structure

```
ai.conf/
├── copilot/      # GitHub Copilot (VS Code) configuration & migration guide
├── cursor/       # (future) Cursor rules & configuration
├── claude/       # (future) Claude Code configuration
└── shared/       # (future) Shared instructions across tools
```

## Contents

### `copilot/`

Configuration and migration guide for **GitHub Copilot in VS Code**.

- [`copilot/MIGRATION.md`](./copilot/MIGRATION.md) — Detailed guide for migrating from [opencode](https://opencode.ai) to VS Code Copilot: concept mapping, file-by-file migration steps, target directory structure, and known gaps.

## Philosophy

Each subfolder is self-contained and tool-specific. Shared conventions (code standards, git workflow, testing philosophy) live in `shared/` and are referenced by each tool's config.

The goal is **parity of intent** across tools — the same coding standards, agent behaviors, and workflow automation, expressed in each tool's native configuration format.
