---
agent: security-reviewer
description: Security audit against OWASP Top 10 and common vulnerabilities
---

Hand off this task to the `security-reviewer` agent. Load the `privacy-guard` skill. Perform a security audit on the
specified target. Check for: hardcoded secrets, SQL/command injection, XSS, insecure deserialization, broken auth,
missing input validation, overly permissive CORS, missing rate limiting, sensitive data in logs, unpatched dependencies.
Output findings as: SEVERITY | FILE:LINE | DESCRIPTION | RECOMMENDATION

Target: $ARGUMENTS
