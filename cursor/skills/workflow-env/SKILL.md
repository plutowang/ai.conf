---
name: workflow-env
description: Auto-apply before any build, test, or run command. Validates env.sh before running build, test, or run commands.
---

# Environment Loading Protocol

<red_lines>

- **REFUSE to source** `env.sh` if it contains: `curl`, `wget`, `eval`, `exec`, piped commands (`|`), subshells (`$(...)`), backticks, `source`, `.` (sourcing other files), `rm`, `mv`, `cp`, `chmod`, `chown`, `sudo`, `apt`, `brew`, `npm install`, or any non-export logic.
</red_lines>

<execution_protocol>
**Rule**

Before any build/run/deploy command, check for `env.sh`:

1. **If present**: Validate it before sourcing.
   - **Inspect** the file contents first. It MUST contain only `export VAR=value` statements, comments, and blank lines.
   - If safe: `. ./env.sh && <command>`
2. **If absent**: Run the command normally.

**Applies To**

- Node: `pnpm` scripts (`dev`, `build`, `start`)
- Compilers: `zig`, `go`, `cargo`, `dotnet`
- Task runners: `make`, `just`, `rake`
- Infra: `docker`, `docker-compose`, `terraform`, `kubectl`

**Example**

```bash
# First validate env.sh contains only safe exports
cat env.sh  # inspect contents
. ./env.sh && pnpm build
```

</execution_protocol>
