---
applyTo: '**'
---

# Development Workflow

## Human-in-the-Loop (HITL)

This workflow follows a **propose → approve → execute** model. The agent never proceeds past a gate without explicit
human approval. When uncertain, the agent presents options and a recommendation — it does not guess silently.

**Hard rules:**

- NEVER run `git commit`, `git push`, or `git add` — output a commit message and stop
- NEVER hand off to a subagent without asking first — except `explore`, which may be used automatically as needed
- NEVER start writing code before the plan is approved

**Feedback & Evolution:**
If the user corrects a logical mistake or misunderstanding, treat it as a learning event. Accept the correction and note
it for future reference.

## Task Approach (The Loop)

Every non-trivial task follows this loop:

1. **Gather Context** — Search the codebase for related code using the `explore` agent. Understand existing patterns,
   conventions, and architecture before writing anything.
2. **Plan** — Use TodoWrite to break the task into discrete steps. Identify dependencies, risks, and unknowns.
3. **⏸ WAIT** — Present the plan to the user. Do not touch any files until the user explicitly approves.
4. **Implement** — Work through the plan step by step. Mark todos in_progress/completed as you go. Make targeted edits,
   not wholesale rewrites.
5. **Verify** — Run the build, tests, and lints. Fix any failures before moving on.
6. **⏸ WAIT** — Summarize all changes made. Ask the user before invoking any review agent.
7. **Report** — Summarize what was done, what was changed, and any follow-up items.

## Write Safety

- Verify the file exists before attempting writes.
- When creating new files, verify the parent directory exists first.

## Testing

- Tests document intent — every test should answer: "what behavior does this protect?"
- **When to write tests**: new public functions (always), bug fixes (write failing test BEFORE fixing), refactors (
  verify tests pass before AND after).
- **When to skip**: generated code, trivial getters/setters, one-off scripts — or when the user explicitly skips.
- **HITL**: Before running tests, present the test plan and ask the user to confirm. User may skip tests and proceed to
  the next step.

## Bash Execution Safety

- **Destructive Commands**: NEVER run `git commit`, `git push`, `git add`, or `git rebase` under any circumstances.
- **Read-Only Commands**: Commands like `git status`, `git diff`, and `ls` are 100% safe. Execute them without
  deliberation. Action beats deliberation.

## Complex Task Orchestration

For non-trivial features, chain agents in phases:

1. **Plan** (`/plan`) — Analyze requirements, produce TodoWrite plan with risks and affected files
2. **⏸ WAIT** — Present plan to user. Wait for explicit approval. Do NOT proceed without it.
3. **Build** (Agent) — Implement plan step-by-step, verify each step
4. **⏸ WAIT** — Summarize all changes. Ask: "Should I run code-reviewer / security-reviewer?" Wait for answer.
5. **Review** (`/review`) — Only if user approves. Validate correctness, security, types, and quality.
6. **Verify** (`/verify`) — Run full check suite: types, lint, tests, secrets, debug statements
7. **Commit** (`/commit`) — Output conventional commit message only. STOP. Never run git commands.

Rules:

- Each phase completes before the next begins
- **Plan MUST be approved by user before any file is touched**
- Before handing off to another agent, ask the user first — `explore` is the only exception and may be used
  automatically as needed
- If review finds issues, loop back to build (max 2 iterations), then ask user again
- If verify fails, fix and re-verify before suggesting a commit message
- NEVER run `git commit`, `git push`, `git add`, or `git rebase`

## Communication

- State what you're about to do before doing it (one sentence, not a paragraph).
- When done, state what you did and any follow-up needed.
- **When uncertain or at a decision point**: present 2-3 options with trade-offs, state your recommended choice clearly,
  then stop and ask the user to decide. Never silently pick an option when alternatives exist.
