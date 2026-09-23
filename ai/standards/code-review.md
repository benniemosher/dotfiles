---
title: Code Review Standards
description: Nine-category framework for reviewing PRs and diffs at depth, plus posting format
tags: [code-review, pull-requests, quality]
last_updated: 2026-09-23
---

# Code Review Standards

## When to Use This

Any PR/diff review done at "principal engineer" depth — not a quick skim,
not a `/code-review low`. If the user asks to review a PR, evaluate whether
it's worth merging, or answer a reviewer's open question about a PR, walk it
against these categories.

## Category Framework

Nine categories, in this order. Give each a verdict of one or two sentences.
Use "N/A" plus a one-clause reason rather than omitting a row that doesn't
apply — a missing row reads as "forgot to check," not "doesn't apply."

1. **Definition of Done** — does the PR's own stated scope (ticket, PR body,
   prior review follow-ups it claims to close) actually get closed? Check
   open items against what's claimed done, not just against the diff.
2. **Correctness** — real bugs: wrong behavior, edge cases, race conditions,
   off-by-ones, unhandled error paths. This is the category that blocks
   merge; everything else is usually negotiable.
3. **Efficiency** — hot-path cost, N+1s, unnecessary re-computation. "N/A —
   no hot paths touched" is a fine, common verdict here.
4. **Documentation** — does README/specs/comments match what the code now
   does? Flag drift (a comment that used to be true and no longer is) as
   hard as flagging absence.
5. **Conciseness** — dead code, duplicated logic, comments narrating what
   the code already says. Note debt found along the way without demanding
   it be fixed in this PR — see "Non-blocking debt" below.
6. **Risk** — blast radius: what else does this change touch (shared
   modules, other environments/consumers, other deployments), and does the
   PR's own risk section describe that accurately? Verify claims like "only
   X is affected" against the actual dependency graph rather than trusting
   the PR body.
7. **Conventions** — does it match the codebase's existing patterns (naming,
   file layout, comment style, commit format)?
8. **Testing** — what's covered vs. untested, especially the exact
   bug-prone paths (error handling, auth boundaries, concurrency, the paths
   a prior review round flagged as untested).
9. **SDLC** — process: docs-update bots/labels, deploy sequencing, manual
   steps not yet automated or recorded, whether the PR follows the repo's
   own PR template.

## Posting Format

Post as a single markdown table, verdict-only per row — a sentence or two,
not a wall of text:

```
| Category | Verdict |
|---|---|
| Definition of Done | ... |
| Correctness | ... |
| Efficiency | ... |
| Documentation | ... |
| Conciseness | ... |
| Risk | ... |
| Conventions | ... |
| Testing | ... |
| SDLC | ... |
```

Follow the table with one or two sentences giving the bottom-line call: is
this mergeable now, does it need to be split, what's the single biggest
risk if any.

### Non-blocking debt

Debt found along the way — duplication, a follow-up worth doing but not in
this PR — goes in its own paragraph below the table, explicitly marked "not
a required change" or "non-blocking." Don't fold it into a category verdict
where it would read as blocking the PR.

## Before Posting to GitHub

- Start as a **pending review** (`gh api repos/<owner>/<repo>/pulls/<n>/reviews`
  with no `event` field — leaves it in `PENDING` state, visible only to the
  author until submitted) rather than posting directly, unless explicitly
  told to post immediately. Show the drafted content to the user first.
- If a review references other PRs being built as follow-ups, don't
  reference them with vague language ("getting a PR built") once a real PR
  exists — update the pending review body with the actual link before it's
  submitted.

## Origin

This table format matches how reviews are run on zCore's va-llm-api project
(PR #160, review by jtratner-zcore alongside GPT-6 and Claude Fable AI
reviewers) — reuse it for any PR review at this depth, not just that
project. See `~/Code/zcore/context.md` for that project's own PR template
requirements (Summary, High-level description of approach & implementation,
Diagrams or Visuals, Definition of Done, Testing criteria, Related tickets,
Risk assessment) — those are that repo's PR *description* template, a
separate but related convention from this review-*posting* format.
