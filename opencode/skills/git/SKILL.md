---
name: git
description: Auto-apply when the user asks for any git version control operation — commit, branch, merge, rebase, and recovery workflows.
---

# Git Master (Safe Mode)

<red_lines>
**Security Protocol**

1. **NEVER EXECUTE** write commands (commit, push, rebase, reset, branch deletion).
2. **ONLY EXECUTE** read-only commands (`status`, `log`, `diff`, `branch --list`, `stash list`).
3. **ALWAYS OUTPUT** write commands in bash code blocks for the user to copy-paste and run manually.

**Safety Rules**

- **Never force-push to main/master.** Period.
- **Never commit secrets**, credentials, API keys, `.env` files, or private keys — even temporarily.
- **Never amend commits** that have been pushed to remote.
- **Verify tests pass** before creating a commit.
- **Review the diff** before committing — no accidental files, no debug statements.
- All write and recovery commands below are **output only** — present them for the user to review and run manually.
- `git reset --hard` and `git push -f` are destructive. Always warn the user before outputting these commands.
</red_lines>

<standards>
**Conventional Commits**

- **Commit Format:** `<type>(<scope>): <description>`
- **Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`.
- **Scope** is optional but encouraged for monorepos.
- **Description** is imperative mood, lowercase, no period: `feat(auth): add JWT refresh token rotation`

**Branch Strategy**

- **Branch Format:** `<type>/<kebab-case-description>` (e.g., `feat/auth-login` or `fix/jwt-expiry`).
- Keep branches short-lived — merge within days, not weeks.
- Rebase feature branches on main before merging to maintain linear history.

**Atomic Commits**

- One logical change per commit. Don't mix refactoring with feature work.
- Each commit should leave the codebase in a compilable, testable state.
- If a change requires multiple steps, each step gets its own commit.

**Pull Requests**

- Title follows conventional commit format.
- Description includes: summary (1-3 bullets), what changed, how to test.
- Link related issues.
- Keep PRs focused — one feature or fix per PR.
</standards>

<execution_protocol>
**Workflows** (all write commands are output only)

- **Commit:** Analyze `git diff` → output `git commit -m "type(scope): description"` for user.
- **Push:** Output `git push -u origin <branch>` for user.
- **Sync:** Output `git fetch origin && git rebase origin/main` for user.
- **Squash:**
  1. Identify count $N$ from `git log`.
  2. Output `git rebase -i HEAD~N` for user.
  3. **Instruct:** "Change `pick` to `squash` (or `s`) for the bottom $N-1$ commits."

**Recovery: "Wrong Push"**

Identify if the branch is **Public** (shared/main) or **Private** (feature).

**A. Public (Safe / No Force Push)**

Output these commands for the user:

```bash
# 1. Undo on wrong branch
git checkout wrong && git revert <hashes> && git push
# 2. Move to right branch
git checkout right && git cherry-pick <hashes> && git push
```

**B. Private (Clean / Force Push OK)**

Output these commands for the user:

```bash
# 1. Copy commits to correct branch
git checkout right && git cherry-pick <hashes>
# 2. Reset wrong branch (DESTRUCTIVE — user must confirm)
git checkout wrong && git reset --hard <good-hash> && git push -f
```

**C. Local/Recent ("Soft Reset")**

Output these commands for the user:

```bash
git reset --soft HEAD~N
git checkout right
git commit
```

</execution_protocol>
