---
title: Obsidian Vault
description: What lives in the personal Obsidian vault and how the workflows use it
tags: [workflow, notes, obsidian]
last_updated: 2026-09-27
---

# Obsidian Vault

The vault at `~/Code/obsidian-vault-setup` is where daily notes, learnings, and billing live.
It's a git repo that `vault-snapshot` commits every 15 minutes and pushes to a backup remote
(see Snapshots below).

Every machine has one, and daily notes and learnings route into it everywhere (changed
2026-10-08; it used to branch on `WORK_WORKSPACE`). What differs is the plumbing around it,
not the location: a personal machine gets LiveSync and the backup remote, while a work-issued
machine's vault is local-only — no LiveSync, no remote — and billing doesn't apply there.

## Layout

| Path | What's in it |
|------|--------------|
| `Daily/YYYY-MM-DD.md` | Daily notes, including the `## Standup` section |
| `02-Areas/Work-Ongoing/<client>/Hours.md` | Unbilled time, one dated section per day |
| `02-Areas/Work-Ongoing/<client>/Hours/YYYY-MM.md` | Closed months, archived by `--close` |
| `02-Areas/Work-Ongoing/<client>/Invoices/` | Generated invoice notes, one per invoice |
| `03-Resources/Learnings/YYYY-MM-DD.md` | Captured reusable knowledge |
| `03-Resources/Templates/` | Note templates, including the invoice layout |
| `01-Projects`, `04-Archive`, `MOCs`, `00-Inbox` | PARA-style organization |
| `Attachments/`, `Meta/`, `Dashboard.md` | Media, vault config notes, landing page |
| `zz-secrets/` | Secrets a vault note needs to read at runtime. In neither git (`.gitignore`) nor LiveSync (`syncIgnoreRegEx`), so it is per-machine and has no backup — see below |
| `bin/` | Vault scripts (see below) |

## zz-secrets is per-machine, and that is not a backup gap to fix

`Dashboard.md` fetches a daily photo through the Pexels API, and reads the key with
`app.vault.adapter.read("zz-secrets/pexels-api-key.md")`. That adapter only reads
vault-relative paths, so the key has to be a file inside the vault — it cannot live only in
1Password and be read from there.

The folder is therefore excluded from both git and LiveSync on purpose. The consequence is
that nothing in it reaches another machine or any backup, so:

- **1Password is the source of truth.** The copy in the vault is a deployed artifact, like a
  rendered dotfile, not the record.
- **Keep nothing here you could not recreate from 1Password.** A wiped machine loses it.
- Earlier versions of the migration runbook said to "confirm `zz-secrets/` is in the
  snapshot" before a wipe. `.gitignore` makes that impossible; the instruction never worked.

`Dashboard.md` degrades gracefully when the key is absent — it prints a line telling you to
add one — so a new machine is not broken by it, just missing the photo.

Deploy them with `vault-secrets`, or `vault-secrets --force` to roll out a rotated key.
Placing a secret is deliberately a human step: `op` authenticates through the 1Password
desktop app and so needs an unlocked app and a prompt. A Service Account token would make it
unattended, and that was considered and rejected — a long-lived token that reads vaults
without a prompt is worse than typing a password once per machine. Expect `chezmoi apply` on
a fresh machine to say it is skipping the secrets, and run `vault-secrets` yourself after
signing in.

## Scripts

- `bin/generate-invoice.py` — builds an invoice note from a client's `Hours.md`. Generating
  never writes `Hours.md`; `--close YYYY-MM`, run once the invoice is sent, marks that month
  billed and moves it to `Hours/YYYY-MM.md`. See `time-tracking.md`.
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

LiveSync only runs inside a running Obsidian. On battlestation, the `hours` and `standup`
commands write vault files directly, and nothing pushes them until Obsidian is open. When the
desktop session there ended on 2026-10-09, the Mac fell four days behind. On Linux personal
machines, `~/.config/autostart/obsidian.desktop` starts Obsidian at login, but it still needs
a desktop login after a reboot or logout.

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
`journalctl --user -u vault-snapshot` on Linux. On macOS, `~/Library/Logs/vault-snapshot.log`
and the `runs` count in `launchctl print gui/$(id -u)/com.local.vault-snapshot`. A healthy
run logs nothing, so look at the backup branch's last commit too. The LaunchAgent uses
`StartCalendarInterval`, because `StartInterval` stopped firing across sleep and the Mac went
from Sept 28 to Oct 13 without a snapshot.

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
It creates the same PARA skeleton locally and stops — so the vault exists and `standup` and
`learning` write into it, but nothing leaves the machine. Populating it beyond the skeleton
is manual: there's no sync to pull history down.

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
