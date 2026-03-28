---
name: nx-monorepo
description: Auto-apply when working in an Nx monorepo workspace. Trigger this skill when creating Nx libraries or apps, running nx commands (like affected), or generating Nx projects.
---

# Nx Monorepo Layout Detection

## Detection

Check for `nx.json` in the repository root:

- If present: Nx workspace layout.
- If absent: Standard layout.

## Layout

### Nx Workspace

- `apps/<app-name>/src/`
- `libs/<lib-name>/src/`

### Standard Layout

Frontend:

- `src/app/`
- `src/components/`

Backend (Go):

- `cmd/<app>/`
- `internal/`
- `pkg/`

Backend (Rust):

- `src/main.rs`
- `src/lib.rs`

## Usage

Detect layout before generating file paths or imports.
