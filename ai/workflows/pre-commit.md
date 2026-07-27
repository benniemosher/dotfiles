---
title: Pre-Commit Workflow
description: Standards for pre-commit hook usage and configuration
tags: [workflow, quality, automation]
last_updated: 2026-07-26
---

# Pre-Commit Workflow

## Philosophy

Pre-commit hooks catch issues before they enter version control. They should be fast, deterministic, and auto-fix where possible.

## Standard Hook Set

### Universal (all repos)

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: detect-private-key
```

### Terraform repos

```yaml
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
        args:
          - --hook-config=--parallelism-limit=1
          - --tf-init-args=-backend=false
      - id: terraform_tflint
      - id: terraform_trivy
        args:
          - --args=--skip-dirs="**/.terraform"
      - id: terraform_docs
  - repo: https://github.com/clarkenet/pre-commit-commit-msg-hooks
    hooks:
      - id: conventional-pre-commit
```

### Shell scripts

```yaml
  - repo: https://github.com/shellcheck-py/shellcheck-py
    hooks:
      - id: shellcheck
        args: ["-x"]
```

### Markdown

```yaml
  - repo: local
    hooks:
      - id: markdownlint-cli2
        name: markdownlint
        language: system
        entry: npx markdownlint-cli2
        types: [markdown]
```

## Corporate Network Workarounds

When behind corporate SSL proxies:

| Problem | Fix |
|---------|-----|
| `checkov_container` hangs (Docker pull) | Use `terraform_trivy` instead |
| `markdownlint_docker` fails | Use local system hook with `npx` |
| `terraform-docs` download fails | Use `language: system` local hook |
| Node-based hooks fail (`nodeenv`) | Use `language: system` with local Node |

## Workflow Rules

### After Auto-Fix

When pre-commit auto-fixes files (terraform_fmt, trailing-whitespace, end-of-file-fixer):

```bash
git add <fixed-files>
git commit  # run hooks again on the fixed version
```

Don't use `--no-verify` to skip — that defeats the purpose.

### When --no-verify Is Acceptable

- Corporate SSL breaks a hook with no workaround available
- Amending a commit where only the message changed
- Husky hooks require Node in PATH and you're in a non-Node context

### Manual Hooks (Slow Operations)

Use `stages: [manual]` for hooks that are too slow for every commit:

```yaml
- id: terraform_validate
  stages: [manual]
```

Run manually: `pre-commit run terraform_validate --hook-stage manual`

## Setup

```bash
# Install (one-time per repo)
pre-commit install

# Run on all files (not just staged)
pre-commit run --all-files

# Update hook versions
pre-commit autoupdate

# Skip hooks temporarily (escape hatch)
git commit --no-verify -m "WIP: temporary"
```
