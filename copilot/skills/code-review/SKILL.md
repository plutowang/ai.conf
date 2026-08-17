---
name: code-review
description: Use when asked to review a branch, Pull Request (PR), Merge Request (MR), inline code snippet, or perform a pre-merge review. Covers full branch reviews and lightweight snippet critique.
license: MIT
---

# Code Review

Perform comprehensive code reviews of a branch against the base branch, providing actionable feedback on code quality, security, performance, and best practices.

<red_lines>

- NEVER review lock files. Filter them out: `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, `bun.lockb`, `go.sum`, `Cargo.lock`, `poetry.lock`, `Pipfile.lock`, `pdm.lock`, `Gemfile.lock`, `composer.lock`, `deno.lock`, `flake.lock`.
- Snippet mode: NEVER review the full branch — this mode is for the provided snippet only.
- ONLY comment on code that was changed in THIS branch's commits or uncommitted work.
- NEVER provide a corrected example unless requested.
- Frame ALL feedback as questions, not commands.
- If the diff is very large — files > 100 or lines > 5000 — ask for confirmation before proceeding.
- Worktree mode: NEVER run automated checks without asking the user first (may require installing dependencies).
- Current-branch mode: NEVER create a worktree or switch branches.
</red_lines>

<execution_protocol>
Activate this skill when: the user types "review", "code review", "critique", or "analyze"; types "review BRANCH-NAME" to review a specific branch; asks to review a specific code snippet, function, or file; asks to review a branch, pull request, or merge request; analyzing code changes before merging; performing code quality assessments; checking for security vulnerabilities or performance issues; reviewing branch diffs.

**Three review modes:**

1. **Snippet Review** — review a specific code block or snippet for bugs, security issues, and code quality.
2. **Current Branch Review** (default when no branch specified) — reviews all changes in current branch (committed + uncommitted), includes staged and unstaged changes, runs automated checks (linters, formatters, tests).
3. **Other Branch Review** (when branch name specified) — uses git worktree for non-disruptive review, reviews only committed changes from that branch, leaves your current work untouched.

**Snippet mode focus:** Security (injections, exposed secrets, unsanitized input); Performance (O(n²) loops, memory leaks, unoptimized queries); Types (strict typing, no `any`, correct error handling); Logic (edge cases, off-by-one errors, incorrect assumptions).

**Finding tiers:** 🔴 **Critical** — bugs, security vulnerabilities, panics. 🟡 **Warning** — performance issues, messy logic, missing error handling. 🟢 **Suggestion** — naming, formatting, style improvements.

For each finding: file:line reference + question framing (see Feedback style below); corrected example only if requested.

**Branch selection:**

- Branch name provided: use `skill git-worktrees` for isolated workspace setup. Fetch latest, create the worktree, and perform all review operations within it. Clean up the worktree after the review.
- No branch specified (current branch): include uncommitted changes — staged: `git diff --cached`; unstaged: `git diff`. Run automated quality checks (linters, formatters, tests). Do not create a worktree or switch branches.

**Analyze branch context:** identify the current branch name (or worktree branch); determine the appropriate base branch (main or master); check for any uncommitted changes (current branch only); find the merge-base to isolate only commits made in this branch; get the list of commits and changed files.

**Detect default branch (use ancestry):**

```bash
DEFAULT_BRANCH=""

for branch in main master; do
  if git merge-base --is-ancestor origin/$branch HEAD 2>/dev/null; then
    DEFAULT_BRANCH=$branch
    break
  fi
done

if [ -z "$DEFAULT_BRANCH" ]; then
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
fi

if [ -z "$DEFAULT_BRANCH" ]; then
  if git show-ref --verify --quiet refs/remotes/origin/main; then
    DEFAULT_BRANCH="main"
  elif git show-ref --verify --quiet refs/remotes/origin/master; then
    DEFAULT_BRANCH="master"
  fi
fi

[ -z "$DEFAULT_BRANCH" ] && DEFAULT_BRANCH="main"
```

**Finding branch-specific changes (CRITICAL):** you MUST use `git merge-base` to find the common ancestor. This ensures you only review commits that were made in THIS branch, not commits from other branches that happened to be merged into main.

```bash
MERGE_BASE=$(git merge-base origin/$DEFAULT_BRANCH HEAD)
git log --oneline $MERGE_BASE..HEAD
git diff --name-status $MERGE_BASE..HEAD
git diff $MERGE_BASE..HEAD
```

Why this matters: `git diff origin/main..HEAD` shows ALL differences between main and HEAD, including changes from OTHER branches merged into main after this branch was created; `git diff $(git merge-base origin/main HEAD)..HEAD` shows ONLY the changes introduced in THIS branch. Always use the merge-base approach for: `git log` (list commits), `git diff` (see changes), `git diff --stat` (change statistics), `git diff --name-status` (file list).

**Uncommitted changes (current branch only):**

```bash
git diff --cached --name-status
git diff --cached --stat
git diff --name-status
git diff --stat
```

**Run automated quality checks:** current branch — always run; worktree — ask the user before running (may require installing dependencies). Auto-detect project type and run appropriate checks. Use `gtimeout` or `timeout` with a 5-minute limit per check. Failures are reported but do not stop the review.

**Detect project type:**

```bash
# Detect in order of specificity
if [ -f "nx.json" ]; then
  PROJECT_TYPE="nx"
