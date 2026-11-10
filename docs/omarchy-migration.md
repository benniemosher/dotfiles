# Omarchy on a T2 MacBook Pro

Omarchy replaced macOS on the first of these machines on 2026-11-04 (`omarchy-mbp-1`). No
macOS, no dual boot. This records what the machine is, what needed doing by hand, and how to
do the next one.

Both MacBook Pros here are `MacBookPro15,1`, so everything below applies to either.

Reusable findings live in the vault instead of here:
`T2-Mac-Linux-WiFi-Needs-Firmware-Extracted-From-macOS`,
`dd-conv-fsync-Looks-Hung-At-The-End`, `Moving-Dotfiles-To-XDG-Paths-Needs-chezmoi-remove`.

## Before wiping a Mac  **do not skip this**

The second machine still runs macOS as of 2026-11-07, and is the last one that does. Work
down this list before starting.

### Sign out of Apple's services

Activation Lock is **enabled** on it. Wipe without signing out and a future DFU revive of the
T2 can be blocked.

- System Settings → your name → **Sign Out** of iCloud
- Confirm Find My Mac is off
- Verify, which should now say `Disabled`:

```bash
system_profiler SPHardwareDataType | grep -i "activation lock"
```

### Save the things no sync or backup covers

- **The Wi-Fi firmware tarball** — already saved, as the 1Password document
  **`T2 Mac Wi-Fi Firmware (BCM4364)`**. Nothing to do here beyond knowing where it is.

  Why it had to be saved: this is the last macOS machine, and Apple's BCM4364 firmware is not
  redistributable, so no distro ships it and after the wipe there is nothing left to extract
  from. It is not in git either — this repo is public and the firmware is Apple's. To use it:

  ```bash
  sudo tar -xf firmware.tar -C /lib/firmware/brcm
  sudo modprobe -r brcmfmac_wcc; sudo modprobe -r brcmfmac; sudo modprobe brcmfmac
  sudo journalctl -k --grep=brcmfmac    # want a firmware version line
  ```

  The fallback without it is t2linux's `firmware.sh` option 5, which downloads a macOS
  recovery image to recover 12 MB.
- **`~/.config/chezmoi/chezmoi.toml`** — never committed. Holds `git_email`,
  `invoice_phone`, `invoice_address`, the vault backup remote, and the `op://` references for
  LiveSync and the Pexels key. `chezmoi init` asks for all of it again, so either copy the
  file or know the answers.
- **`~/.config/git/allowed_signers`** — deliberately unmanaged; lists work addresses.
- **`~/.zshrc.local`** — machine-local shell overrides.
- **`zz-secrets/`** in the vault — in neither git nor LiveSync, so nothing carries it. Each
  item needs to be in 1Password first; `vault-secrets` then redeploys it after. Earlier
  versions of this runbook said to confirm it was "in the snapshot", which `.gitignore` makes
  impossible.
- **Unpushed work under `~/Code`:**

```bash
for d in ~/Code/*/; do
  [ -d "$d/.git" ] || continue
  dirty=$(git -C "$d" status --porcelain | wc -l | tr -d ' ')
  ahead=$(git -C "$d" log --branches --not --remotes --oneline 2>/dev/null | wc -l | tr -d ' ')
  [ "$dirty" != 0 ] || [ "$ahead" != 0 ] && echo "$(basename "$d"): $dirty dirty, $ahead unpushed"
done
```

### Confirm the vault has nothing only on this machine

battlestation is the vault's source of truth, not the Mac. LiveSync only runs inside a
running Obsidian, so a Mac with Obsidian closed has been diverging for however long it has
been closed. Open Obsidian, let it settle, then compare file lists rather than counts —
`LC_ALL=C` because macOS and GNU `sort` disagree on collation and `comm` otherwise lies:

```bash
V=~/Code/obsidian-vault-setup
(cd "$V" && find . -name '*.md' -not -path './.obsidian/*' | sed 's|^\./||' | LC_ALL=C sort) > /tmp/here.txt
ssh battlestation-ubuntu.local "cd ~/Code/obsidian-vault-setup && find . -name '*.md' -not -path './.obsidian/*' | sed 's|^\./||' | LC_ALL=C sort" > /tmp/bs.txt
LC_ALL=C comm -23 /tmp/here.txt /tmp/bs.txt
```

`zz-secrets/*` is the only acceptable output. Anything else is a note that exists nowhere
else yet.

### Data that does not survive the move

