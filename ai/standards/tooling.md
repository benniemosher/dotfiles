---
title: Tooling & Runtime Management
description: mise version manager patterns, workspace-level overrides, and environment setup
tags: [tooling, mise, runtime, versions]
last_updated: 2026-07-26
---

# Tooling & Runtime Management

## mise Version Manager

mise manages runtime versions for Node, Python, Ruby, Terraform, Go, and other tools. Config files are discovered by walking up the directory tree — more specific (deeper) files take precedence over less specific ones.

### Configuration Hierarchy

```
~/.config/mise/config.toml               ← global defaults (tools available everywhere)
~/Code/<workspace>/.mise.toml            ← workspace-pinned versions
~/Code/<workspace>/<repo>/.mise.toml     ← repo-level overrides (strictest)
```

The global config installs tools at "latest" — it's about availability, not pinning. Pinning belongs at the workspace or repo level where reproducibility matters.

### Workspace `.mise.toml`

Drop a `.mise.toml` at `~/Code/<workspace>/` to pin versions for everything under that workspace. mise activates these automatically when you `cd` anywhere inside it.

```toml
[tools]
node = "20"
terraform = "1.13.4"
python = "3.12"
```

### Repo-Level `.mise.toml`

For strict reproducibility (local must match CI):

```toml
[tools]
node = "20.18.1"   # exact version, committed to repo
terraform = "1.13.4"
```

Commit this file. CI should install mise and run `mise install` before builds.

### Common Commands

```bash
mise install          # install all tools for current directory
mise current          # show active versions
mise ls               # list all installed versions
mise use node@20      # add/update a tool in the nearest .mise.toml
mise upgrade --bump   # upgrade to latest within constraints
mise reshim           # regenerate shims after installing tools
```

### Idiomatic Version Files

mise reads standard version files (`.nvmrc`, `.node-version`, `.python-version`, `.ruby-version`, `.terraform-version`) when enabled:

```toml
[settings]
idiomatic_version_file_enable_tools = ["terraform", "ruby", "node"]
```

Repos using these standard files work automatically without a `.mise.toml`.

### Multiple Versions

Install multiple versions simultaneously (useful for testing across versions):

```toml
node = ["18", "20", "22"]   # last entry is the default
```

Switch per-directory with `mise use node@18`.
