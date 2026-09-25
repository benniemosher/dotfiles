# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io/), featuring [Starship](https://starship.rs/) prompt and [LazyVim](https://www.lazyvim.org/).

## What's Included

### Packages

**macOS (Homebrew):**
- Terminal: `wezterm`, `starship`, `tmux`, `neovim`, `fzf`
- DevOps: `awscli`, `argocd`, `kubernetes-cli`, `kubectx`, `kustomize`, `kubeseal`, `stern`, `docker-desktop`
- Infrastructure: `checkov`, `tfsort`, `terraform` (via mise)
- Tools: `gh`, `chezmoi`, `mise`, `pre-commit`, `gnupg`, `1password-cli`
- Apps: `1password`, `brave-browser`, `slack`, `notion`, `amethyst`, `grammarly-desktop`, `keybase`

**Linux (apt/snap):**
- Terminal: `starship`, `neovim`, `fzf`, `zsh` with autosuggestions
- DevOps: `kubectl`, `kubectx`, `k9s`, `docker`
- Build: `build-essential`, `gcc`, and the `lib*-dev` headers mise needs to compile runtimes
- Tools: `gh`, `chezmoi`, `mise`, `pre-commit`, `shellcheck`, `jq`, `gnupg`
- Apps (snap): `1password`, `brave`, `slack`, `keybase`

### Profiles

Every package list is split into `work` and `personal`. `work` installs everywhere; `personal`
installs only on machines without `work_platform`, so a personal machine gets both. The
profile is chosen once, when you run `chezmoi init`, and stored in
`~/.config/chezmoi/chezmoi.toml`.

A work machine also skips the Keybase GPG import (it generates its own signing key instead)
and uses a plain `~/.ssh/id_ed25519` rather than the 1Password SSH agent.

To change profile later, edit that file and re-apply:

```toml
[data]
git_email = "you@company.com"
work_platform = true
work_workspace = "mycompany"    # the ~/Code/<name> directory
```

### Configurations

- Shell: `zsh` with Starship prompt, aliases, and completions
- Editor: LazyVim (Neovim) with custom configs
- Git: Global gitconfig with GPG signing
- Terminal: WezTerm configuration
- Window Manager: Amethyst (macOS tiling)
- Version Manager: mise for runtime versions (Node, Python, Ruby, Go, Terraform, etc.)

### macOS Settings

Applies sensible defaults including:
- Dark mode, keyboard settings, trackpad configuration
- Finder preferences (show extensions, hidden files)
- Dock settings (autohide, icon size)
- Security settings (firewall, screen lock)
- And 400+ other tweaks

## Prerequisites

- **macOS** (primary) or **Linux** (Ubuntu/Debian)
- Admin/sudo access
- Internet connection

## Installation

### Phase 1: Bootstrap

**macOS:**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gh chezmoi
gh auth login
```

**Ubuntu Desktop:**

```bash
sudo apt-get update
sudo apt-get install -y curl git

# chezmoi's own installer rather than apt -- the archived apt version lags badly.
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# gh is not in Ubuntu's default repos
sudo snap install gh
gh auth login
```

### Phase 2: Initialize chezmoi

```bash
chezmoi init git@github.com:benniemosher/dotfiles-2024.git
```

This asks for your git email and whether the machine is a work machine, then writes
`~/.config/chezmoi/chezmoi.toml`. Answer carefully — the work answer decides which packages
install and how SSH and GPG are set up. It only asks once; re-running `init` later keeps your
answers.

```bash
chezmoi diff     # preview (recommended)
chezmoi apply
```

On Ubuntu the first apply is slow: it installs the apt and snap lists, and snaps in particular
take a few minutes.

### Phase 3: Configure 1Password (Required for SSH/GPG)

Personal machines only — work machines use `~/.ssh/id_ed25519` instead.

1. Open the **1Password** app (on Ubuntu: `sudo snap install 1password`, installed by Phase 2)
2. Go to **1Password Menu > Settings > Developer**
3. Enable:
   - "Use the SSH agent"
   - "Integrate with 1Password CLI"
4. Sign in to CLI:
   ```bash
   op signin
   ```

The agent socket differs by OS and the dotfiles already point at the right one —
`~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` on macOS,
`~/.1password/agent.sock` on Linux. Check it took with `ssh-add -l`.

### Phase 4: Final Apply

```bash
# Re-apply to pick up 1Password-managed secrets
chezmoi apply

# Restart your terminal (or start WezTerm)
```

## Post-Installation

### Optional: GPG/Keybase Setup

If you use Keybase for GPG keys, create `~/.profile.local`:

```bash
export KEYBASE_USERNAME="your-username"
export KEYBASE_PAPERKEY="your-paperkey"
export KEYBASE_KEY_ID="your-key-id"
```

Then run `chezmoi apply` again.

### Symlink for Development

The repo is cloned to `~/.local/share/chezmoi`. A symlink is automatically created at `~/Code/dotfiles`.

## Usage

### Common Commands

```bash
# Pull latest changes and apply
chezmoi update

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Edit a managed file
chezmoi edit ~/.zshrc

# Add a new file to management
chezmoi add ~/.some-config

# Go to the source directory
chezmoi cd
```

### Adding New Packages

Edit `.chezmoidata/packages.yaml`:

```yaml
packages:
  darwin:
    brews:
      - "new-package"
    casks:
      - "new-app"
```

Then run `chezmoi apply`.

## Troubleshooting

### "Permission denied" errors
Ensure you have admin access and try with `sudo` where appropriate.

### 1Password SSH agent not working
1. Verify 1Password settings (Developer > SSH agent enabled)
2. Check `~/.config/1Password/ssh/agent.toml` exists
3. Restart 1Password and terminal

### GPG signing failures
1. Ensure GPG agent is running: `gpgconf --launch gpg-agent`
2. Verify key is available: `gpg --list-secret-keys`

### Homebrew packages failing
```bash
brew update && brew upgrade
brew doctor
```

## Structure

```
.
├── .chezmoidata/          # Data files (packages, settings)
├── dot_config/            # ~/.config files
├── dot_zshrc.tmpl         # Shell configuration
├── dot_gitconfig.tmpl     # Git configuration
├── dot_wezterm.lua        # Terminal configuration
├── private_dot_ssh/       # SSH configuration
├── private_dot_gnupg/     # GPG configuration
└── run_onchange_*.sh.tmpl # Install/setup scripts
```

## License

Personal dotfiles - feel free to use as inspiration for your own setup.