Different from backing up: Linux has no app that reads these, so the question is whether you
can still reach them afterwards.

- **Messages** — confirm Messages in iCloud is on, so history stays reachable from the phone.
  Nothing on Linux reads the local store.
- **Photos** — confirm iCloud Photos is on. If not, this needs a full export, not a backup.
- **Keychain** — Wi-Fi passwords, certificates, app credentials. Does not transfer, and
  iCloud Keychain only reaches Apple devices. Anything not already in 1Password is gone.
- **Notes, Reminders, Calendar, Contacts** — iCloud-backed, reachable from the web and the
  phone, not natively from Linux.
- **Authenticator apps and TOTP seeds** — if any live only in a Mac app, move them to
  1Password first. This is the one that locks you out of accounts.

### Confirm you can get back in

- 1Password: you know the account password and have the Secret Key somewhere that is **not**
  this laptop. Everything downstream depends on it.
- GitHub: 2FA recovery codes reachable from your phone.
- Keybase paperkey, if you still use it for GPG.

## The hardware

Both machines are the same model, which is why one runbook covers them. The table describes
`omarchy-mbp-1`, already migrated; the second is identical apart from a 251 GB disk still
holding macOS.

| | |
|---|---|
| Model | `MacBookPro15,1` — 15-inch, 2018 |
| CPU / RAM | 6-core Intel i7-9750H, 16 GB |
| GPU | Intel UHD 630 + AMD Radeon Pro 555X (Baffin, `1002:67ef`) |
| Wi-Fi | BCM4364 (`14e4:4464`) |
| Disk | 234 GB NVMe, LUKS, btrfs root |
| T2 | Yes |
| Hostname | `omarchy-mbp-1`, fixed at 192.168.87.87 on the homelab VLAN |

Omarchy 4.0.6 ships the `linux-t2` kernel, so the T2 hardware works without the t2linux repo.
Check `uname -r` for a `-t2` suffix before reaching for it.

## What needed doing by hand

**Wi-Fi firmware.** This is the only thing that did not work after install. Apple's BCM4364
firmware is not redistributable, so no package ships it — `apple-bcm-firmware-fetcher` did not
produce a working adapter. The tarball is in 1Password as
**`T2 Mac Wi-Fi Firmware (BCM4364)`**; unpack it into `/lib/firmware/brcm` and reload
`brcmfmac`. To regenerate it from a Mac still running macOS, use t2linux's
`firmware.sh create_archive` — but there will not be one after this.

**Secure Boot.** T2 Macs refuse external boot by default. Command-R into Recovery, Startup
Security Utility, Secure Boot to **No Security**, allow booting from external media.

**Boot patience.** The installer USB sat on a black screen for two to three minutes before
drawing anything, because archiso reads a large squashfs at USB 2.0 speed. Wait before
reaching for `nomodeset`.

## Hardware status

Measured on 2026-11-04, not inferred.

| Thing | State |
|---|---|
| Internal keyboard, trackpad | Works (`linux-t2`) |
| Touch Bar | Works (`hid_appletb_kbd`, `hid_appletb_bl`) |
| Audio out and microphone | Works. T2 codec is the default PipeWire sink. Start quiet — the DSP can drive these speakers hard |
| Wi-Fi | Works once the firmware above is in place |
| Bluetooth | Works. Controller present, service active. UART-attached on this model, so the PCIe `brcmbt` firmware missing from the tarball does not matter |
| Fans | Works. `t2fanrd` active, ~2100 RPM idle, 47–50 °C |
| Both GPUs | `i915` and `amdgpu` both bound; T2 bridge on `t2bce_core` |
| Webcam | Works, `/dev/video0`. Do not install `facetimehd-dkms` — wrong device |
| Suspend and resume | Works. Clean `suspend entry (deep)` / `suspend exit`. The panel needs a keypress to repaint, which looks like a hang and is not |
| Brightness | Works (`apple-gmux`) |
| Touch ID | Unavailable. The sensor needs fingers enrolled in macOS, and there is no macOS here |

The log carries `brcmf_p2p` and `p2p-dev-wlp3s0` errors on every boot. That is Wi-Fi Direct,
which this firmware does not support. Normal Wi-Fi is unaffected.

## Trackpad, mouse, and AirPods

Added 2026-11-10. Chezmoi sets everything that can be set. Pairing cannot be tracked, because
the keys live under `/var/lib/bluetooth`, so it is a manual step on each machine.

