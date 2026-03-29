---
name: code-review
description: Use when explicitly asked to review a git branch, Pull Request (PR), Merge Request (MR), or perform a pre-merge review. Do not use for inline code critiques.
license: MIT
---

# Code Review

Perform comprehensive code reviews of a branch against the base branch, providing actionable feedback on code quality, security, performance, and best practices.

## When to Use This Skill

Activate this skill when:

- The user types "review" or "code review"
- The user types "review BRANCH-NAME" to review a specific branch
- The user asks to review a branch, pull request, or merge request
- Analyzing code changes before merging
- Performing code quality assessments
- Checking for security vulnerabilities or performance issues
- Reviewing branch diffs

**Two Review Modes:**

1. **Current Branch Review** (default when no branch specified)
   - Reviews all changes in current branch (committed + uncommitted)
   - Includes staged and unstaged changes
   - Runs automated checks (linters, formatters, tests)

2. **Other Branch Review** (when branch name specified)
   - Uses git worktree for non-disruptive review
   - Reviews only committed changes from that branch
   - Leaves your current work untouched

## Branch Selection

### Branch Name Provided

**If a branch name is provided** (e.g., "review feature/payment"):

1. Fetch latest from origin: `git fetch origin`
2. Set up a git worktree for the branch (see Worktree Setup below)
3. Proceed with the review in the worktree
4. Clean up the worktree after review is complete

### No Branch Specified (Current Branch)

**If no branch name is provided** (e.g., just "review"):

1. Review the current branch as-is in the current directory
2. **Include uncommitted changes**:
   - Staged changes: `git diff --cached`
   - Unstaged changes: `git diff`
3. **Run automated quality checks** (linters, formatters, tests)
4. Do not create a worktree or switch branches

### Worktree Setup for Non-Disruptive Reviews

When reviewing a branch that isn't the current branch, use a git worktree to avoid disturbing the current working state:

1. Create a worktree directory at `<repo-root>/.worktrees/<branch-name>`:

   ```bash
   git worktree add .worktrees/<branch-name> origin/<branch-name>
   ```

2. Perform all review operations within the worktree directory
3. After the review is complete, remove the worktree:

   ```bash
   git worktree remove .worktrees/<branch-name>
   ```

**Important**: Always use the worktree path when reading files or running git commands during the review.

### Dependency Installation in Worktrees

When setting up a worktree, install dependencies if you need to run checks (tests, type checking, linting):

1. **Detect package manager**: Check for `pnpm-lock.yaml`, `Cargo.lock`, `go.mod`
2. **Install dependencies**:

   ```bash
   cd <worktree-path> && pnpm install
   ```

3. **Run checks** (optional, if needed for thorough review)

**When to install dependencies:**

- When you need to run tests, type checking, or linting
- When reviewing changes that affect build or compilation

**When to skip dependency installation:**

- Simple reviews that only need to examine diffs

### Worktree Error Handling

**If the worktree already exists:**

```bash
git worktree remove .worktrees/<branch-name> --force 2>/dev/null || true
git worktree add .worktrees/<branch-name> origin/<branch-name>
```

**If no matching branch is found:**

- Inform the user that no branch was found
- List available branches that might be related (partial matches)

**Always clean up worktrees:**

- Even if the review encounters errors, attempt to clean up the worktree
- Use `git worktree list` to verify cleanup was successful

### .gitignore Recommendation

The `.worktrees` directory should be added to `.gitignore`.

## Analyze Branch Context

First, gather essential information about the branch to review:

- Identify the current branch name (or worktree branch)
- Determine the appropriate base branch (main or master)
- Check for any uncommitted changes (current branch only)
- **Find the merge-base** to isolate only commits made in this branch
- Get the list of commits and changed files

### Detect Default Branch (Use Ancestry)

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

### Finding Branch-Specific Changes (CRITICAL)

**You MUST use `git merge-base` to find the common ancestor.** This ensures you only review commits that were made in THIS branch.

```bash
MERGE_BASE=$(git merge-base origin/$DEFAULT_BRANCH HEAD)
git log --oneline $MERGE_BASE..HEAD
git diff --name-status $MERGE_BASE..HEAD
git diff $MERGE_BASE..HEAD
```

**Why this matters:**

- `git diff origin/main..HEAD` shows ALL differences between main and HEAD, including changes from OTHER branches
- `git diff $(git merge-base origin/main HEAD)..HEAD` shows ONLY the changes introduced in THIS branch

**Always use the merge-base approach for:**

- `git log` - to list commits
- `git diff` - to see changes
- `git diff --stat` - for change statistics

### Uncommitted Changes (Current Branch Only)

```bash
git diff --cached --name-status
git diff --cached --stat
git diff --name-status
git diff --stat
```

### Exclude Lock Files

Do not review lock files. Filter them out:

- `pnpm-lock.yaml`
- `package-lock.json`
- `yarn.lock`
- `bun.lockb`
- `go.sum`
- `Cargo.lock`
- `poetry.lock`
- `Pipfile.lock`
- `pdm.lock`
- `Gemfile.lock`
- `composer.lock`
- `deno.lock`
- `flake.lock`

### Large Diff Confirmation

If diff is very large, ask for confirmation before proceeding:

- **Files > 100** or **Lines > 5000**

## Run Automated Quality Checks

**Current branch**: Always run checks.
**Worktree**: Ask the user before running checks.

Run the bundled check script. It auto-detects the project type (Nx, Rust, Go, Node.js) and runs the appropriate linters, formatters, and tests with a 5-minute timeout per check. Failures are reported but do not stop the review.

```bash
.github/skills/code-review/run-checks.sh "$MERGE_BASE" [WORKTREE_PATH]
```

Capture the output and include results in the review report.

## Perform Comprehensive Code Review

Conduct a thorough review of **only the changes introduced in this branch**.

### 1. Change Analysis

- Use `git diff $(git merge-base origin/$DEFAULT_BRANCH HEAD)..HEAD -- <file>` to review each modified file
- Examine commits using `git show <commit-hash>`
- Identify patterns across changes
- Check for consistency with existing codebase

### 2. Code Quality Assessment

- Code style and formatting consistency
- Variable and function naming conventions
- Code organization and structure
- Adherence to DRY principles

### 3. Technical Review

- Logic correctness and edge cases
- Error handling and validation
- Performance implications
- Security considerations

### 4. Best Practices Check

- Design patterns usage
- SOLID principles adherence
- Testing coverage implications

## Generate Review Report

Create a structured code review report with:

1. **Executive Summary**: High-level overview of changes
2. **Statistics**: Files changed, lines added/removed, commits reviewed
3. **Automated Check Results**: Format/lint/test results
4. **Strengths**: What was done well
5. **Issues by Priority**: Critical / Important / Suggestions
6. **Security Review**: Specific security considerations
7. **Testing Recommendations**: What tests should be added

## User Interaction

After completing the review:

1. Display the complete review report in markdown format
2. Provide actionable next steps based on findings

## Feedback Style: Questions, Not Directives

**Frame all feedback as questions, not commands.**

❌ **Don't write:**
- "You should use early returns here"

✅ **Do write:**
- "Could this be simplified with an early return?"
