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

# Install ansible
if command -v ansible >&2; then
  echo Ansible is already installed. Skipping install.
else
  echo Installing Ansible...
  pipx install --include-deps ansible
  pipx ensurepath
fi

# Run ansible tasks
if command -v ansible >&2; then
  echo Running Ansible playbook
  ansible-playbook playbook.yml --ask-become-pass
else
  echo Cannot find Ansible.
fi

if ! gh auth status >/dev/null 2>&1; then
  gh auth login
fi
