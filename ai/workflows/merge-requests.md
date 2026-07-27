---
title: Merge Request Workflow
description: Standards for creating, describing, and managing merge requests
tags: [workflow, git, code-review]
last_updated: 2026-07-26
---

# Merge Request Workflow

## Principles

- Every MR has a meaningful description (never blank)
- Squash commits on merge for clean history
- Remove source branch after merge
- Include ticket reference in title and branch name

## MR Description Structure

### Feature/Fix MRs

```markdown
## Summary

One-paragraph description of what this MR does and why.

## Changes

- Bullet list of specific changes
- Include file names when helpful
- Note any breaking changes

## Testing

- How was this verified?
- Commands run, environments tested

## Rollback Plan

How to revert if something goes wrong.
```

### Release MRs (develop → main)

```markdown
## Summary

Merge development → main for release X.Y.Z. Contains <brief description>.

## Changes

### TICKET-1: Title
- Change detail with old → new values
- Rationale in parentheses (e.g., "1.5x observed avg")

### TICKET-2: Title
- Change details

### Files Modified
- `path/to/file.yml`
- `path/to/other.yml`

### Before
\`\`\`yaml
<old values>
\`\`\`

### After
\`\`\`yaml
<new values>
\`\`\`

## Post-Merge
- Tag as X.Y.Z on main
- Monitor for issues
- Deploy to next environment
```

## CLI Creation

```bash
glab mr create \
  --source-branch <branch> \
  --target-branch <main|development> \
  --title "TICKET-123: Short description" \
  --description "<markdown>" \
  --squash-before-merge \
  --remove-source-branch \
  --no-editor
```

For GitHub:
```bash
gh pr create \
  --title "TICKET-123: Short description" \
  --body "<markdown>" \
  --base main
```

## Pre-Submission Checklist

- [ ] Pre-commit hooks pass (`pre-commit run --all-files`)
- [ ] Tests pass locally
- [ ] Branch is rebased on target (no stale conflicts)
- [ ] Description filled out (not blank)
- [ ] Ticket number in title and branch name
- [ ] No secrets or credentials in the diff
- [ ] For Terraform: `terraform validate` passes

## Review Etiquette

- Respond to all review comments before re-requesting review
- Explain WHY, not just what, when addressing feedback
- If a comment leads to a code change, reply with what was changed
- Mark conversations as resolved only after the fix is pushed
