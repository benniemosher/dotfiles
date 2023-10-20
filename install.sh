#!/usr/bin/env bash

# Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/bmosher/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install brew software
brew bundle

# Run ansible tasks
ansible-playbook playbook.yml

gh auth login
