---
title: Git Standards
description: Branch naming, commit messages, MR creation, and safety practices
tags: [git, workflow, version-control]
last_updated: 2026-07-26
---

# Git Standards

## Branch Naming

Include ticket reference and type:
```
feature/TICKET-123-short-description
fix/TICKET-456-bug-description
hotfix/TICKET-789-urgent-fix
chore/TICKET-012-maintenance
```

**Important:** Some CI systems require slashes (`feature/` not `feature-`) for pattern matching on test/deploy rules.

## Commit Messages

### Format

```
type: TICKET-123: short description

Optional body with more context.
```

### Conventional Commits & Semantic Versioning

All commits should follow [Conventional Commits](https://www.conventionalcommits.org/) to enable automated semantic versioning. The commit type directly determines the version bump:

- `fix:` → **patch** bump (1.0.0 → 1.0.1)
- `feat:` / `feature:` → **minor** bump (1.0.0 → 1.1.0)
- `BREAKING CHANGE:` in body or `!` after type → **major** bump (1.0.0 → 2.0.0)

Repos should follow [Semantic Versioning (semver)](https://semver.org/): `MAJOR.MINOR.PATCH`.

### Types
- `feature:` — new functionality (note: some systems use `feat:`, verify your semantic-release config)
- `fix:` — bug fix
- `chore:` — maintenance, deps, CI changes
- `docs:` — documentation only

### Semantic Release Variant

Some semantic-release configurations use `feature:` instead of `feat:`. Using the wrong prefix means **no version bump happens**. Always verify which convention your project uses.

### Squash Merge Consideration

When GitLab/GitHub squash-merges, the commit message becomes the MR title. If the title lacks the right prefix, semantic release skips the bump. Set MR titles with the correct prefix.

## MR/PR Creation

### Always Include
- Meaningful description (never blank)
- Squash on merge
- Remove source branch after merge
- Assign yourself

### CLI Templates

```bash
# GitLab
glab mr create \
  --source-branch feature/TICKET-123-desc \
  --target-branch main \
  --title "feature: TICKET-123: description" \
  --squash-before-merge \
  --remove-source-branch \
  --no-editor

# GitHub
gh pr create \
  --title "feat: TICKET-123: description" \
  --base main
```

For multiline descriptions, create the MR first then update:
```bash
glab mr update <id> --description "$(cat description.md)"
```

## Git Safety

### Never Without Explicit Permission
- `git push --force` to shared branches
- `git reset --hard` (destructive)
- `git clean -f` (irreversible)
- `git branch -D` (uppercase D = force delete)

### Best Practices
- **Prefer new commits over `--amend`** — only amend your own unpushed commits
- **Stage specific files** (`git add file.tf`) over `git add .`
- **Preserve hooks** — don't skip with `--no-verify` unless hooks are genuinely broken
- **Non-interactive commands** — avoid `-i` flags in automated contexts
- **Check for secrets** before committing (.env, credentials.json, tokens)

## Release Tagging

```bash
# Annotated tag (includes author, date, message)
git tag -a 1.2.3 -m "Release 1.2.3: description (TICKET-123)"
git push origin 1.2.3
```

First tag must often be created manually (semantic release can't bump from nothing).

## Rebase Patterns

### Conflict Resolution at Scale
- For simple same-shape conflicts across many files: Python regex > sed on macOS
- `GIT_EDITOR=true git rebase --continue` auto-accepts commit messages
- Always verify after automated resolution (`git diff`, `helm template`, `terraform validate`)

### When to Rebase vs Merge
- **Rebase:** Feature branches onto develop/main (clean linear history)
- **Merge:** Release branches, never rewrite shared history

## .gitignore Patterns for Infrastructure

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
*.tfplan
crash.log

# Secrets
.env
.env.local
*.pem
*.key

# OS
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/settings.json
```
