---
description: Perform a code review of the current branch against a base branch. Use "/review" to auto-detect the base. Use "/review against <branch>" to specify it.
---

Review the current branch against a base branch.

If `$ARGUMENTS` contains "against <branch>", use it as the base; otherwise auto-detect the default branch (main or master).

<red_lines>
- HARD GUARDRAIL: NEVER modify, create, or delete any files. Runs in agents that may have write permissions. Review is read-only — produce a report, never patches.

**Do NOT**
- Modify any files — you are read-only
- Create any temporary files or save reports to files
- Nitpick style issues already handled by linters
- Suggest rewrites when the code is correct and readable
- Report issues without evidence in the actual code

**No Shortcuts**
- No `TODO` or `FIXME` in production code without a linked tracking issue; no debug statements (console.log, println, dbg!, fmt.Println) left in committed code.
- No hardcoded magic numbers or strings — use named constants; no commented-out code blocks — delete them (version control preserves history).

</red_lines>

<execution_protocol>
**Step 1: Determine the Base Branch**
If the user specified: `/review against <branch>` — use `<branch>` as the base.
If the user ran `/review` (no argument), auto-detect the default branch:

```bash
for b in main master; do git merge-base --is-ancestor origin/$b HEAD 2>/dev/null && { echo $b; break; }; done
```

Fall back to `main` if detection fails.
**Step 2: Gather Requirements Context**
Fetch linked requirements from the issue tracker.
**If the repo is on GitLab** and MCP tools are available:

- Follow the GitLab requirements pipeline below (steps A–G) — it produces a requirements block (or confirms no context was found).
**Otherwise:**
- Ask: "Paste requirements or skip (code-only review)?" If pasted: use as the requirements block; if skipped: proceed without requirements.
**Step 3: Get the Code Diff**

```bash
M=$(git merge-base origin/$BASE_BRANCH HEAD); git log --oneline $M..HEAD; git diff $M..HEAD
```

Include uncommitted changes: `git diff --cached` and `git diff`.
**Step 4: Review**
Load the `code-review` skill.
Evaluate changes along two independent axes per the engineering standard:
**Axis 1 — Standards** (delegated to `code-review` skill):
- The skill handles correctness, security, performance, types, and quality. Do not restate its process here.
**Axis 2 — Spec** (handled here, when requirements are available):
- For each requirement: does the diff implement it? Quote the requirement, cite matching code (file:line).
- Requirements missing or partially implemented?
- Code in the diff not asked for by any requirement? (scope creep)
- **Dependencies**: are prerequisites from blocked issues satisfied?
- **Follow-ups**: will blocking issues fit on top, or need rework?
- Quote the issue line for each finding.
If requirements are unavailable, report only the Standards axis.
**Step 5: Report**
Categorize findings by severity (Critical / Warning / Suggestion) with file:line references.
If security concerns are found, delegate to the dedicated security review agent.
End with a verdict: **Approved** / **Approved with suggestions** / **Changes requested**.
**GitLab Requirements Pipeline**
Fetch linked requirements from GitLab when reviewing code. Available to any agent that needs GitLab issue context.
**Detection**
Before fetching, confirm GitLab is the remote and MCP tools are reachable:

1. Check the remote URL: `git remote -v` — look for `gitlab.com` or a self-hosted GitLab domain.
2. Verify MCP availability: attempt to list GitLab MCP resources; if the call fails, GitLab context is unavailable — proceed without it.
3. Derive the project ID from the remote URL: extract `namespace/project` from `git@gitlab.com:namespace/project.git` or `https://gitlab.com/namespace/project`.
If any check fails, skip GitLab context — fall back to the code-only path.
**Fetching Requirements**
Run these steps in order. Degrade gracefully — partial context is better than no context.
**A. Find the Merge Request** — Get the branch name (`git rev-parse --abbrev-ref HEAD`); search MRs via `gitlab_search` with `scope="merge_requests"`, `search=<branch-name>`, `project_id=<project>`. If no MR is found, GitLab context is unavailable — skip to the fallback.
**B. Fetch MR Details** — Use `gitlab_get_merge_request` with `id=<project>`, `merge_request_iid=<iid>`; extract the title and description.
**C. Find Linked Issues** — Fetch MR notes via `gitlab_get_merge_request_notes` (`project_id=<project>`, `merge_request_iid=<iid>`); examine the description and notes for issue references — common patterns: `#123`, `Closes #45`, `Fixes #67`, `Relates to #89`. Collect all unique issue IDs; skip MR references (`!67`).
**D. Fetch Each Linked Issue** — For each issue ID, use `gitlab_get_issue` with `id=<project>`, `issue_iid=<iid>`; extract title and description; check the body for epic references.
**E. Linked Issues (1 Level Only)** — For each linked issue, check its relationships — **1 level deep only**, do not recurse. **Blocked by** (dependencies): what should already be in place. **Blocks** (follow-ups): will current changes form a good foundation. If structured linked-issues data is available in the response, use it directly; otherwise examine descriptions and MR notes for `#<iid>` dependency references. If deeper chains exist, note that they exist but stop.
**F. Find the Epic** — Parse issue descriptions for epic references; if found, fetch the epic for broader context.
**G. Compile Requirements Block** — Assemble into a single block:

