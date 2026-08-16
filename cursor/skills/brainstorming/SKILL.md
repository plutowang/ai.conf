---
name: brainstorming
description: Load before any creative work — features, components, behavior changes. Explores intent, proposes approaches, writes spec. HARD-GATE - no code before spec approval.
---

# Brainstorming: Ideas Into Designs

Turn ideas into fully formed specs through collaborative dialogue.

Announce at the start: "I'm using the brainstorming skill to turn this into a spec."

<red_lines>

- **HARD-GATE**: Do NOT implement anything — no code, no scaffolding — until the spec is written and the human explicitly approves it. This applies to every project, regardless of perceived simplicity. Single-file bug fixes, typos, and straightforward test additions are exempt from spec creation per Invariant I; load `writing-plans` only for work that benefits from a full plan.
</red_lines>

<execution_protocol>
**Process**

1. **Gather context** — Build an accurate picture of the current state: the affected code, the docs, recent commits. Delegate retrieval if you cannot read directly.
2. **Check scope** — Before asking detailed questions, assess scope. If the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, and billing"), flag it immediately — don't refine details of a project that needs decomposition first. For too-large projects, help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built? Each sub-project gets its own spec → plan → implementation cycle.
3. **Ask clarifying questions** — One at a time. Prefer multiple-choice. Understand purpose, constraints, success criteria. When several decisions are genuinely independent (no answer depends on another still-open question), batch them into a frontier round: number each question and give your recommended answer, then wait for all responses before the next round.
4. **Propose 2–3 approaches** — With trade-offs and a recommendation
5. **Present design** — Cover architecture, components, data flow, error handling, testing. Validate each section as you go
6. **Write design doc** — Save to `docs/specs/YYYY-MM-DD-<slug>.md`. Self-review before presenting:
   - **Placeholder scan** — Any "TBD", "TODO", or vague requirements? Fix them inline.
   - **Internal consistency** — Do sections contradict each other? Does the architecture match the feature descriptions?
   - **Scope check** — Focused enough for a single implementation plan, or does it need decomposition?
   - **Ambiguity check** — Could any requirement be read two ways? Pick one and make it explicit.
7. **HITL Gate** — Ask the human to review the spec before proceeding

**After Approval**

Load `writing-plans` to create the implementation plan.
</execution_protocol>

<standards>
**Key Principles**

- **One question at a time.** Break multi-faceted topics into separate questions; batch independent decisions into frontier rounds (see step 3). Thoroughness over speed.
- **YAGNI ruthlessly.** Remove unnecessary features from every design
- **Propose alternatives.** Never settle on the first approach without considering others
- **Design for isolation.** Each unit should have one clear purpose, a well-defined interface, and be independently testable. Ask: can someone understand this unit without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.
- **Work within existing patterns.** Explore the current codebase before proposing changes and follow its conventions. Where existing code problems affect the work (tangled responsibilities, oversized files), include targeted improvements in the design — but no unrelated refactoring.

</standards>
