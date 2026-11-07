# Omarchy on the 2018 MacBook Pro

Omarchy replaced macOS on this machine on 2026-11-04. No macOS, no dual boot. This records
what the machine is, what needed doing by hand, and how to rebuild it.

Reusable findings live in the vault instead of here:
`T2-Mac-Linux-WiFi-Needs-Firmware-Extracted-From-macOS`,
`dd-conv-fsync-Looks-Hung-At-The-End`, `Moving-Dotfiles-To-XDG-Paths-Needs-chezmoi-remove`.

## This machine

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
produce a working adapter. Extract it from a Mac still running macOS with t2linux's
`firmware.sh create_archive`, copy the tarball over, unpack into `/lib/firmware/brcm`, reload
`brcmfmac`. Do this before wiping the only macOS machine you have, or you are downloading a
recovery image to get a 12 MB file.

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
