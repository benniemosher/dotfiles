# dotfiles

2024 rendition using chezmoi, starship, and lazyvim.

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
