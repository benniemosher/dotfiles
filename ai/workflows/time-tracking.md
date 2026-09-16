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

Appends a row to `~/Code/obsidian-vault-setup/02-Areas/Work-Ongoing/<workspace>/Hours.md`, which is one
`### YYYY-MM-DD` section and table **per day** (not one flat table for the whole client):

```markdown
### 2026-09-01

| Date       | Hours | Time        | Description                | Invoiced |
|------------|-------|-------------|-----------------------------|----------|
| 2026-09-01 | 2.5   |             | Fixed CORS bug in tunnel   | No       |
| 2026-09-01 | 3.00  | 19:00-22:00 | Client call, budget review | No       |
| **Total**  | **5.50** |  |  |  |
```

`hours <start> to <end> "<desc>"` (24h `HHMM` or `HH:MM`) fills in both Hours (computed
duration) and Time (the original range); `hours <amount> "<desc>"` fills in Hours only, leaving
Time blank. `hours --date yesterday|today|YYYY-MM-DD|MM-DD-YYYY ...` backdates an entry — it
can appear anywhere in the arguments — run once per entry to backfill several for the same day.

Keep descriptions very brief — a few words, not a paragraph. Detail belongs in the Daily
note's `## Standup` section (see `standup-notes.md`); this table is purely for billing.

Errors out on a work machine (`WORK_WORKSPACE` set) — there's no vault to write to there.

Each day's **Total** row is recomputed by the script every time it logs another entry for that
day — a plain sum, no target/goal comparison, so the user can glance at today's section and see
today's hours at a time. Day sections are kept newest-first, inserted by actual date (not by
when the command ran) so backdated `--date` entries land in the right place; re-logging to an
existing day rebuilds that day's section in place rather than moving it.

