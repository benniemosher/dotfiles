#!/usr/bin/env bash

# Install Homebrew
if command -v brew >&2; then
  echo Homebrew is already installed. Skipping install.
else
  echo Installing Homebrew...
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install brew software
echo Installing Homebrew packages
brew bundle

if ! gh auth status >/dev/null 2>&1; then
  gh auth login
fi
