---
title: Time Tracking & Invoicing Workflow
description: System for logging billable hours and generating client invoices
tags: [workflow, productivity, billing]
last_updated: 2026-09-01
---

# Time Tracking & Invoicing Workflow

## Overview

Billable hours get logged per-client into the personal Obsidian vault, then compiled into an
invoice note when it's time to bill. This is a personal-machine-only workflow — there's no
work-machine equivalent, since invoicing reads directly from the vault.

## The `hours` Command

Quick capture from terminal, auto-detects the client from the current workspace:

```bash
cd ~/Code/zcore
hours 2.5 "Fixed CORS bug in tunnel config"
```

Appends a row to `~/Code/obsidian-vault-setup/02-Areas/<workspace>/Hours.md`:

```markdown
| Date       | Hours | Time        | Description                | Invoiced |
|------------|-------|-------------|-----------------------------|----------|
| 2026-09-01 | 2.5   |             | Fixed CORS bug in tunnel   | No       |
| 2026-09-01 | 3.00  | 19:00-22:00 | Client call, budget review | No       |
```

`hours <start> to <end> "<desc>"` (24h `HHMM` or `HH:MM`) fills in both Hours (computed
duration) and Time (the original range); `hours <amount> "<desc>"` fills in Hours only, leaving
Time blank. `hours --date yesterday|today|YYYY-MM-DD|MM-DD-YYYY ...` backdates an entry — it
can appear anywhere in the arguments — run once per entry to backfill several for the same day.

Keep descriptions very brief — a few words, not a paragraph. Detail belongs in the Daily
note's `## Standup` section (see `standup-notes.md`); this table is purely for billing.

Errors out on a work machine (`WORK_WORKSPACE` set) — there's no vault to write to there.

Every `Hours.md` ends with a `dataviewjs` block that computes an "Unbilled: Xh · $Y" line live,
straight from the table — it's correct on every view, not just after running `hours` (so a
manual edit or a mobile QuickAdd capture doesn't go stale). The script keeps that block
positioned as the last thing in the file whenever it appends a row; don't reorder it by hand,
and if writing to `Hours.md` outside the script (e.g. marking rows `Invoiced: Yes` when
generating an invoice, below), insert new/changed rows *above* the ```` ```dataviewjs ```` fence,
never below it.

## Generating an Invoice

When asked to generate an invoice (e.g. "generate my zcore invoice for August"), an AI
assistant should:

1. Read `02-Areas/<client>/Hours.md`.
2. Filter rows in the requested period where `Invoiced` = `No`.
3. Sum hours. If `rate` is set in that file's frontmatter, compute the total ($).
4. Write a new note at `02-Areas/<client>/Invoices/<invoice_number>.md`, following the shape
   in `03-Resources/Templates/invoice.md` (frontmatter includes `cssclass: invoice`, which
   picks up `.obsidian/snippets/invoice.css` for a clean printed layout).
5. Update those same rows in `Hours.md` to `Invoiced: Yes` so they aren't billed twice.
6. Tell the user to open the new note in Obsidian and use **Export to PDF** (Command
   Palette → "Export to PDF") to produce the sendable file — no plugin needed, it's a core
   Obsidian command.

## Rules for AI Assistants

- Never mark a row `Invoiced: Yes` without the user having actually requested (or approved)
  the invoice generation — this changes billing state.
- Keep invoice notes idempotent-safe: check `Invoices/` for an existing draft covering the
  same period before creating a duplicate.
- If `rate` isn't set for a client, still generate the invoice with hours only and ask for a
  rate rather than guessing one.
