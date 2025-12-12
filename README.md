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
- Similar toolset adapted for Linux package managers

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

```bash
# Install Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essentials
brew install gh chezmoi

# Authenticate with GitHub
gh auth login
```

### Phase 2: Initialize chezmoi

```bash
# Clone and initialize dotfiles
chezmoi init git@github.com:benniemosher/dotfiles-2024.git

# Preview what will be changed (optional but recommended)
chezmoi diff

# Apply dotfiles
chezmoi apply
```

### Phase 3: Configure 1Password (Required for SSH/GPG)

1. Open **1Password** app
2. Go to **1Password Menu > Settings > Developer**
3. Enable:
   - "Use the SSH agent"
   - "Integrate with 1Password CLI"
4. Sign in to CLI:
   ```bash
   op signin
   ```

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
