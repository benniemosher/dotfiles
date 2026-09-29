---
title: Obsidian Vault
description: What lives in the personal Obsidian vault and how the workflows use it
tags: [workflow, notes, obsidian]
last_updated: 2026-09-27
---

# Obsidian Vault

The personal vault at `~/Code/obsidian-vault-setup` is where daily notes, learnings, and
billing live on a personal machine. It's a git repo that `vault-snapshot` commits every 15
minutes and pushes to a backup remote (see Snapshots below).

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
CouchDB, not over git — see the vault's `SPEC.md` §1. Git is not a transport between
devices; it is the history that lets you undo what LiveSync does.

The LiveSync **setup URI** encodes the CouchDB URL and credentials, and LiveSync encrypts
it with a passphrase of its own. Both live in 1Password, in one item with a `setup-uri` field and a `passphrase` field.

`chezmoi init` asks for that item as `op://<vault>/<item id>` on personal machines and writes
the refs into `~/.config/chezmoi/chezmoi.toml`. That file is never committed, so the vault and
item names stay out of the dotfiles repo. Use the item **id**, not its title — the id survives
a rename. Leave the answer blank on a machine that doesn't sync the vault, and the bootstrap
script skips itself. Treat the URI as a
credential: never paste it into a note, a shared terminal, or a repo.

Regenerate it from Obsidian → Settings → Self-hosted LiveSync → Setup wizard → Copy setup
URI, which is also where you set the passphrase.

## Snapshots

LiveSync propagates deletions, and a first "fetch from remote" on a new device replaces the
vault with the server's copy, dropping local-only files. Both have removed notes and invoices
before (2026-09-25 and 09-27). `bin/vault-snapshot` guards against that:

- A systemd user timer (Linux) or LaunchAgent (macOS) runs it every 15 minutes on personal
  machines. It commits every change, unsigned, since no one is there to approve a signature.
- It refuses to commit when more than 5 tracked files have disappeared since the last
  snapshot, and sends a desktop notification instead. Restore with
  `git -C ~/Code/obsidian-vault-setup ls-files --deleted -z | xargs -0 git -C ~/Code/obsidian-vault-setup checkout --`.
  If the deletions were intended, run `VAULT_SNAPSHOT_ALLOW_DELETES=1 vault-snapshot` once.
- It pushes to `obsidian_vault_backup_remote` (a `chezmoi init` prompt), one branch per
  machine named for its short hostname. The remote is a bare repo on battlestation's `/data`
  disk: `/data/backups/obsidian-vault.git` there, and
  `ssh://battlestation-ubuntu.local/data/backups/obsidian-vault.git` from the Mac. Leave it
  blank to commit locally only. It is deliberately not on GitHub.
- The setup script commits the vault before handing LiveSync the setup URI, so a fetch that
  drops local files can be undone.

Check it: `systemctl --user list-timers vault-snapshot.timer` and
`journalctl --user -u vault-snapshot` on Linux; `~/Library/Logs/vault-snapshot.log` on macOS.

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
4. Obsidian prompts for the setup-URI passphrase — this part is attended, since that prompt
   can't be fed programmatically. The script puts the passphrase on the clipboard when the
   passphrase ref is configured, so it's a paste. Clear the clipboard afterwards.
5. Accept the imported settings and let the first replication finish. The rest of the vault
   arrives over LiveSync.
6. Then run the vault's `bin/install-obsidian-plugins.sh` for the remaining plugins, and
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
