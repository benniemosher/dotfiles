# Shared Knowledge Base

Every AI tool I use — Claude Code, Kiro, or whatever replaces them — reads the same
instructions and the same accumulated knowledge. This file says where that lives, so no
agent is working from a smaller picture than the others.

## The three layers

| Layer | Location | What it is |
|---|---|---|
| **Instructions** | `~/.config/ai/` | How to work: `AGENT.md` (personality, communication, working style), `standards/` (git, Terraform, K8s, CI/CD, observability, code review, documentation), `workflows/` (standups, learnings, MRs, pre-commit, time tracking) |
| **Accumulated knowledge** | `~/Code/obsidian-vault-setup/03-Resources/Learnings/` | Technical learnings — dated files are the capture surface, topic-named notes are what gets read later. `Learnings-Index.md` groups them by technology. |
| **Current state** | `~/Code/obsidian-vault-setup/02-Areas/Work-Ongoing/<workspace>/Context.md` and `Daily/` | What this client/employer's environment actually is, and what I was last doing in it |

All three are the same on every machine. A work-issued machine's vault is local-only — no
LiveSync, no git remote — rather than a different location, so `standup` and `learning` write
to the same places everywhere and no agent is reading a different set of notes than another.

`~/.config/ai/` is canonical and managed by chezmoi. Edit it there, not in a tool-specific
config, so the change reaches every agent at once.

## Rules

**Search the learnings before solving.** If a problem touches Terraform, EKS, Helm, Datadog,
GitLab CI, IAM, DocumentDB, DNS, secrets or cost, grep
`~/Code/obsidian-vault-setup/03-Resources/Learnings/` first. A lot of what looks novel has
already been debugged once and written up with the root cause. `Learnings-Index.md` in that
folder groups every note by technology.

**Capture what's reusable.** When we work out something non-obvious, write it up per
`workflows/learnings.md` — one topic per note, descriptive heading, code examples, tags in
frontmatter. The point is that the next agent session starts where this one ended.

**Read the workspace context before acting on a repo.** The `Context.md` note for that
workspace carries the account IDs, profiles, repo list, branch and commit conventions.
Guessing these wastes a round trip; worse, acting on a stale guess can touch the wrong
account.

**One writing style everywhere.** `standards/documentation.md` governs all prose output —
docs, PR/MR descriptions, commit messages, Slack and email updates. Plain, clear language,
linear flow, no hyperbole or metaphor, Hemingway not Faulkner. It applies to every agent, not
just the one that happens to be writing the doc.

**Treat notes as last-known-good, not truth.** A note records what was true when it was
written. If one names a file, flag, ticket state or account, verify it still holds before
recommending action on it.

## Related

- `AGENT.md` — the top-level working agreement
- `standards/documentation.md` — the writing style all output follows
- `workflows/learnings.md` — how learnings get captured and where they route
- `workflows/standup-notes.md` — how daily work gets recorded