| Thing | What chezmoi does |
|---|---|
| Trackpad | `dot_config/hypr/input.lua` sets `clickfinger_behavior = true`. The click type then depends on finger count, not position. By area, a click near the bottom middle is a middle click, and in a browser that closes the tab. |
| Magic Mouse | `run_onchange_arch-magicmouse.sh.tmpl` writes `/etc/modprobe.d/hid-magicmouse.conf` with `emulate_3button=N` and sets the live value. By default a click in the middle of the mouse surface is a middle click. The script needs `sudo`, so run `chezmoi apply` from a terminal. |
| AirPods Pro | `dot_config/wireplumber/wireplumber.conf.d/bluetooth-no-headset-autoswitch.conf` turns off `bluetooth.autoswitch-to-headset-profile`. Without it, WirePlumber switches the AirPods to the low-quality headset profile whenever an app records. The microphone here is the MacBook mic or the Logitech webcam. |

To pair, by hand:

1. Put the AirPods in the case, open the lid, and hold the button on the back until the light
   flashes white. Disconnect them from the iPhone first, or they may jump back to it.
2. Run `bluetoothctl --timeout 15 scan on`, then `bluetoothctl devices`. They appear as
   `AirPods Pro - Find My`.
3. `bluetoothctl pair <address>`, then `trust`, then `connect`.
4. Check `pactl list cards | grep -A40 bluez_card | grep 'Active Profile'` says `a2dp-sink`.
5. WirePlumber does not move the default output to them. Pick them in the audio menu.

The Magic Mouse pairs the same way, without holding a button. After pairing it,
`cat /sys/module/hid_magicmouse/parameters/emulate_3button` should print `N`.

## Hybrid graphics

