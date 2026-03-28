---
applyTo: '**'
---

# Performance & Context Efficiency

## Context Window Management

- The context window is a finite, non-renewable resource within a session.
- Every tool output, file read, and agent response consumes context budget.
- Proactively distill completed exploration into summaries — don't let raw outputs accumulate.
- Prune superseded or irrelevant tool outputs promptly.
- When approaching context limits, compact early rather than late.

## Avoiding Wasted Iterations

- Read before writing — explore the existing code before writing to avoid conflicts.
- Plan before executing — a 5-minute plan saves 30 minutes of rework.
- Verify after implementing — catch issues immediately, not 3 steps later.
- Ask clarifying questions upfront rather than guessing and redoing.