Right after the H1 header, the file carries a `dataviewjs` block that computes a *grand*
"Unbilled: Xh · $Y" line live, across every day — it's correct on every view, not just after
running `hours` (so a manual edit or a mobile QuickAdd capture doesn't go stale), and it's the
first thing visible on opening the note. The script keeps that block pinned there — right under
the header, above every day section — whenever it appends a row; don't reorder it by hand, and
if writing to `Hours.md` outside the script (e.g. marking rows `Invoiced: Yes` when generating
an invoice, below), insert changes into the correct day's table, always *below* the
```` ```dataviewjs ```` block, never above it.

## Generating an Invoice

When asked to generate an invoice (e.g. "generate my zcore invoice for August"), an AI
assistant should:

1. Read `02-Areas/Work-Ongoing/<client>/Hours.md`.
2. Filter rows in the requested period where `Invoiced` = `No`.
3. Compute the line-item `Amount` for each row (Hours × `rate` from that file's frontmatter),
   and the Total Hours / Total Due. If `rate` isn't set, ask for one rather than guessing.
4. Compute `due_date` from the invoice date using `terms` (default **Net 15** unless the user
   says otherwise for that invoice) — e.g. date `2026-09-01` + Net 15 → `2026-09-16`.
5. Write a new note at `02-Areas/Work-Ongoing/<client>/Invoices/<invoice_number>.md`, following the shape
   in `03-Resources/Templates/invoice.md`. Sender block is fixed: Bennie Mosher /
   benniemosher@gmail.com / 970-590-2040. Payment line reads "Direct deposit (arranged
   separately)" — never print bank/account details in the note.

   The note is two parts, split by a hard page break, so **Export to PDF** always starts the
   itemized detail on its own page:
     - `.invoice-summary-page` — a "Summary" table with columns **Category, Hours, Rate,
       Amount** (in that order — matches the standard invoicing convention of title → hours →
       rate → amount), one row per category, ordered by hours descending, ending in a bold
       `Total` row that gives Total Hours and Total Due **in one line** rather than as a
       separate banner (Rate is blank on the Total row — summing a rate is meaningless). Every
       category used here must come from the canonical list below — see "Rules for AI
       Assistants" before inventing a new one. The `**Payment:**` line lives on this page too,
       directly below the Total row — not at the bottom of the whole note — so the reader sees
       it without turning to the detail pages. **Rate lives here, not on the detail pages.**
     - `.invoice-detail-page` — one day-header bar + table per calendar day in the period
       (mirroring `Hours.md`'s per-day sections), not one flat table for the whole period.
       Each day's table has columns **Category, Description, Hours, Amount** — no Rate column
       (that's on the Summary page only, since it's a constant per invoice and repeating it on
       every row added no information) — and ends with a bold "Day Total" row; day totals must
       sum to the Summary page's Total row. Each day's header-bar + table pair is wrapped in
       one outer `<div style="page-break-inside:avoid;break-inside:avoid;">` — without it,
       Obsidian's PDF pagination can strand a day's header bar at the bottom of a page and push
       its table onto the next one. Wrap the pair, not just the table, so they always move
       together.

   **Styling is inline, not just the CSS snippet.** `.obsidian/snippets/invoice.css` exists and
   is enabled, but Obsidian's "Export to PDF" has been observed dropping it entirely (symptom:
   flex layouts collapse and adjacent `<span>`s render jammed together with no gap, e.g.
   "Terraform3.00 h"). `03-Resources/Templates/invoice.md` bakes the letterhead banner, table
   header colors, zebra-striping, and the Total row as `style="..."` attributes directly on
   each element for this reason — copy that pattern rather than reintroducing bare classed
   `<div>`/`<span>` layouts that only look right if the snippet happens to load. Color scheme
   is a single royal purple, `#4c1d95` (user's preference, 2026-09-09: "purple and black is my
   Harley color" — a follow-up dropped the black variant, then a second follow-up replaced the
   first, brighter purple `#6d28d9` for something deeper/less neon — "royal purple like Jesus
   would wear"): header banner, table header accents, day-header bars, and the summary Total
   row all use it — don't drift back to blue, black, or the brighter violet.
   The `**Period:**` line in `invoice-dates` is wrapped in an inline `<span style="white-space:
   nowrap;">` on the same line as itself, staying in the same paragraph as the Date/Due/Terms
   lines above it — this keeps the date range from wrapping without opening a `<div>` (a block
   element), which would start a new paragraph and add a visible blank-line gap before it.
6. Update those same rows in `Hours.md` to `Invoiced: Yes` so they aren't billed twice — insert
   changes *above* the ```` ```dataviewjs ```` fence at the end of the file, never below it.
7. Tell the user to open the new note in Obsidian and use **Export to PDF** (Command
   Palette → "Export to PDF") to produce the sendable file — no plugin needed, it's a core
   Obsidian command.

## Summary Categories

Reuse these across invoices so the rollup stays comparable period to period — don't reinvent a
category with slightly different wording each time:

- **Meetings** — standups, syncs, 1:1s, team/project meetings.
- **Code Review** — reviewing, approving, or merging *someone else's* PR; also covers
  reviewing an infra/config PR (e.g. Terraform) even when the subject matter isn't code per se.
- **Admin** — paperwork, Slack triage, general overhead, and travel/appointments (travel time
  is folded in here rather than given its own bucket, per user preference 2026-09-09).
- **Onboarding / Setup** — one-off account/environment/machine setup; mostly a new-engagement
  category, won't recur on every invoice.
- **Tooling / CI Setup** — pre-commit config, CI/CD pipeline work, dev-tooling setup — distinct
  from feature/infra development.
- **`PR#NN` / `Issue#NN` (ad hoc)** — when a meaningful chunk of time centers on building out
  one specific ticket (not reviewing it — building it), break it out under its own
  ticket-numbered category instead of a generic bucket, e.g. `PR#95 (App Service Deploy)`.
- Client- or project-specific buckets (e.g. **Azure E2E Testing**) are fine to add when a
  cluster of work is real and recurring — add it here once agreed so later invoices reuse the
  same label instead of drifting (e.g. "Azure/Dev" vs "Azure Testing" vs "E2E work").

## Rules for AI Assistants

- Never mark a row `Invoiced: Yes` without the user having actually requested (or approved)
  the invoice generation — this changes billing state.
- Keep invoice notes idempotent-safe: check `Invoices/` for an existing draft covering the
  same period before creating a duplicate.
- If `rate` isn't set for a client, still generate the invoice with hours only and ask for a
  rate rather than guessing one.
- When a line item's category isn't obviously covered by the list above — it's genuinely
  ambiguous, or two activities are jammed into one logged row (e.g. "reviewed the Terraform PR
  and prepped the pre-commit PR") — ask the user which bucket it belongs in rather than
  guessing silently. Add the resolved category to the list above if it'll recur.