Omarchy issue [#12593](https://github.com/omacom/omarchy/issues/12593) reports full-speed
fans, a black screen and shutdown after first login on T2 Macs, and is still open. **It did
not happen on this machine.** 4.0.6 booted to the desktop with no workaround, and the original
report is 4.0.4 while the second is a `MacBookPro16,1` with a different GPU.

Treat the workaround as a contingency. If you hit that loop: at the Limine menu press `e` and
append `apple_gmux.force_igd=1` for one boot, or reach a TTY with **Ctrl+Alt+F2**. Omarchy now
has `omarchy toggle hybrid gpu`, which drives supergfx — try that before hand-editing
`limine.conf`. Holding the Radeon at low power through a udev rule on
`power_dpm_force_performance_level` is what helped the reporters most.

## Where the dotfiles defer to Omarchy

Omarchy owns these; the dotfiles do not deploy their own:

- **tmux** — its config is a superset of ours, and `omarchy-update` migrations edit the file in
  place, so deploying ours would fight them. Arch gives up OSC 8 hyperlinks and the `|` and `-`
  split binds.
- **nvim** `lua/config/{options,autocmds,keymaps}.lua` — ours are empty; Omarchy's `options.lua`
  sets up `remote_clipboard`, which carries yanks over SSH.
- **Terminal and window manager** — Omarchy's terminal, themed by its switcher, and Hyprland.
  No WezTerm, no Amethyst.
- **Hack fonts** — the terminal uses JetBrainsMono Nerd Font.
- **mise the binary** — Omarchy's `mise-bin` conflicts with the repo package and fails the whole
  pacman transaction. The dotfiles still own the tool list.

And where Omarchy's opinions were adopted into the repo instead, so every machine shares them:

- **Shell is zsh**, via Omarchy's own `omarchy-zsh` package. `dot_zshrc.tmpl` sources its
  `zoptions` and `shell/all`, which bring the aliases, functions, envs and tool init. Do not run
  `omarchy-setup-zsh` — it overwrites `~/.zshrc` and `~/.bashrc` from its templates, and chezmoi
  owns those.
- **starship** — Omarchy's prompt design, plus our kubernetes module.
- **git** — nine of its defaults (`rerere`, histogram diffs, `push.autoSetupRemote`, branch and
  tag sort, `commit.verbose`, `column.ui`) copied into the template rather than included on one
  machine.
- **mise settings** — `codex`, and `auto_prune` on upgrade.

## Rebuilding this machine

1. Sign out of iCloud first and confirm `Activation Lock Status: Disabled`. Skipping this can
   block a later DFU revive.
2. Extract the Wi-Fi firmware from a macOS machine while you still have one.
3. Write the ISO: `sudo dd if=omarchy-X.Y.Z.iso of=/dev/sdX bs=4M status=progress oflag=direct
   conv=fsync`. Never repartition a hybrid-ISO stick from macOS; `diskutil` cannot see the
   ISO9660 partition and may drop it.
4. Disable Secure Boot, hold Option at power-on, pick **EFI Boot**.
5. Install. Choose a LUKS passphrase you can type on a US layout, before any keymap settings
   exist, and put it in 1Password from your phone immediately.
6. Install the Wi-Fi firmware. Ethernet or USB tethering until then.
7. 1Password first — it gates everything else. `omarchy pkg aur add 1password 1password-cli`,
   sign in with the Secret Key, enable the SSH agent and CLI integration under Developer,
   confirm `ssh-add -l`. Then `gh auth login` per account, and recreate
   `~/.config/git/allowed_signers`, which is deliberately unmanaged.
8. `chezmoi init --apply`. The Arch path keys off `ID_LIKE`, because Omarchy reports
   `ID=omarchy`.
9. Obsidian and the vault: `run_once_setup-obsidian-vault.sh` builds the PARA skeleton and
   feeds LiveSync the setup URI from 1Password. The passphrase prompt is attended — the script
   puts it on your clipboard. Clear the clipboard afterwards. Then
   `bin/install-obsidian-plugins.sh`, and confirm
   `systemctl --user list-timers vault-snapshot.timer`.

10. Pair the Magic Mouse and the AirPods by hand (see Trackpad, mouse, and AirPods). Chezmoi
    only sets how they behave once paired.

Worth keeping off this machine and in 1Password: `~/.config/chezmoi/chezmoi.toml` is not
committed and holds the invoice and LiveSync answers `chezmoi init` asks for.

Verify with `ssh -T git@github.com`, `git log --show-signature -1`, `mise current`, a
`standup` write, and a suspend cycle.

## Citrix Workspace

AUR `icaclient`. Two things break without pre-empting them.

It crashes as a native Wayland client, so force XWayland:

```bash
mkdir -p ~/.local/share/applications
sed 's|^Exec=|Exec=env GDK_BACKEND=x11 |' \
  /usr/share/applications/wfica.desktop > ~/.local/share/applications/wfica.desktop
```

If it still crashes, set `HwAcceleration=False` in `~/.ICAClient/wfclient.ini`.

Since 13.1 it wants root CAs as separate files in its own store, not the system bundle:

```bash
sudo ln -s /etc/ca-certificates/extracted/cadir/* /opt/Citrix/ICAClient/keystore/cacerts/
sudo /opt/Citrix/ICAClient/util/ctx_rehash
```

This is a 2880×1800 panel and XWayland cannot scale per-window, so Citrix will be blurry or
tiny. Set the session DPI inside Citrix (`DPIMatchingEnabled`), use a 1× external monitor, or
fall back to the HTML5 receiver. Test it before you need it.

## No Linux equivalent

| macOS app | Replacement |
|---|---|
| Grammarly Desktop | Browser extension only |
| Sequel Ace | DBeaver or Beekeeper Studio |
| SourceTree | `lazygit`, or the `gh`/`glab` CLIs |
| Amethyst | Hyprland |
| Docker Desktop | Native Docker Engine |
| `mas`, `defaultbrowser`, `pinentry-mac` | macOS-only, nothing needed |

## If it will not boot

1. Hold **Option** at power-on. If Omarchy is listed, use the Limine menu (`e`) to boot with
   modified parameters.
2. Boot an older kernel from the Limine fallback entry.
3. Boot the Omarchy ISO, unlock, and `arch-chroot` in to fix config.
4. DFU revive from another Mac with Apple Configurator, via the USB-C port nearest the display
   on the left. **Revive** preserves data; Restore wipes it. Clean if Activation Lock is off.
5. Internet Recovery with **Command-Option-R** reinstalls macOS over the network, even with the
   drive wiped.

## Sources

- [Omarchy Mac support manual](https://omarchy.org/manual/mac-support/)
- [Omarchy issue #12593 — hybrid graphics black screen (open)](https://github.com/omacom/omarchy/issues/12593)
- [omarchy-zsh](https://github.com/omacom-io/omarchy-zsh) and [omadots](https://github.com/omacom-io/omadots)
- [t2linux — Wi-Fi and Bluetooth firmware](https://wiki.t2linux.org/guides/wifi-bluetooth/)
- [t2linux — device support](https://wiki.t2linux.org/state/)
- [ArchWiki — Citrix](https://wiki.archlinux.org/title/Citrix)
