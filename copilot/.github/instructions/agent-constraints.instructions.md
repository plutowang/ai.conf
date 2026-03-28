---
applyTo: '**'
---

# Agent Constraints

## File & Codebase Access

### Search & Discovery Guidelines

- **explore agent** is the preferred agent for codebase searches and web research. When you need to find files, search
  code patterns, or fetch external documentation, prefer handing off to the `explore` agent.
- **build agent** uses `read` directly before editing — this satisfies the edit timestamp check.
- All other agents should delegate file reading and searching to the `explore` agent.

### Build Agent

The `build` agent has `read` enabled and should use it directly before editing any file.

### All Other Agents

Delegate all file reading, codebase searches, and web fetches to the `explore` agent. You can do this by asking the
explore agent to find or read specific files, then using those results.

### No Direct File Reading via Bash

Do not use `bash` with `cat`, `head`, `tail`, or similar commands to read file contents — always use the `read` tool or
delegate to the explore agent.

---

## Code Execution

### Python Execution Guard

**NEVER** run `python` or `python3` directly. Running Python scripts can silently exfiltrate secrets via network calls,
environment variable reads, or file system access.

#### Preferred Alternative: jq

For JSON tasks, always prefer `jq`:

```bash
# Validate JSON syntax
jq . file.json

# Validate from stdin
echo '{"key": "val"}' | jq .

# Extract a field
jq '.key' file.json
```

#### Exception: Docker Sandbox

If Python is absolutely required, run it **inline** inside an isolated Docker container — no script file needed:

```bash
# Inline one-liner (preferred)
docker run --rm --network none -i python:3-alpine python -c "<your code here>"

# Multi-line via heredoc stdin
docker run --rm --network none -i python:3-alpine python - <<'EOF'
# your python code here
EOF

# Only if file I/O is needed: mount minimum directory as read-only
docker run --rm --network none -i -v "$(pwd):/work:ro" -w /work python:3-alpine python -c "<your code here>"
```

**Rules for Docker Python:**

- `--rm` — container destroyed after use (clean environment)
- `--network none` — no internet access whatsoever
- `-i` — allows stdin piping for inline code
- Use inline `-c` or heredoc stdin — **never write a `.py` file first**
- If a mount is needed, use `:ro` (read-only) and mount only the minimum directory
- **Never mount** directories containing secrets: `~/.ssh`, `~/.kube`, `~/.config`, `.env` parent dirs

---

## Privacy & Secret Handling

### Mandatory: Load Privacy Guard Skill

**ALWAYS** load the `privacy-guard` skill (type `/privacy-guard`) before:

- Reading any user-provided file
- Outputting or sharing file contents that may contain secrets, credentials, or PII
- Processing `.env`, config, credential, or key files of any kind

This applies even when the task appears unrelated to secrets — user-provided files may contain sensitive data that is
not immediately obvious. Skipping this step is a critical protocol violation.
