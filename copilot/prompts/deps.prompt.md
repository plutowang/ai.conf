---
agent: agent
description: Audit dependencies for vulnerabilities and outdated packages
---

Audit project dependencies for vulnerabilities and outdated packages.

1. Detect the package manager (pnpm or bun — NEVER use npm)
2. Check if this is an Nx workspace (look for nx.json)
3. Run the appropriate audit:
    - **Nx workspace**: `pnpm nx run-many -t audit --parallel=3` AND `pnpm audit`
    - **pnpm project**: `pnpm audit`
    - **bun project**: `bun pm trust --all` and review, or `bunx audit-ci`
    - **Cargo**: `cargo audit`
    - **Go**: `go list -m -json all` and check for known vulnerabilities
    - **Python**: `pip-audit` or `safety check`
    - **Dotnet**: `dotnet list package --vulnerable`
4. Report findings as: SEVERITY | PACKAGE | CURRENT | FIXED_IN | DESCRIPTION
5. Suggest a remediation plan ordered by severity

$ARGUMENTS
