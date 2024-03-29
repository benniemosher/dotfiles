#!/usr/bin/env bash

# Install Homebrew

# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && eval "$(/usr/local/bin/brew shellenv)"

# Install brew software
brew bundle

# Run ansible tasks
ansible-playbook playbook.yml

gh auth login
