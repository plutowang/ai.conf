---
agent: ask
description: Log a logical mistake or misunderstanding for the self-evolution pipeline
---

I am triggering the evolution pipeline to log a learning point.

$ARGUMENTS

Please review the recent conversation context to understand where you went wrong based on my recent corrections or the
arguments provided above.

CRITICAL INSTRUCTION:

1. If you CAN clearly identify your mistake and my correction from the context, you MUST output your self-reflection
   EXACTLY wrapped in the following tags. Do NOT output any conversational text outside the tags. Be brutally concise.

[EVOLUTION_NOTE]

- **Misunderstanding**: <Limit to 1-2 sentences. Describe exactly what you incorrectly assumed>
- **The Correction**: <Limit to 1-2 sentences. Explain the correct requirement>
- **Actionable Rule**: <Strictly 1 sentence. Start with ALWAYS or NEVER to prevent this>
  [/EVOLUTION_NOTE]

2. If you CANNOT find any actual correction in the recent context, or if the context is ambiguous, DO NOT generate the
   tags. Simply reply with: "Abort: No clear correction context found. Please specify the mistake using
   `/learn <details>`."
