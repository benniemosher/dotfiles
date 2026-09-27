---
title: Obsidian Vault
description: What lives in the personal Obsidian vault and how the workflows use it
tags: [workflow, notes, obsidian]
last_updated: 2026-09-27
---

# Obsidian Vault

The personal vault at `~/Code/obsidian-vault-setup` is where daily notes, learnings, and
billing live on a personal machine. It's a git repo, but **local-only — no remote**, so it
isn't backed up anywhere off this disk.

Only used when `WORK_WORKSPACE` is unset. On a work machine the standup and learning
workflows write to `<workspace>/notes/` instead, and billing doesn't apply at all.

## Layout

| Path | What's in it |
|------|--------------|
| `Daily/YYYY-MM-DD.md` | Daily notes, including the `## Standup` section |
| `02-Areas/Work-Ongoing/<client>/Hours.md` | Billable time, one dated section per day |
| `02-Areas/Work-Ongoing/<client>/Invoices/` | Generated invoice notes, one per invoice |
| `03-Resources/Learnings/YYYY-MM-DD.md` | Captured reusable knowledge |
| `03-Resources/Templates/` | Note templates, including the invoice layout |
| `01-Projects`, `04-Archive`, `MOCs`, `00-Inbox` | PARA-style organization |
| `Attachments/`, `Meta/`, `Dashboard.md` | Media, vault config notes, landing page |
| `zz-secrets/` | Kept out of anything shared — never commit its contents elsewhere |
| `bin/` | Vault scripts (see below) |

## Scripts

- `bin/generate-invoice.py` — builds an invoice note from a client's `Hours.md`. Never writes
  `Hours.md`. See `time-tracking.md`.
- `bin/install-obsidian-plugins.sh` — installs and enables the community plugins listed in
  `obsidian-plugins.yaml`. Plugin code and settings are deliberately untracked, so this
  script is what reproduces them on a new machine.

## Which workflow owns what

- `standup-notes.md` — the `Daily/` note and its `## Standup` section
- `learnings.md` — `03-Resources/Learnings/`
- `time-tracking.md` — `Hours.md`, `Invoices/`, and the `hours` command

Those three are the detail; this file is just the map.

## Sync

Content syncs over **Self-hosted LiveSync** (`obsidian-livesync`) against a self-hosted
CouchDB, not over git — see the vault's `SPEC.md` §1. The git repo is for local version
history only, and it has no remote, so git is not a transport and not a backup.

The LiveSync **setup URI** encodes the CouchDB URL and credentials. It lives in 1Password;
`obsidian_livesync_op_ref` in `~/.config/chezmoi/chezmoi.toml` points at it, defaulting to
`op://Private/Obsidian LiveSync/setup uri`. Treat it as a credential: never paste it into a
note, a terminal you're sharing, or a repo.

## Setting up a new machine

`run_once_setup-obsidian-vault.sh` in the dotfiles does this on the first `chezmoi apply`,
and branches on whether the machine is a work one:

**Personal** (`work_platform` unset, `WORK_WORKSPACE` unset):

1. Creates `~/Code/obsidian-vault-setup` with the PARA skeleton.
2. Installs the `obsidian-livesync` plugin and enables it — bootstrapping it directly,
   because the vault's own `bin/install-obsidian-plugins.sh` doesn't exist locally until
   the vault has synced.
3. Reads the setup URI from 1Password and hands it to Obsidian. The URI is never echoed
   or written to disk.
4. Accept the imported settings in Obsidian and let the first replication finish. The rest
   of the vault arrives over LiveSync.
5. Then run the vault's `bin/install-obsidian-plugins.sh` for the remaining plugins, and
   pick the Minimal theme under Settings → Appearance.

**Work** (`work_platform` or `WORK_WORKSPACE` set): no LiveSync, no 1Password, no billing.
It creates the same PARA skeleton locally and stops. Standups and learnings route to
`<workspace>/notes/` on a work machine anyway.

The script skips its work if LiveSync is already configured, so it's safe to re-run. To
force it:

```bash
chezmoi state delete-bucket --bucket=entryState && chezmoi apply
```

It also exits quietly rather than failing when `op` is missing or not signed in, or when
there's no GUI session to open the URI — re-run it once that's sorted.

## Also per-machine, by choice

CSS snippets live in `.obsidian/snippets/`; enable them under Appearance. `invoice.css`
styles invoice notes, though those notes also carry inline styles because PDF export has
been seen dropping the snippet entirely.
