---
name: diagnosing-bugs
description: Use when diagnosing hard bugs, debugging failures, investigating performance regressions, or when a bug resists a first-glance fix. Disciplined diagnosis loop from feedback loop through fix to post-mortem.
---

# Diagnosing Bugs

A discipline for hard bugs. Skip phases only when explicitly justified.

<red_lines>

- **This is the skill.** If you have a **tight** pass/fail signal for the bug — one that goes red on *this* bug — you will find the cause. Without one, no amount of reading code will save you.
- When you cannot build a loop: stop and say so. List what you tried. Ask for: access to the reproduction environment, a captured artifact (log dump, screen recording with timestamps), or permission to add temporary production instrumentation. Do **not** proceed to hypothesise without a loop.
- A hypothesis you cannot state a prediction for is a guess — discard or sharpen it.
- Write the regression test **before the fix** — but only if a **correct seam** exists. A correct seam exercises the real bug pattern as it occurs at the call site. A unit test that cannot replicate the chain that triggered the bug gives false confidence.
</red_lines>

<execution_protocol>
**Phase 1 — Build a Feedback Loop**

Ways to construct one, in roughly descending order of preference:

1. **Failing test** at whatever seam reaches the bug — unit, integration, end-to-end.
2. **HTTP script** (curl or similar) against a running dev server — local diagnostic requests, not general web fetching.
3. **CLI invocation** with a fixture input, diffing output against a known-good snapshot.
4. **Headless browser script** — drives the UI, asserts on DOM or console output.
5. **Replay a captured trace** — save a real request or event log to disk; replay it through the code path in isolation.
6. **Minimal harness** — spin up the smallest subset of the system that exercises the bug path with a single function call.
7. **Property / fuzz loop** — run many random inputs and look for the failure mode.
8. **Bisection harness** — automate "boot at state X, check, repeat" so the commit range can be narrowed mechanically.
9. **Differential loop** — run the same input through old-version vs new-version and diff outputs.

**Tighten the Loop**

Once you have a loop, **tighten** it:

- Make it faster (cache setup, narrow scope).
- Sharpen the signal (assert on the specific symptom, not "didn't crash").
- Make it deterministic (pin time, seed randomness, isolate filesystem).

A 30-second flaky loop is barely better than no loop; a 2-second deterministic one is a debugging superpower.

**Non-Deterministic Bugs**

The goal is not a clean reproduction but a **higher reproduction rate**. Loop the trigger many times, add stress, narrow timing windows. A 50%-flake bug is debuggable; 1% is not — keep raising the rate.

**Phase 1 Completion — a Tight, Red-Capable Loop**

Phase 1 is done when you can name **one command** that you have already run, and that is:

- **Red-capable** — drives the actual bug code path and asserts the user's exact symptom.
- **Deterministic** — same verdict every run (or a pinned, high reproduction rate for flakes).
- **Fast** — seconds, not minutes.
- **Runnable unattended** — no human in the loop required.

**Phase 2 — Reproduce and Minimise**

Run the loop. Confirm the failure matches what the user described — wrong symptom = wrong fix. Then **minimise**: shrink the reproduction to the smallest scenario that still goes red. Cut inputs, callers, config, and data one at a time, re-running the loop after each cut. Stop when every remaining element is load-bearing — removing any one makes the loop green.

**Phase 3 — Hypothesise**

Generate **3–5 ranked hypotheses** before testing any. Each must be **falsifiable**:

> Format: "If \<X\> is the cause, then changing \<Y\> will make the bug disappear."

Show the ranked list before testing; domain knowledge can re-rank instantly.

**Phase 4 — Instrument**

Each probe must map to a specific prediction from Phase 3. Prefer a debugger breakpoint over ten log statements. Tag every temporary log with a unique prefix (e.g., `[DBG-a4f2]`) so cleanup is a single search. For performance regressions, measure first — establish a baseline, then bisect.

When the reproduction loop is **human-mediated** (full-stack apps requiring manual interaction), batch all hypothesis probes in a single instrumentation pass — each reproduction costs minutes of human time. Output a capture command the user runs to collect tagged output into a file the agent can read (e.g., `go run ./cmd/server 2>&1 | tee ./tmp/debug-session.log`). Change one variable at a time only when the feedback loop is unattended.

**Phase 5 — Fix and Regression Test**

If no correct seam exists, that itself is the finding — the architecture prevents the bug from being locked down. Note it for the post-mortem.

If a correct seam exists: turn the minimised repro into a failing test → watch it fail → apply the fix → watch it pass → re-run the Phase 1 loop against the original scenario.
</execution_protocol>

<pre_flight_check>
Before declaring done:

- Re-run the Phase 1 loop — original scenario no longer reproduces.
- Regression test passes (or absence of seam is documented).
- All temporary instrumentation removed.
- Throwaway harnesses deleted or moved to a clearly marked location.
- The hypothesis that was correct is stated in the commit message.

Then ask: what would have prevented this bug? If the answer is architectural (no good test seam, tangled coupling), note it for a future improvement — you have more information now than when you started.
</pre_flight_check>
