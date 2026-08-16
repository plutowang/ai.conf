---
name: subagent-driven-dev
description: Load when executing an implementation plan with independent tasks. Dispatches a fresh subagent per task with two-stage review.
---

# Subagent-Driven Development (SDD)

Execute an implementation plan by dispatching a fresh subagent for each task. Each task undergoes two-stage review: spec compliance first, then code quality.

Announce at the start: "I'm using the subagent-driven-dev skill to execute this plan task by task."

<red_lines>

- **Review Order (Enforced)**: Spec compliance review **must** pass before starting code quality review. Never reverse this order — spec issues make code quality review wasteful.
- **Red Flags**: Never skip a review stage, proceed with unfixed issues, or accept "close enough" on spec compliance; never let self-review replace actual review. Implementation stays strictly serial — one implementer, one task at a time, never split across parallel agents.
- After 3 failed retries, escalate to the human: the plan or the approach itself is wrong.
</red_lines>

<execution_protocol>
**Why**

- Fresh context per task — no pollution from previous tasks
- Subagents follow TDD naturally with isolated focus
- Two-stage review catches both over/under-building and quality issues
- Continuous execution — no pausing between tasks

**Per-Task Process**

1. **Dispatch implementer** — Provide full task text, relevant context, file paths
2. **Implementer self-reviews** — Subagent tests, commits, and self-checks before handoff
3. **Spec compliance review** — Does the code match the plan? Is anything missing or extra?
4. **Code quality review** — Is the implementation well-built? (Only after spec review passes)
5. **Mark complete** — Both reviews must pass before moving to the next task

**Handling Subagent Status**

| Status              | Action                                                        |
| ------------------- | ------------------------------------------------------------- |
| **DONE**            | Proceed to spec compliance review                             |
| **DONE_WITH_CONCERNS**| Read concerns. Address correctness/scope issues before review |
| **NEEDS_CONTEXT**   | Provide missing info and re-dispatch                          |
| **BLOCKED**         | Fix context, use stronger model, or break task smaller. If the plan itself is wrong, escalate to human |

**Fix Loop**

If a task fails review, retry with escalating fixes — max 3 retries:

| Retry | Action |
| ----- | ------ |
| 1 | Clarify context or requirements, re-dispatch |
| 2 | Split the task into smaller pieces |
| 3 | Dispatch with a more capable model |

**Parallel Diagnosis (Allowed)**

Parallel subagents are permitted for **diagnosis only** — never for parallel implementation:

- Independent failure domains (different files, different services, different hypotheses) each get their own investigation subagent; dispatch them in one response so they run concurrently.
</execution_protocol>

<formatting_and_memory>
**Progress Ledger**

Maintain a running log under a `## Progress` heading in the plan file so state survives context compaction:

```text
[IN_PROGRESS] Task 3/7 — "Add auth middleware" — dispatched to implementer at 14:32
[DONE]        Task 3/7 — spec review passed, quality review passed
[FAILED]      Task 4/7 — review failed (missing edge case) — retry 1: context clarified
```

Update the ledger after every dispatch and every review. When resuming after compaction, the ledger is the source of truth.
</formatting_and_memory>
