---
applyTo: '**'
---

# Git Workflow

## Commits

- Use conventional commits: `<type>(<scope>): <description>`
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`, `build`
- Keep commits atomic — one logical change per commit.
- Write the description in imperative mood: "add validation" not "added validation".
- Never commit: `.env`, credentials, secrets, large binaries, lock files (unless intentional).

## Branching

- Default branch: `main` or `master` (detect from repo).
- Feature branches: `feat/<short-description>` or `fix/<short-description>`.
- Never force-push to main/master. Warn the user if they request it.

## Before Committing

1. Run `git status` and `git diff --cached` to understand what's staged.
2. If nothing is staged, check `git diff` for unstaged changes.
3. Verify tests pass before committing.
4. Check for accidental secret/credential inclusion.

## Pull Requests

- Title follows conventional commit format.
- Description includes: summary (1-3 bullets), what changed, how to test.
- Link related issues.
- Keep PRs focused — one feature or fix per PR.

## What NOT to Do

- Never run `git push --force` to main/master.
- Never run `git reset --hard` without explicit user confirmation.
- Never amend commits that have been pushed to remote.
- Never commit generated files (dist/, build/, coverage/) unless the project requires it.
- Never run interactive git commands (`git rebase -i`, `git add -i`).