elif [ -f "Cargo.toml" ]; then
  PROJECT_TYPE="rust"
elif [ -f "go.mod" ]; then
  PROJECT_TYPE="go"
elif [ -f "package.json" ]; then
  PROJECT_TYPE="node"
else
  PROJECT_TYPE="unknown"
fi
```

**Run checks by type:**

```bash
# Nx (Node.js/TypeScript monorepo)
pnpm nx run-many --target=lint --target=test --parallel=2

# Rust
cargo clippy --all-targets --all-features -- -D warnings
cargo check --all
cargo fmt --check --all
cargo test

# Go
go vet ./...
go test -v ./...

# Node.js (pnpm)
pnpm lint
pnpm test

# Node.js (npm/yarn fallback)
npm run lint 2>/dev/null || yarn lint 2>/dev/null
npm test 2>/dev/null || yarn test 2>/dev/null
```

Capture output and include results in the review report.

**Perform comprehensive code review** — review ONLY the changes introduced in this branch (using merge-base as described above):

1. **Change Analysis** — use `git diff $(git merge-base origin/$DEFAULT_BRANCH HEAD)..HEAD -- <file>` to review each modified file; if reviewing current branch, also review `git diff --cached` and `git diff`; examine commits using `git show <commit-hash>` for individual commits in the branch; identify patterns across changes; check for consistency with existing codebase.
2. **Code Quality** — code style and formatting consistency; variable and function naming conventions; code organization and structure; adherence to DRY; proper abstraction levels.
3. **Technical Review** — logic correctness and edge cases; error handling and validation; performance implications; security considerations (input validation, SQL injection, XSS, etc.); resource management (memory leaks, connection handling); concurrency issues if applicable.
4. **Best Practices** — design patterns usage; SOLID principles adherence; testing coverage implications; documentation completeness; API consistency; backwards compatibility.
5. **Dependencies and Integration** — new dependencies added; breaking changes to existing interfaces; impact on other parts of the system; database migration requirements.

**Feedback style: questions, not directives.** Frame all feedback as questions, not commands — this encourages dialogue and respects the author's context.

- ❌ Don't write: "You should use early returns here"; "This needs error handling"; "Extract this into a separate function"; "Add a null check".
- ✅ Do write: "Could this be simplified with an early return?"; "What happens if this API call fails? Would error handling help here?"; "Would it make sense to extract this into its own function for reusability?"; "Is there a scenario where this could be null? If so, how should we handle it?"
- Why questions work better: the author may have context you don't have; questions invite explanation rather than defensiveness; they acknowledge uncertainty in the reviewer's understanding; they create a conversation rather than a checklist.
</execution_protocol>

<formatting_and_memory>
Create a structured code review report with:

1. **Executive Summary** — high-level overview of changes and overall assessment
2. **Statistics** — files changed, lines added/removed; commits reviewed; uncommitted changes status (current branch only); critical issues found
3. **Automated Check Results** — format check ✅ Passed / ❌ Failed; linter ✅ Passed / ⚠️ Warnings / ❌ Errors; tests ✅ Passed / ❌ Failed; brief summary of failures
4. **Strengths** — what was done well
5. **Issues by Priority** (vocabulary matches the code review standards: Critical / Warning / Suggestion) — 🔴 must fix before merging (bugs, security issues, failed checks); 🟡 should address (performance, maintainability); 🟢 nice to have improvements
6. **Detailed Findings** — for each issue: file:line reference; question framing ("Could this cause X?"); why you're asking; code example if helpful
7. **Security Review** — specific security considerations
8. **Performance Review** — performance implications
9. **Testing Recommendations** — what tests should be added
10. **Documentation Needs** — what documentation should be updated

**Report output:** display the complete review report in markdown format; save report to `docs/reviews/CODE_REVIEW_[YYYY-MM-DD_HH-MM-SS].md` in repo root (example filename: `CODE_REVIEW_2026-01-27_14-30-22.md`).
</formatting_and_memory>

<pre_flight_check>

- Before finishing: confirm no lock files were reviewed, no comments on out-of-branch code, all feedback is question-framed, large-diff confirmation was obtained when needed, worktree was cleaned up after branch review, and the report was saved to `docs/reviews/CODE_REVIEW_*.md` — then display the complete report, provide actionable next steps based on findings, and highlight critical issues prominently.
</pre_flight_check>
