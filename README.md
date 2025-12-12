# dotfiles

2024 rendition using chezmoi, starship, and lazyvim.

## Installation

```bash
# Setup homebrew, see: https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install gh and chezmoi
brew install gh chezmoi

# Setup chezmoi
chezmoi init git@github.com:benniemosher/dotfiles-2024.git

# Setup dotfiles directory
mkdir -p $HOME/Code
ln -sf $HOME/.local/share/chezmoi $HOME/Code/dotfiles
chezmoi cd
chezmoi apply

# Login to 1Password
# 1Password Menu > Install 1Password CLI
# 1Password Menu > Settings > Developer > Check all the boxes
op signin
```

## Usage

Create a `~/.profile.local` filling in contents below:

```bash
# ~/.profile.local

export KEYBASE_USERNAME="<ENTER_USERNAME>"
export KEYBASE_PAPERKEY="<ENTER_PAPERKEY>"
export KEYBASE_KEY_ID="<ENTER_KEY_ID>"
```

```bash
chezmoi apply
osascript -e 'quit app "Terminal"'
```

Update iTerm2.app to pull the plist from `$HOME/.local/share/chezmoi/preferences`.
