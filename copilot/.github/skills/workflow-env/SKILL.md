---
name: workflow-env
description: Auto-apply before running any common CLI build, test, or run commands (e.g., npm, pnpm, yarn, bun, make, just, cargo, go, dotnet, docker, terraform, kubectl, dev, start, deploy, serve, lint, format, compile, or bundle).
---

# Environment Loading Protocol

## Rule

Before any build/run/deploy command, check for `env.sh`:

1. **If present**: Validate it before sourcing.
   - **Inspect** the file contents first. It MUST contain only `export VAR=value` statements, comments, and blank lines.
   - **REFUSE to source** if it contains: `curl`, `wget`, `eval`, `exec`, piped commands (`|`), subshells (`$(...)`), backticks, `source`, `.` (sourcing other files), `rm`, `mv`, `cp`, `chmod`, `chown`, `sudo`, `apt`, `brew`, `npm install`, or any non-export logic.
   - If safe: `. ./env.sh && <command>`
2. **If absent**: Run the command normally.

## Applies To

- Node: `pnpm`, `bun` scripts (`dev`, `build`, `start`)
- Compilers: `zig`, `go`, `cargo`, `dotnet`
- Task runners: `make`, `just`, `rake`
- Infra: `docker`, `docker-compose`, `terraform`, `kubectl`

## Example

```bash
# First validate env.sh contains only safe exports
cat env.sh  # inspect contents
. ./env.sh && pnpm build
```
