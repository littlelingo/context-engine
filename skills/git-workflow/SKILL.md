---
description: Git workflow conventions - branching, commits, PRs, rebasing. Auto-loaded when working with git operations, merge conflicts, or PR-related files.
---

# Git Workflow

## Branching
- `feat/[name]` for features, `fix/[name]` for bugs, `refactor/[scope]` for restructuring
- Never commit directly to `main`/`master`
- Keep branches short-lived - merge or rebase within days, not weeks

## Commits
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Subject < 72 chars, imperative mood ("add" not "added")
- Body: what and why, not how (the diff shows how)
- Reference PRP path in footer when implementing features

## Pull Requests
- Use `gh pr create` (GitHub) or `glab mr create` (GitLab)
- PR title matches commit subject
- Description includes: summary, changes list, testing done, security notes
- Link to PRP: `.context/features/[NNN]-[name]/PRP.md`

## Rebasing
- Prefer rebase over merge for feature branches (linear history)
- `git rebase -i main` to squash WIP commits before PR
- Never rebase shared/published branches

## Conflict Resolution
- Always pull latest main before starting work
- When resolving conflicts: understand both sides before choosing
- Run full test suite after every conflict resolution
- If conflict is complex, ask before resolving

## Common Operations
```bash
# Start feature
git checkout -b feat/[name] main

# Sync with main
git fetch origin && git rebase origin/main

# Interactive squash before PR
git rebase -i main

# Create PR
gh pr create --title "feat: [description]" --body "[PR body]"

# Clean up after merge
git checkout main && git pull && git branch -d feat/[name]
```
