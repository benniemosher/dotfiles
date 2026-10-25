# Omarchy on the 2018 MacBook Pro — migration runbook

Read this on your phone while the laptop is being wiped. Work top to bottom and tick the
boxes. Anything marked **STOP** will cost you real time if you skip it.

## This machine

| | |
|---|---|
| Model | `MacBookPro15,1` — 15-inch, 2018 |
| CPU | 6-core Intel Core i7 @ 2.6 GHz, 16 GB RAM |
| GPU | Intel UHD 630 **+ AMD Radeon Pro 555X** (hybrid — this matters, see Phase 5) |
| Disk | 251 GB NVMe, single APFS container, FileVault **off** |
| T2 | Yes (iBridge 24.16.6005) |
| Activation Lock | **On** — Phase 0 turns this off |

Plan: full wipe, Omarchy only, no macOS and no dual boot. Omarchy's installer takes the whole
drive and macOS will not be bootable afterward. That is the supported path and the one you
chose.

## The three things that will actually bite you

1. **Hybrid graphics.** Omarchy issue
   [#12593](https://github.com/omacom/omarchy/issues/12593) is open as of 2026-10-23 and names
   `MacBookPro15,1` directly: after the first login the fans go to full, the screen goes
   black, and the machine powers off. There is no shipped fix — `force_igd` does not appear
   anywhere in the Omarchy tree. The t2linux wiki independently lists hybrid graphics as
   only partially supported — "dGPU power toggling doesn't work" — so this is two sources
   agreeing, not one bug report. Phase 5 applies the workaround **before** you ever log in.
2. **No Wi-Fi in the installer until firmware lands.** Have a USB-C hub with Ethernet, or a
   phone you can USB-tether. Omarchy pulls the Broadcom firmware from Apple's recovery image
   during install, but it needs a network to do it.
3. **Activation Lock.** If you wipe without signing out of iCloud first, a future DFU revive
   of the T2 can be blocked. Phase 0, step 1. Do not skip it.

---

## Phase 0 — Before you touch anything

### Sign out of Apple's services  **STOP**

- [ ] System Settings → your name → **Sign Out** of iCloud
- [ ] Confirm Find My Mac is off: System Settings → your name → iCloud → Find My Mac → Off
- [ ] Verify: `Apple menu → About This Mac → More Info → System Report → Hardware` should now
      read `Activation Lock Status: Disabled`

Check it from the terminal:

```bash
system_profiler SPHardwareDataType | grep -i "activation lock"
```

You want `Disabled`. If it still says `Enabled`, you are not signed out.

### Back up what is not already in git or 1Password

You have 149 GB on the data volume. Most of it recovers from somewhere; these do not:

- [ ] `~/.config/chezmoi/chezmoi.toml` — not committed, holds `git_email`, `invoice_phone`,
      `invoice_address`, the vault backup remote, and the 1Password refs for LiveSync. Copy it
      to 1Password as a secure note, or just write the answers down — `chezmoi init` asks for
      them again.
- [ ] `~/.config/git/allowed_signers` — deliberately unmanaged, lists work email addresses.
- [ ] `~/.zshrc.local` — machine-local shell overrides.
- [ ] Every repo under `~/Code` with unpushed commits or uncommitted work. Check all of them
      in one pass:

```bash
for d in ~/Code/*/; do
  [ -d "$d/.git" ] || continue
  dirty=$(git -C "$d" status --porcelain | wc -l | tr -d ' ')
  ahead=$(git -C "$d" log --branches --not --remotes --oneline 2>/dev/null | wc -l | tr -d ' ')
  [ "$dirty" != 0 ] || [ "$ahead" != 0 ] && echo "$(basename "$d"): $dirty dirty, $ahead unpushed"
done
```

- [ ] The Obsidian vault. It syncs over LiveSync and snapshots to battlestation, but confirm
      the snapshot actually landed before you wipe:

```bash
git -C ~/Code/obsidian-vault-setup status --porcelain
vault-snapshot
git -C ~/Code/obsidian-vault-setup log --oneline -1
git -C ~/Code/obsidian-vault-setup ls-remote backup | head -3
```

- [ ] `~/Code/obsidian-vault-setup/zz-secrets/` — confirm it is in the snapshot, since it is
      never in anything shared.
- [ ] Anything in `~/Downloads`, `~/Desktop`, `~/Documents` you care about.
- [ ] Browser profiles you have not synced.

### Data that does not survive the move  **STOP**

Different from backing up: Linux has no app that reads these, so the question is not "is it
safe" but "can I still reach it afterward". Verified on 2026-10-24 — Messages and Photos are
in iCloud and reach the phone and the other Macs, so neither needs action.

- [ ] **Messages** (~14 GB here) — confirm Messages in iCloud is on: Messages → Settings →
      iMessage → **Enable Messages in iCloud**. History then stays reachable from the phone
      and other Macs. Nothing on Linux reads the local SQLite store.
- [ ] **Photos** — confirm iCloud Photos is on. If it is not, this needs a full export before
      the wipe, not a backup.
- [ ] **Keychain** — Wi-Fi passwords, certificates, app credentials. Does not transfer, and
      iCloud Keychain only reaches Apple devices. Anything not already in 1Password is gone.
      Worth a pass through Passwords.app for logins that never made it over.
- [ ] **Notes, Reminders, Calendar, Contacts** — iCloud-backed, so reachable from the web and
      the phone, but not natively from Linux.
- [ ] **Authenticator apps / 2FA seeds** — if any TOTP codes live only in a Mac app, move them
      to 1Password first. This is the one that locks you out of accounts.

### Confirm you can get back in to everything

- [ ] 1Password: you know the account password and have the Secret Key / Emergency Kit
      **somewhere that is not this laptop**. Everything downstream depends on this.
- [ ] GitHub: 2FA recovery codes accessible from your phone.
- [ ] Keybase paperkey, if you still use it for GPG.

---

## Phase 1 — Rehearse in a VM (recommended, do it before the wipe)

This is worth the hour. It lets you get the dotfiles working against a real Arch system while
you still have a working machine. Two tiers, use both:

### Tier 1 — Arch container, for the dotfiles loop

Fast (seconds per iteration), no GUI, tests the package lists and the chezmoi templates.

```bash
open -a Docker            # the daemon is not running right now
docker run -it --rm -v "$HOME/.local/share/chezmoi:/src:ro" archlinux:base bash
```

Inside it:

```bash
pacman -Syu --noconfirm git sudo base-devel
useradd -m -G wheel bennie && echo '%wheel ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/wheel
su - bennie
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source /src
```

### Tier 2 — Omarchy in UTM, for the full desktop

This machine is Intel, so x86_64 guests run accelerated under Hypervisor.framework. An Apple
Silicon Mac could not do this nearly as well — use this one while you have it.

```bash
brew install --cask utm
```

- [ ] New VM → Virtualize → Linux → point at the Omarchy ISO
- [ ] 4 CPU, 8 GB RAM, 40 GB disk (sparse; you have 49 GB free, so keep an eye on it)
- [ ] Enable hardware acceleration; set display to `virtio-gpu-gl`

What the VM **will** tell you: the installer flow, whether the dotfiles apply cleanly, whether
Brave / 1Password / Citrix / Obsidian install and launch, what the Hyprland defaults feel like.

What it **will not** tell you: anything about T2 hardware — Wi-Fi, audio, Touch Bar, fans,
suspend, or the hybrid-GPU problem. Those only show up on the metal.

---

## Phase 2 — Build the installer USB

From this Mac, while it still boots:

- [ ] Download the ISO from <https://omarchy.org>. 4.0.6 is current as of 2026-10-24; do not
      use anything older than 4.0.5, which is the release that fixed T2 installs missing the
      Broadcom firmware fetcher.
- [ ] Verify it, rather than trusting the download:

```bash
cd ~/Downloads
curl -fLO https://iso.omarchy.org/omarchy-4.0.6.iso.sha256
shasum -a 256 -c omarchy-4.0.6.iso.sha256
```
- [ ] Write it with balenaEtcher, or:

```bash
diskutil list                       # find your USB, e.g. /dev/disk4
diskutil unmountDisk /dev/disk4
sudo dd if=~/Downloads/omarchy-4.0.6.iso of=/dev/rdisk4 bs=4m status=progress
sync
```

Gather the hardware too:

- [ ] USB-C hub **with Ethernet**, or a phone + cable for USB tethering
- [ ] USB-A/USB-C keyboard as a fallback. The Omarchy ISO ships `linux-t2`, so the internal
      keyboard and trackpad should work in the installer — but if they do not, you are stuck
      without one.
- [ ] Power adapter, plugged in, for the whole process

---

## Phase 3 — Disable Secure Boot  **STOP**

T2 Macs will not boot anything but macOS until you do this.

- [ ] Shut down
- [ ] Power on holding **Command-R** until the Apple logo appears, to enter Recovery
- [ ] Menu bar → **Utilities → Startup Security Utility**
- [ ] Authenticate with your admin password
- [ ] Secure Boot → **No Security**
- [ ] External Boot → **Allow booting from external or removable media**
- [ ] Quit, shut down

---

## Phase 4 — Install Omarchy

- [ ] Insert the USB and Ethernet adapter
- [ ] Power on holding **Option (⌥)** until the boot picker appears
- [ ] Select the orange **EFI Boot** drive
- [ ] Follow the installer. It will wipe the internal drive and set up full-disk encryption.

Pick a **disk encryption passphrase you can type on a US layout at boot**, before any of your
keymap settings exist. Write it down and put it in 1Password from your phone immediately.

On T2 hardware the installer handles automatically:

- the `linux-t2` kernel instead of Omarchy's default kernel
- `apple-bcm-firmware-fetcher` for Broadcom Wi-Fi and Bluetooth
- `apple-t2-audio-config`
- `t2fanrd` for fan control
- the NVMe suspend fix

When it finishes, **do not reboot into the desktop yet.** Go to Phase 5.

---

## Phase 5 — The hybrid graphics fix  **STOP — this model specifically**

Issue [#12593](https://github.com/omacom/omarchy/issues/12593) is open and lists
`MacBookPro15,1`. Symptom: you log in, the fans spin to maximum, the screen goes black, the
machine powers off. Apply the fix before the first login.

If you are already stuck in that loop: power on, and at the Limine boot menu press `e` to edit
the entry, append the kernel parameter below, and boot once. Or switch to a TTY with
**Ctrl+Alt+F2** and log in there.

Three layers. The third one alone was enough for at least one reporter, but apply all three.

**1. Kernel parameter** — Omarchy uses Limine:

```bash
sudo nano /boot/EFI/limine/limine.conf
```

Find the line with your kernel command line and append:

```
apple_gmux.force_igd=1
```

**2. Module option:**

```bash
echo 'options apple-gmux force_igd=y' | sudo tee /etc/modprobe.d/99-mbp-gmux.conf
```

**3. Hold the Radeon in low power** — this is the one that mattered most:

```bash
cat <<'EOF' | sudo tee /etc/udev/rules.d/99-amdgpu-lowpower.rules
SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="low"
EOF
```

Then:

```bash
sudo mkinitcpio -P
sudo reboot
```

If it boots to the desktop, you are past the worst of it.

> If a later Omarchy release ships this fix properly, these three files become redundant
> rather than harmful. Check issue #12593 before assuming you still need them.

---

## Phase 6 — Hardware checklist

Work through these and note what fails. Expect one or two to.

```bash
# Wi-Fi — firmware should already be fetched
sudo journalctl -k --grep=brcmfmac
nmcli device wifi list

# Audio (speakers are driven by a software DSP; start at low volume)
wpctl status
speaker-test -c2 -l1

# Fans
systemctl status t2fanrd

# Battery / thermals
cat /sys/class/power_supply/BAT0/capacity
sensors
```

| Thing | Expected | If it fails |
|---|---|---|
| Internal keyboard / trackpad | Works via `linux-t2` | Check `apple-bce` / `t2bce_vhci` loaded |
| Wi-Fi | Works after firmware fetch | Re-run the fetcher; see the [t2linux Wi-Fi guide](https://wiki.t2linux.org/guides/wifi-bluetooth/) |
| Bluetooth | **Partial.** BCM4377 glitches on 2.4 GHz | Prefer 5 GHz devices; interference with Wi-Fi is expected |
| Audio out | Works via `apple-t2-audio-config` | **Start quiet.** The T2 DSP can drive these speakers past safe excursion |
| Internal microphone | Works, but **low input volume** is a known T2 quirk | Raise the gain in `wpctl`; test on a real call before you rely on it |
| Touch Bar | Works via `tiny-dfr` | from the `arch-mact2` repo the T2 install configures, not the AUR; config at `/etc/tiny-dfr/config.toml` |
| Brightness | Via `apple-gmux` | Merged upstream in 4.0.0 |
| Webcam | **Works** via `t2bce` | Do not install `facetimehd-dkms` — that is the pre-T2 Broadcom 1570 camera, a different device, and the wrong driver here |
| Thunderbolt / USB-C | Works | May need `pcie_ports=native` as a kernel parameter |
| Suspend / lid close | **Flaky on T2.** Known unresolved | Set lid-close to lock, not suspend, in `/etc/systemd/logind.conf` |
| Touch ID | **Not available on this plan.** The sensor does work on T2 Macs, but only for fingers enrolled *in macOS*, and recovery after a panic or forced shutdown means booting macOS | No macOS means no enrolment and no recovery path. The `t2-touchid` package is Debian/Ubuntu-only as well. This is a consequence of the full wipe, not a hardware limit |

Suspend is the one most likely to annoy you daily. The pragmatic setting:

```bash
sudo sed -i 's/^#*HandleLidSwitch=.*/HandleLidSwitch=lock/' /etc/systemd/logind.conf
sudo systemctl restart systemd-logind
```

---

## Phase 7 — Get your identity back

Order matters — 1Password gates everything else.

- [ ] Install 1Password and the CLI:

```bash
omarchy pkg aur add 1password 1password-cli
```

- [ ] Sign in. You will need the account password **and** the Secret Key from your Emergency
      Kit.
- [ ] Settings → Developer → enable **Use the SSH agent** and **Integrate with 1Password CLI**
- [ ] Confirm the agent socket is at `~/.1password/agent.sock` (the Linux path — the dotfiles
      already point there) and that keys show up:

```bash
ssh-add -l
```

- [ ] `op signin`, then test: `op read "op://Private/<item>/public key"`
- [ ] Export the second GitHub account's public key, since the repo ships no key material:

```bash
op read "op://Private/<item>/public key" > ~/.ssh/github_<alias>.pub
```

- [ ] `gh auth login` for each GitHub account
- [ ] Recreate `~/.config/git/allowed_signers` — one `<email> <keytype> <key>` per line:

```bash
mkdir -p ~/.config/git
printf '%s %s\n' "you@example.com" "$(op read 'op://Private/<ssh item>/public key')" \
  >> ~/.config/git/allowed_signers
```

---

## Phase 8 — Dotfiles

The Linux branch of these dotfiles currently assumes **apt and snap**. Arch needs a pacman +
AUR branch, which is being added on a separate branch — use it rather than `main` until it is
merged.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
chezmoi init https://github.com/benniemosher/dotfiles.git --branch feature/arch-omarchy-support
chezmoi diff        # read this properly before applying
chezmoi apply
```

`chezmoi init` will ask the questions from Phase 0's backup list again:

| Question | Your answer |
|---|---|
| Git commit email | from the saved `chezmoi.toml` |
| Is this a work machine | **no** — this is personal |
| Use the 1Password SSH agent | **yes** |
| Phone number / address for invoices | from the saved `chezmoi.toml` |
| 1Password item for Obsidian LiveSync | `op://<vault>/<item id>` from the saved config |
| Git remote for vault snapshots | `ssh://battlestation-ubuntu.local/data/backups/obsidian-vault.git` |

Things that change on Omarchy, by your own choice to adopt its defaults:

- **Shell is bash**, not zsh. `dot_zshrc.tmpl`'s content needs a bash equivalent so Omarchy's
  aliases, theming, and `omarchy-*` tooling keep working.
- **Terminal is Omarchy's**, not WezTerm, so the theme switcher drives it.
- **Window manager is Hyprland**, so Amethyst is gone.
- **Starship** is still there, from `pacman`, not a curl installer.

---

## Phase 9 — Apps

### Straight swaps

```bash
omarchy pkg aur add brave-bin obsidian slack-desktop keybase-bin \
  visual-studio-code-insiders-bin wezterm
sudo pacman -S docker docker-compose tmux neovim fzf jq tree yq \
  kubectl kubectx kustomize github-cli shellcheck pre-commit
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"      # log out and back in
```

`mise` installs the rest (awscli, checkov, k9s, terraform, node, python) exactly as it does
today — `dot_config/mise/config.toml.tmpl` is unchanged.

### Citrix Workspace app

AUR `icaclient`, version 26.04.10.1 as of September 2026, actively maintained.

```bash
omarchy pkg aur add icaclient
```

Two things will go wrong if you do not pre-empt them:

**1. It crashes as a native Wayland client.** Force it onto XWayland:

```bash
mkdir -p ~/.local/share/applications
sed 's|^Exec=|Exec=env GDK_BACKEND=x11 |' \
  /usr/share/applications/wfica.desktop > ~/.local/share/applications/wfica.desktop
```

If it still crashes, disable hardware acceleration — set `HwAcceleration=False` in
`~/.ICAClient/wfclient.ini`.

**2. Certificates.** Since 13.1 Citrix wants root CAs as separate files in its own store, not
the system bundle:

```bash
sudo ln -s /etc/ca-certificates/extracted/cadir/* /opt/Citrix/ICAClient/keystore/cacerts/
sudo /opt/Citrix/ICAClient/util/ctx_rehash
```

**HiDPI warning:** this is a 2880×1800 panel and XWayland cannot scale per-window. Citrix will
be either blurry or tiny. Options, in order of how well they work: set the session's DPI inside
Citrix (`DPIMatchingEnabled`), run Citrix on a 1× external monitor, or fall back to the
browser-based HTML5 receiver if your client offers one. Test this **before** you need it for
real work.

### Obsidian + the vault

- [ ] Install Obsidian (above)
- [ ] `chezmoi apply` runs `run_once_setup-obsidian-vault.sh`, which builds the PARA skeleton,
      installs the LiveSync plugin, and feeds it the setup URI from 1Password
- [ ] The passphrase prompt is **attended** — the script puts it on your clipboard, you paste
      it. Clear the clipboard after.
- [ ] Accept the imported settings, let the first replication finish
- [ ] Then `bin/install-obsidian-plugins.sh` for the remaining plugins, and pick the Minimal
      theme
- [ ] Confirm `vault-snapshot` is running: `systemctl --user list-timers vault-snapshot.timer`

### No Linux equivalent — decide what to do

| macOS app | Status |
|---|---|
| Grammarly Desktop | **No Linux app exists.** Browser extension only |
| Sequel Ace | Gone — use DBeaver or Beekeeper Studio |
| SourceTree | Gone — use `lazygit`, or the `gh`/`glab` CLIs you already use |
| Amethyst | Replaced by Hyprland |
| Docker Desktop | Replaced by native Docker Engine, which is better here anyway |
| `mas`, `defaultbrowser`, `pinentry-mac` | macOS-only, no equivalent needed |

---

## Phase 10 — Verify before you call it done

```bash
git -C ~/.local/share/chezmoi status      # dotfiles clone healthy
ssh -T git@github.com                     # 1Password agent signing
git log --show-signature -1               # commit signature verification
mise current                              # runtimes installed
standup "migrated to Omarchy"             # vault write path works
hours 0.1 "test"                          # billing path works (then delete the row)
```

- [ ] Suspend / resume, twice
- [ ] Close the lid, reopen
- [ ] Reboot and unlock the encrypted disk
- [ ] Audio out and mic
- [ ] Wi-Fi survives a suspend cycle
- [ ] Citrix connects to a real session
- [ ] Battery life over a normal working hour — the Radeon is the main thing to watch

---

## If it will not boot at all

The T2 means the usual Linux recovery tricks are not the whole story.

1. **Boot picker**: hold **Option (⌥)** at power-on. If Omarchy is listed, pick it and use the
   Limine menu (`e`) to boot with modified parameters.
2. **Limine fallback entry**: boot an older kernel from the menu.
3. **Live USB**: boot the Omarchy ISO, unlock and `arch-chroot` into the install to fix config.
4. **DFU revive from another Mac** — this is why Phase 0 matters. On one of your other Macs,
   install Apple Configurator, connect via the correct USB-C port (the one nearest the
   display on the left side), and **Revive** the device. Revive preserves data; Restore wipes
   it. With Activation Lock signed out this is clean; with it on, you need the Apple ID.
5. **Reinstall macOS**: Internet Recovery with **Command-Option-R**. Works even with the drive
   wiped, as long as Secure Boot being off has not been changed — and it downloads from Apple
   over the network.

---

## Sources

- [Omarchy Mac support manual](https://omarchy.org/manual/mac-support/)
- [Omarchy discussion #773 — Intel T2 MacBooks](https://github.com/omacom/omarchy/discussions/773)
- [Omarchy issue #12593 — hybrid graphics black screen (open)](https://github.com/omacom/omarchy/issues/12593)
- [t2linux wiki — pre-install](https://wiki.t2linux.org/guides/preinstall/)
- [t2linux wiki — basic post-install setup](https://wiki.t2linux.org/guides/postinstall/)
- [t2linux wiki — Wi-Fi and Bluetooth firmware](https://wiki.t2linux.org/guides/wifi-bluetooth/)
- [t2linux wiki — Arch installation](https://wiki.t2linux.org/distributions/arch/installation/)
- [t2linux wiki — device support and state of features](https://wiki.t2linux.org/state/)
- [t2linux wiki — Touch ID](https://wiki.t2linux.org/guides/touchid/)
- [ArchWiki — Citrix](https://wiki.archlinux.org/title/Citrix)
- [AUR — icaclient](https://aur.archlinux.org/packages/icaclient)
- [ArchWiki — 1Password](https://wiki.archlinux.org/title/1Password)

Written 2026-10-23. Omarchy moves fast — re-check issue #12593 and the Mac support page before
you start.
