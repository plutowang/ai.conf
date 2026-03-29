---
agent: evolver
description: Read the mistake book and execute architectural review to propose system upgrades
---

Please read `retrospective.md` (or the path provided by the user) and execute your architectural review.

Focus strictly on identifying:

1. "The API Guessing Loop" — the agent encounters an error, fails to find docs, and repeatedly blind-guesses syntax
2. "The Tool Misuse Loop" — the agent uses the wrong tool or violates conventions
3. "The Sandbox Rabbit Hole (Overthinking)" — the agent wastes steps building isolated test environments or performing
   useless context gathering

Diagnose the root causes and propose concrete rules to prevent each failure pattern.

Note: This prompt references an opencode-specific file (`retrospective.md`). In VSCode Copilot, adapt the path to point
to your own retrospective or lessons-learned file.

$ARGUMENTS
