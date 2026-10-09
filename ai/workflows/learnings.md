---
title: Learnings Workflow
description: System for capturing and organizing technical learnings
tags: [workflow, productivity, knowledge-management]
last_updated: 2026-09-01
---

# Learnings Workflow

## Overview

Learnings capture reusable knowledge discovered during daily work. They serve as a personal knowledge base that AI assistants can reference in future sessions, preventing re-discovery of solutions.

## Routing: the vault, on every machine

Entries route into the Obsidian vault at
`~/Code/obsidian-vault-setup/03-Resources/Learnings/YYYY-MM-DD.md`, tagged `type: learning`
per the vault's frontmatter schema (`Meta/Schema.md`).

This is the destination on **work and personal machines alike** (changed 2026-10-08; it used
to branch on `WORK_WORKSPACE`). A work machine's vault is local-only — no LiveSync, no git
remote — rather than a different location, so every learning ends up searchable in one place
regardless of which machine found it. The per-workspace `<workspace>/notes/learnings/` layout
described below is the fallback for a machine with no vault at all.

Long-lived topic notes live in the same folder, named for the topic rather than a date — see
the 250 extracted Charter notes and `Learnings-Index.md` for the shape. Dated files are the
capture surface; topic notes are what gets read later.

The Portable vs Business-Specific classification below still applies either way — it's about
where a *pattern* belongs long-term, independent of which machine captured it.

## File Structure

```
<workspace>/notes/learnings/
├── YYYY-MM-DD.md        # Daily learnings (can have multiple per day)
└── topics/              # Optional: long-lived topic files
    ├── terraform.md
    └── kubernetes.md
```

## File Format

```markdown
---
date: YYYY-MM-DD
tags: [terraform, eks, debugging]
---

# Learnings - YYYY-MM-DD

## Descriptive Section Title

### The Problem/Context
Brief description of what you were trying to do.

### The Solution/Pattern
What worked, with code examples.

### Why It Matters
When you'd use this again. Edge cases or gotchas.
```

## What Gets Captured

### Always Capture
- Root causes that took significant debugging
- Patterns that will be reused (CLI commands, API quirks, workarounds)
- "I wish I'd known this before I started" moments
- Tool-specific gotchas (version conflicts, config quirks)
- Decision rationale ("we chose X over Y because...")

### Don't Capture
- Obvious things documented in official docs
- One-off commands you'll never use again
- Temporary workarounds being fixed next sprint

## Classification: Portable vs Business-Specific

| Portable (goes in dotfiles ai/standards/) | Business-Specific (stays in workspace notes/) |
|-------------------------------------------|-----------------------------------------------|
| Terraform patterns (for_each, state mgmt) | How a specific repo's CI pipeline works |
| K8s probe tuning methodology | Account IDs, team names, repo URLs |
| Git workflow patterns | Ticket-specific debugging logs |
| Generic tool gotchas (Helm, Docker) | Architecture decisions for a product |
| Shell scripting patterns | Internal API endpoints |

When in doubt: if you could post it on a public blog without revealing your employer, it's portable.

## Rules for AI Assistants

- When we discover something reusable, proactively suggest capturing it as a learning
- Use descriptive section headers (not "Learning 1", "Learning 2")
- Include code examples wherever possible
- Cross-reference related learnings with `[[wikilinks]]`
- Add appropriate tags in frontmatter for discoverability

## The `learning` Command

Quick capture from terminal:

```bash
learning "terraform" "for_each requires map or set, not list of objects"
```

Creates or appends to today's learning file with a timestamp and the provided tags/content, at
the vault's `03-Resources/Learnings/YYYY-MM-DD.md`. Same on every machine (see Routing above).

## Obsidian Compatibility

- YAML frontmatter with date and tags
- Use `[[wikilinks]]` for cross-references between learnings
- Tags enable Obsidian graph view clustering by topic
- Section headers enable Obsidian outline navigation
