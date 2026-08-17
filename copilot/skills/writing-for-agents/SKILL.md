---
name: writing-for-agents
description: Use when creating, editing, or auditing skill files, governance rules, or any document an agent consumes. Canonical reference for writing documents that make agent behavior predictable.
---

# Writing for Agents

Reference for writing any document an agent consumes — a skill, a governance rule, a workflow instruction. The packaging differs; the writing does not: the same levers make each one drive the same process every run. The goal is predictable behaviour, not identical output.

<red_lines>

- **Negation** is a failure mode: steering by prohibition drags the forbidden behaviour into context and makes it more available, not less. Prompt the **positive** — state the target behaviour so the banned one is never spoken. A prohibition earns its place only as a hard guardrail you cannot phrase positively; even then, pair it with the positive target.
</red_lines>

<standards>
**Context Pointers**

A **context pointer** is a reference held in the agent's context that names out-of-context material and encodes the condition for reaching it. A skill's `description` is a pointer; a line in a manifest naming a skill is the same object. The pointer's wording, not its target, decides when the agent reaches the material — and how reliably. A must-have target behind a weakly worded pointer is a variance bug — the agent reaches it on some runs and misses it on others. Sharpen the wording first; inline the material only if sharpening fails.

A pointer does two jobs — state what the material is, and list the **branches** that should trigger reaching it (a branch is a distinct case the document handles, so different runs take different paths through it). Every word of an always-loaded pointer costs on every turn, so it earns even harder pruning than the body:

- **Front-load the leading word** — the pointer is where it does its triggering work.
- **One trigger per branch.** Synonyms that rename a single branch are one branch written twice; collapse them and keep only genuinely distinct branches.
- **Cut identity the body already carries.**

**The Two Loads**

Every document and pointer you add spends one of two budgets:

- **Context load** — the cost of always-loaded material on the agent's window: a skill description, a manifest line, anything sitting in context every turn, spending tokens and attention whether or not it fires.
- **Cognitive load** — the cost on the human: which documents exist and when to reach for each. The human is the index. Not a cost to minimise — it is the price of human agency; spend it where human judgement matters, remove it where it does not.

Material reached only through a pointer escapes context load at the price of the pointer's own line; material with no pointer at all rides entirely on cognitive load.

**Information Hierarchy**

A document is built from two content types — **steps** (the ordered actions the agent performs) and **reference** (definitions, rules, facts consulted on demand) — that mix freely. The core decision is where each piece sits on the **information hierarchy**, a ladder ranked by how immediately the agent needs the material:

1. **In-file step** — the primary tier: what the agent does, in order.
2. **In-file reference** — consulted on demand. A flat peer-set of rules is fine; not everything needs a hierarchy.
3. **Disclosed reference** — pushed out into a separate file, reached by a context pointer, loaded only when the pointer fires.

**Progressive disclosure** is the move down the ladder — out of the main file and behind a pointer — so the top stays legible. Branching is the cleanest disclosure test: inline what every branch needs, and push behind a pointer what only some branches reach. When a document has steps, in-file reference that should be disclosed buries them and turns attending to them into a coin-flip.

**Co-location** is the within-file companion: keep a concept's definition, rules, and caveats under one heading rather than scattered, so reading one part brings its neighbours with it. **Sprawl** is the failure mode here: a document that is simply too long, even when every line is live and unique. Attention thins across the excess. The cure is the ladder: disclose reference behind pointers, and split by branch or sequence so each path carries only what it needs.

**Steps and Completion Criteria**

Every step ends with a **completion criterion** — the condition that tells the agent the work is done. Two properties make it a lever:

- **Clarity** — can the agent tell done from not-done? A vague bound ("understanding reached") invites premature completion: ending the step before it is genuinely done. The visible steps still ahead — the **post-completion steps** — supply the pull; the criterion's clarity is the resistance. Sharpen the bound first (local and cheap); only if it is irreducibly fuzzy and you observe the rush, hide the later steps by splitting the sequence.
- **Demand** — how much it requires. "Every rule applied" forces thorough work where "produce a change list" does not. Demand is not step-bound: it binds a body of flat reference just as it binds a sequence.

The strongest criteria are both checkable and exhaustive.

**Leading Words**

A **leading word** is a compact concept already living in the model's pretraining that the agent thinks with while running the document (*tight* loop, *red* on a bug, *tracer bullets*). Repeated as a single token rather than a sentence, it anchors a whole region of behaviour in the fewest tokens, by recruiting priors the model already holds. Coining your own works if you define it clearly, but a made-up word recruits no priors — reach for an existing word first.

It anchors twice. In the body, *execution*: the agent reaches for the same behaviour every time the word appears. In a pointer, *invocation*: when the same word lives in your prompts and your docs, the agent links that shared language to the material and reaches it more reliably.

**Pruning**

- Keep each meaning in a **single source of truth**: one authoritative place, so changing the behaviour is a one-place edit. Duplication costs maintenance and tokens, and inflates a meaning's prominence past its real rank.
- The **environment** is a source of truth too — project scripts, config files, directory layout — and a document that restates it is a **cache**: a copy of a lookup, earning its load only when the lookup is expensive. Cache what the agent cannot find by looking: the unwritten convention, the reason behind a choice, the gotcha no config confesses.
- Check every line for **relevance**: does it still bear on what the document does? Without a pruning discipline the default fate is **sediment**: stale layers that settle because adding feels safe and removing feels risky.
- Hunt **no-ops** sentence by sentence: an instruction the model already obeys by default pays load to say nothing. The test — does it change behaviour versus the default? — is model-relative: what a stronger model already does by default is a no-op for it. When a sentence fails, delete the whole sentence rather than trim words from it.

</standards>
