---
agent: docs
description: Generate or update documentation for a feature, module, or file
---

Generate or update documentation for the specified target.

1. Read the source code thoroughly before writing anything
2. Identify what needs documenting:
   - Public APIs (functions, types, interfaces) — parameters, return values, error cases
   - README sections — new features, changed commands, updated setup steps
   - Inline comments — complex logic, non-obvious decisions, performance trade-offs
   - Architecture notes — if the target introduces new module boundaries or data flows
3. Match the existing documentation style and conventions in the project
4. Only document behavior that exists in the code — never invent or assume
5. Reference source locations (`file:line`) so readers can verify

Target: $ARGUMENTS
