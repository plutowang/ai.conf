---
agent: security-reviewer
description: Security audit against OWASP Top 10 and common vulnerabilities
---

Load the `privacy-guard` skill. Perform a security audit on the specified target.

Check for:
- Hardcoded secrets, API keys, or credentials
- SQL/command injection and XSS vulnerabilities
- Insecure deserialization and broken authentication
- Missing input validation and overly permissive CORS
- Missing rate limiting and sensitive data in logs
- Unpatched dependencies with known CVEs

Output findings as: SEVERITY | FILE:LINE | DESCRIPTION | RECOMMENDATION

Target: $ARGUMENTS
