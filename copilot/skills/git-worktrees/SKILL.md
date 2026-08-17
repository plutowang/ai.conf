---
name: git-worktrees
description: Load before starting implementation to decide whether an isolated workspace is needed. Most of the time it is not — verify first, create only as a last resort.
---

# Git Worktrees: Isolated Workspaces

Announce at the start: "I'm using the git-worktrees skill to check whether an isolated workspace is needed."

<red_lines>

- A worktree is an escape hatch for one situation only: implementation is about to start **on the default branch**. In every other case you already have a valid workspace and must use it.
- **Never start implementation on `main`/`master` without explicit human consent.**
- Never delete a workspace containing uncommitted work without explicit confirmation.
- Skip worktree creation entirely if ANY of these hold: you are already inside a linked worktree (rung 1); you are inside a submodule — treat it as a normal repository (rung 2); you are already on a non-default branch — build directly on it, do NOT create a worktree unless the human explicitly asks for one; the human declined isolation — work in place.
</red_lines>

<execution_protocol>
**Detection Ladder (run in order, stop at the first match)**

Run each check and stop as soon as one matches. Do not skip ahead.

1. **Already isolated?**

   ```bash
   [ "$(git rev-parse --git-dir)" != "$(git rev-parse --git-common-dir)" ] && echo ISOLATED
   ```

   Prints `ISOLATED` → you are already in a linked worktree. **Skip creation. Work here.**

2. **In a submodule?**

   ```bash
   git rev-parse --show-superproject-working-tree
   ```

   Non-empty output → treat this as a normal repository. **Skip creation. Work here.**

3. **Already on a working branch?**

   ```bash
   git rev-parse --abbrev-ref HEAD
   ```

   Anything other than `main` or `master` → **build directly on this branch. Skip creation.**

4. **On the default branch** → ask the human for consent before creating anything. If they decline, work in place.

**Creating a Worktree (rung 4 only)**

Verify the target path is ignored before creating it, so the worktree never becomes tracked content:

```bash
git check-ignore -q .worktrees && git worktree add .worktrees/<feature-name> -b <branch-name> main
```

If `.worktrees` is not ignored, add it to `.gitignore` first, then retry. After creation, work inside the new directory for everything that follows.

**Finishing**

When implementation is complete, present the human with three options and wait for a choice:

1. **Merge locally** — integrate into the base branch from here.
2. **Push and open a pull request** — leave integration to review.
3. **Leave as-is** — keep the branch and workspace for later.

Only after the choice is made, and only if the worktree lives under `.worktrees/`, offer to remove it:

```bash
git worktree remove .worktrees/<feature-name>
```

</execution_protocol>
