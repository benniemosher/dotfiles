# Dotfiles - Project Memory

This file contains persistent context for Claude Code sessions on this project.
It will be automatically loaded at the start of every session.

## Project Overview

Personal dotfiles managed with chezmoi, featuring Starship prompt, LazyVim, and
comprehensive macOS/Linux configuration automation.

**Key Details:**

- **Management Tool:** chezmoi
- **Shell:** zsh with Starship prompt
- **Editor:** LazyVim (Neovim)
- **Terminal:** WezTerm
- **Version Manager:** mise (Node, Python, Ruby, Go, Terraform, etc.)
- **Secrets:** 1Password CLI integration
- **Platforms:** macOS (primary), Linux (Ubuntu/Debian)

## Repository Structure

```text
dotfiles/
├── .chezmoidata/              # Data files for templates
│   ├── packages.yaml          # Homebrew/apt/snap packages
│   └── macos-settings.yaml    # macOS defaults settings
├── .chezmoiexternal.toml      # External dependencies (LazyVim, etc.)
├── .chezmoiignore             # Files to ignore during apply
├── dot_config/                # ~/.config files
│   ├── 1Password/             # 1Password SSH agent config
│   ├── mise/                  # mise version manager config
│   ├── nvim/                  # LazyVim configuration
│   └── starship.toml          # Starship prompt config
├── dot_zshrc.tmpl             # Shell configuration (templated)
├── dot_gitconfig.tmpl         # Git configuration (templated)
├── dot_wezterm.lua            # WezTerm terminal config
├── private_dot_ssh/           # SSH configuration (1Password managed)
├── private_dot_gnupg/         # GPG configuration
├── private_Library/           # macOS Library files
├── run_onchange_*.sh.tmpl     # Install/setup scripts
└── bin/                       # Custom scripts
```

## Chezmoi Patterns

### File Naming Conventions

- `dot_` prefix becomes `.` (e.g., `dot_zshrc` -> `.zshrc`)
- `private_` prefix sets restrictive permissions (600)
- `.tmpl` suffix indicates Go template processing
- `run_onchange_` scripts run when their content changes
- `run_once_` scripts run only on first apply

### Template Variables

Templates have access to:

- `.chezmoi.os` - Operating system (darwin, linux)
- `.chezmoi.arch` - Architecture (amd64, arm64)
- `.chezmoi.hostname` - Machine hostname
- Custom data from `.chezmoidata/*.yaml`

### Adding New Packages

Edit `.chezmoidata/packages.yaml`:

```yaml
packages:
  darwin:
    brews:
      - "package-name"
    casks:
      - "app-name"
  linux:
    apts:
      - "package-name"
    snaps:
      - "snap-name"
```

## Development Workflow

### Common Commands

```bash
# Preview changes before applying
chezmoi diff

# Apply dotfiles
chezmoi apply

# Pull latest and apply
chezmoi update

# Edit a managed file (opens source, not target)
chezmoi edit ~/.zshrc

# Add a new file to management
chezmoi add ~/.some-config

# Go to source directory
chezmoi cd

# Re-add a file after manual changes
chezmoi re-add ~/.some-config
```

### Testing Changes

1. Make changes to source files in `~/.local/share/chezmoi`
2. Run `chezmoi diff` to preview what will change
3. Run `chezmoi apply` to apply changes
4. Test the changes work as expected

### Git Workflow

1. **Create feature branch:** `git checkout -b feature/description`
2. **Make changes** to dotfiles
3. **Run pre-commit hooks:** `pre-commit run --all-files`
4. **Commit with conventional format:** `git commit -m "type: description"`
5. **Push and create PR:** `gh pr create --title "feat: description"`

**Commit Format:** Conventional Commits

- `feat:` - New feature or package
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance
- `refactor:` - Restructuring without behavior change

## Pre-commit Hooks

**Installed hooks:**

- YAML linting (yamllint)
- Shell script linting (shellcheck)
- File hygiene (trailing whitespace, EOF, etc.)
- Checkov (security scanning)

**Setup:**

```bash
pre-commit install              # One-time setup
pre-commit run --all-files      # Run manually
pre-commit autoupdate           # Update hook versions
```

## Key Configuration Details

### 1Password Integration

SSH keys are managed via 1Password SSH agent:

- Config: `dot_config/1Password/ssh/agent.toml`
- Requires 1Password desktop app with SSH agent enabled
- Keys referenced by 1Password item name, not file path

### macOS Settings

The `run_onchange_darwin-change-settings.sh.tmpl` script applies 400+ macOS
defaults settings including:

- Dark mode, keyboard, trackpad configuration
- Finder preferences (show extensions, hidden files)
- Dock settings (autohide, icon size)
- Security settings (firewall, screen lock)
- Application-specific settings

### mise Version Manager

Manages runtime versions for:

- Node.js, Python, Ruby, Go
- Terraform, Terragrunt
- Other tools as needed

Config: `dot_config/mise/config.toml`

### External Dependencies

Defined in `.chezmoiexternal.toml`:

- LazyVim configuration (pulled from GitHub)
- Other external configs as needed

## Important Notes

### Platform-Specific Code

Use chezmoi templating for platform differences:

```bash
{{ if eq .chezmoi.os "darwin" -}}
# macOS-specific code
{{ else if eq .chezmoi.os "linux" -}}
# Linux-specific code
{{ end -}}
```

### Secrets Management

- NEVER commit raw secrets
- Use 1Password CLI (`op`) for secret retrieval in templates
- SSH keys managed via 1Password SSH agent
- GPG keys optionally via Keybase

### Common Pitfalls

- Remember to run `chezmoi apply` after changing source files
- Use `chezmoi diff` before apply to preview changes
- Template syntax errors will cause apply to fail
- Changes to `run_onchange_` scripts trigger re-execution

## References

- @README.md - Installation and usage guide
- Chezmoi Documentation: <https://chezmoi.io/user-guide/command-overview/>
- Starship Documentation: <https://starship.rs/config/>
- LazyVim Documentation: <https://www.lazyvim.org/>
- mise Documentation: <https://mise.jdx.dev/>

---

**Last Updated:** 2025-12-12

This file should be updated whenever:

- New tools or packages are added
- Configuration patterns change
- Important context is discovered
