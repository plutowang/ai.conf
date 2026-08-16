---
name: domain-modeling
description: Use when defining or refining project terminology, building a shared glossary, recording architectural decisions, or when another skill needs a precise domain model. Actively challenges ambiguous terms and records decisions as they crystallise.
---

# Domain Modeling

Actively build and sharpen the project's domain model as you work. This is the *active* discipline — challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise.

<standards>
**File Structure**

Most repos use a single context:

```text
/
├── CONTEXT.md          ← glossary of domain terms
├── docs/
│   └── adr/            ← architectural decision records
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts — the map points to where each one lives. Create files lazily: no `CONTEXT.md` until the first term is resolved; no `docs/adr/` until the first ADR is needed.
</standards>

<execution_protocol>
**During the Session**

**Challenge Against the Glossary**

When someone uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "'Cancellation' is defined as X in the glossary, but you seem to mean Y — which is it?"

**Sharpen Fuzzy Language**

When vague or overloaded terms appear, propose a precise canonical term. "You said 'account' — do you mean Customer or User? Those are different things."

**Stress-Test with Scenarios**

Invent scenarios that probe edge cases and force precision about boundaries between concepts.

**Cross-Reference with Code**

When someone states how something works, check whether the code agrees. Surfacing a contradiction early prevents rework.

**Update CONTEXT.md Inline**

When a term is resolved, update `CONTEXT.md` immediately — don't batch. The file is a glossary, not a spec or scratch pad. No implementation details.

Format:

```md
# Context Name

## Language

**Order**: A customer's request to purchase products.  
_Avoid_: Purchase, transaction

**Invoice**: A request for payment sent after delivery.  
_Avoid_: Bill, payment request
```

**Offer ADRs Sparingly**

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will wonder why this choice was made.
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons.

If any of the three is missing, skip the ADR. An ADR is a single paragraph recording context, decision, and rationale. Number them sequentially (`0001-slug.md`) in `docs/adr/`.
</execution_protocol>
