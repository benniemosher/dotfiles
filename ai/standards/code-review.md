---
title: Code Review Standards
description: Ten-category framework for reviewing PRs and diffs at depth, plus posting format
tags: [code-review, pull-requests, quality]
last_updated: 2026-09-29
---

# Code Review Standards

## When to Use This

Any PR/diff review done at "principal engineer" depth — not a quick skim,
not a `/code-review low`. If the user asks to review a PR, evaluate whether
it's worth merging, or answer a reviewer's open question about a PR, walk it
against these categories.

## Category Framework

Ten categories, in this order. Give each a verdict of one or two sentences.
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
7. **Observability** — once this ships, will we know whether it's working?
   New failure modes should produce queryable signals (logs, metrics,
   traces) with enough context to trace a request, and a failure that
   matters should raise an owned alert on a sustained condition, not a
   single spike. Check dashboards and runbooks for new behavior, and that
   nothing logs secrets, PII/PHI, or identity headers. See
   `observability.md`. "N/A — no runtime change" is a fine verdict.
8. **Conventions** — does it match the codebase's existing patterns (naming,
   file layout, comment style, commit format)?
9. **Testing** — what's covered vs. untested, especially the exact
   bug-prone paths (error handling, auth boundaries, concurrency, the paths
   a prior review round flagged as untested).
10. **SDLC** — process: docs-update bots/labels, deploy sequencing, manual
    steps not yet automated or recorded, whether the PR follows the repo's
    own PR template.

## Posting Format

The ten categories are the reviewer's checklist. Don't post the table: the author
reads findings, not a scorecard (team feedback, 2026-10-01, modeled on a teammate's
reviews the lead singled out).

**Review body:** one or two sentences, no praise or preamble. The bottom-line call
(mergeable now, needs a split, or blocked) and the single biggest risk, if any.

**Inline comments**, one issue each:

- **Start with a severity label:** `Must fix before merge:`, `Non-blocking:`,
  `Nit:`, or a qualified form (`Security nit:`, `A11y, non-blocking:`,
  `Test, non-blocking:`). The author should be able to triage from the first words.
- **Name the rule** when it comes from the repo's conventions, e.g.
  `Nit (typed assertions rule):`.
- **Give the concrete failure:** the input or state, and what goes wrong.
- **Say how you verified it** in one clause: "checked at this head", "ran X", or
  "per `lib/file.js:63`".
- **Use a ` ```suggestion ` block** whenever the fix is a concrete edit, so it's one
  click to apply.
- **Outside the diff:** anchor the comment on the nearest changed line and say so.

**Before writing**, read the existing threads (Codex, Copilot, humans). Extend a
thread ("follows up Codex thread (a)") rather than repeating it. For docs PRs, check
the change against the other open docs PRs for contradictions.

### Non-blocking debt

Debt found along the way — duplication, a follow-up worth doing but not in
this PR — goes in an inline comment labeled `Non-blocking:`, or in the review
body marked "not a required change". Don't word it so it reads as blocking.

If a non-blocking item won't be done in this PR, open a GitHub issue for it, add the
issue to the program tracker, and link the issue in the comment (team lead's ask,
2026-09-30). A non-blocking comment should end up either fixed in the PR or tracked.

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

The category checklist comes from a client infrastructure project where a large PR
was reviewed at this depth by a teammate alongside two AI reviewers — reuse it
for any PR review at that depth, not just that project. A repo may also have
its own PR *description* template (Summary, High-level description of approach
& implementation, Diagrams or Visuals, Definition of Done, Testing criteria,
Related tickets, Risk assessment); check that workspace's `context.md`. That's
a separate but related convention from this review-*posting* format.