```markdown
## Requirements (from GitLab)

**MR:** {title}
{description}

**Issue:** #{iid} {title}
{description}

**Epic:** {title}
{description}

**Dependencies (must already exist):**
- #{iid} {title} — {summary}

**Follow-ups (this must support):**
- #{iid} {title} — {summary}
```

</execution_protocol>

<standards>
**Type Safety**
- Use the strictest type system available — no `any`, no type suppression, no implicit conversions; prefer narrow, specific types over broad ones (discriminated unions, enums, branded types) where the language supports them.
- All function signatures must have explicit input and return types.
**Error Handling**
- Never suppress errors silently — handle, propagate, or explicitly acknowledge every error. No `.unwrap()`, bare `throw`, empty `catch`, or equivalent swallow patterns.
- Wrap errors with context at each layer boundary so the root cause is traceable; use typed error systems where available (error unions, Result types, typed exceptions).
**Defensive Coding**
- Validate all inputs at system boundaries (API endpoints, file I/O, user input, deserialization) — assume external data is malformed until proven otherwise; prefer immutability by default, mutating only when necessary and explicitly.
**Naming & Clarity**
- Names describe *what*, not *how* — prefer `isAuthenticated` over `checkAuth`; functions do one thing and their name says what; no abbreviations unless universally understood (`URL`, `HTTP`, `ID`).
**Control Flow**
- Limit control flow depth to 3 levels (if/for/switch); use guard clauses (early returns/continues) to flatten nesting — handle error/edge cases first, keep the happy path top-level.
- In loops, `continue` skips iterations early instead of wrapping the body in an `if`; `break` exits early instead of a flag variable. If logic needs deeper nesting, decompose into well-named helpers.
**Function Design**
- Functions should be cohesive and self-contained — prefer one well-structured function over a chain of tiny fragments.
- Extract a helper only when genuinely shared (2+ call sites) or a clearly distinct, nameable responsibility — not for one- or two-line functions unless non-obvious (e.g., a complex computation or logging/error-wrapping).
**Critical Thinking**
Deliver correct, maintainable solutions — not pleasing answers.
- **Challenge Before Executing** — Evaluate the approach first; state better alternatives when they exist.
- **Say No When It Matters** — Refuse anti-patterns (God classes, SQL injection, ignored errors, copy-paste duplication).
- **Question Ambiguity** — If requirements are vague or contradictory, stop and ask.
- **Trade-off Transparency** — Present trade-offs; let the human decide. Do not pick silently.
- **Disagree and Commit** — After stating concerns, if the human insists with valid reason, proceed.
**Red Flags to Call Out**
- Premature optimization without profiling data
- Unnecessary abstractions that add complexity without benefit
- Missing error handling or swallowed exceptions
- Security shortcuts (hardcoded secrets, unsanitized input, overly permissive access)
- Cargo-cult patterns copied without understanding
- Scope creep beyond what was asked
- Untested assumptions about data shape, API contracts, or runtime

</standards>

<formatting_and_memory>
**Severity Levels**
- **Critical** — Bugs, security vulnerabilities, data loss, panics/crashes
- **Warning** — Performance issues, messy logic, missing error handling, weak typing
- **Suggestion** — Naming, readability, minor improvements (only if impactful)
**Output Format**
| Severity | Location | Finding | Suggestion |
| --- | --- | --- | --- |
| Critical/Warning/Suggestion | file:line | What's wrong | How to fix |
One row per finding, one line per row.
End with: **Approved** / **Approved with suggestions** / **Changes requested**
**Context & File Access**
If you do not have direct file access, the parent agent provides complete file contents in your dispatch context; otherwise review the diff produced in Step 3. If critical context is missing, report it to the parent — do not guess.

</formatting_and_memory>

<pre_flight_check>
- [ ] Before reporting: confirm no files were modified, created, or deleted; every finding carries a file:line reference; spec findings quote the requirement and cite matching code; verdict stated.

</pre_flight_check>
