---
name: receiving-code-review
description: Use when receiving code review feedback, before implementing suggestions, especially if feedback seems unclear or technically questionable — requires technical rigor and verification, not performative agreement or blind implementation
---

# Code Review Reception

<red_lines>

- **Core principle:** Verify before implementing. Ask before assuming. Technical correctness over social comfort.
- Performative agreement ("You're absolutely right!", "Great point!") wastes tokens and signals passive acceptance — ANY gratitude expression; actions speak, state the fix instead.
- IF any item is unclear: STOP — ask for clarification before implementing anything; items may be related. Partial understanding = wrong implementation.
- ❌ Long apologies / defending the pushback / over-explaining after being wrong.
- IF suggestion seems wrong: push back with technical reasoning.
- IF can't easily verify: say so — "I can't verify this without [X]. Should I investigate or ask?"
- IF conflicts with prior human decisions: stop and discuss with the human first.
</red_lines>

<execution_protocol>
**Overview**

Code review requires technical evaluation, not emotional performance.

**The Response Pattern**

```text
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

**Source-Specific Handling**

**From the human**

- Trusted — implement after understanding. Still ask if scope is unclear.
- No performative agreement. Skip to action or technical acknowledgment.

**From external reviewers**

```text
BEFORE implementing:
  1. Check: technically correct for THIS codebase?
  2. Check: breaks existing functionality?
  3. Check: reason for the current implementation?
  4. Check: does the reviewer understand the full context?
```

**YAGNI Check for "Professional" Features**

```text
IF a reviewer suggests "implementing properly":
  search the codebase for actual usage

  IF unused: "This isn't used anywhere. Remove it (YAGNI)?"
  IF used: then implement properly
```

**Implementation Order**

```text
FOR multi-item feedback:
  1. Clarify anything unclear FIRST
  2. Then implement in this order:
     - Blocking issues (breaks, security)
     - Simple fixes (typos, imports)
     - Complex fixes (refactoring, logic)
  3. Test each fix individually
  4. Verify no regressions
```

**When To Push Back**

Push back when:

- The suggestion breaks existing functionality
- The reviewer lacks full context
- It violates YAGNI (unused feature)
- It is technically incorrect for this stack
- Legacy or compatibility reasons exist
- It conflicts with prior architectural decisions

**How:** Technical reasoning, not defensiveness. Ask specific questions. Reference working tests. Involve the human for architectural conflicts.

**Acknowledging Correct Feedback**

```text
✅ "Fixed. [brief description of what changed]"
✅ [Just fix it and show the code]
```

**If You Pushed Back and Were Wrong**

```text
✅ "You were right — I checked [X] and it does [Y]. Implementing now."
```

State the correction factually and move on.
</execution_protocol>

<formatting_and_memory>
**Common Mistakes**

| Mistake | Fix |
| ------- | --- |
| Performative agreement | State the requirement or just act |
| Blind implementation | Verify against the codebase first |
| Batch without testing | One at a time, test each |
| Assuming the reviewer is right | Check whether it breaks things |
| Avoiding pushback | Technical correctness > comfort |
| Partial implementation | Clarify all items first |
| Can't verify, proceed anyway | State the limitation, ask for direction |
</formatting_and_memory>
