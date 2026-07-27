---
title: Standup Notes Workflow
description: System for maintaining daily standup notes with AI assistance
tags: [workflow, productivity, daily]
last_updated: 2026-07-26
---

# Standup Notes Workflow

## Overview

Daily standup notes track what was accomplished, what's planned, and serve as an audit trail of decisions and debugging. AI assistants update these throughout the day as work happens — not just at the end.

## File Structure

```
<workspace>/notes/standups/
├── YYYY-MM-DD.md        # One file per day
└── templates/
    └── daily.md         # Template for new days
```

## File Format

Each daily file follows this structure:

```markdown
---
date: YYYY-MM-DD
tags: [standup]
---

# Standup - YYYY-MM-DD

## Summary (for standup)

### TICKET-123: Short Description
- Sub-bullet with detail and status (merged ✅, pending, blocked)
- Another detail

### TICKET-456: Another Item
- Detail here

## Plan for tomorrow
- Priority 1
- Priority 2

---

## Log
- [HH:MM] Description of what was done
- [HH:MM] Another entry with context
```

## Rules for AI Assistants

When updating standup notes, ALWAYS:

1. **Append timestamped entry** to the `## Log` section (use 24h format, local time)
2. **Update `## Summary (for standup)`** if the work is standup-worthy (grouped by ticket)
3. **Update `## Plan for tomorrow`** if priorities shifted
4. **Never overwrite existing entries** — only append to Log, update Summary/Plan in place

### Summary Format
- Group by ticket with sub-bullets
- Include status indicators: merged ✅, pending, blocked, in progress
- Keep it scannable — this is what gets read aloud in standup

### Log Format
- Timestamped entries in chronological order
- Include enough context that you can reconstruct what happened weeks later
- Reference MR numbers, pipeline IDs, commands run
- Note root causes when debugging

### Separator
Use `---` (horizontal rule) between Summary/Plan and the Log section.

## The `standup` Command

Quick entry from any terminal:

```bash
standup "TICKET-123: Fixed the flaky test by mocking the clock"
```

This appends a timestamped entry to today's standup file in the current workspace.

## Obsidian Compatibility

- YAML frontmatter required (date, tags)
- Use `[[wikilinks]]` for cross-references to learnings or other standups
- Tags in frontmatter for filtering in Obsidian graph view
