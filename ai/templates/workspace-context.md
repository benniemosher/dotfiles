---
title: Workspace Context Template
description: Copy this to ~/Code/<workspace>/context.md and fill in business-specific details
---

# {{workspace}} Workspace Context

## Team
- Team name:
- Daily standup time:
- Communication channels:

## Repos & Locations
| Repo | Local Path | Default Branch | Deploy Method |
|------|-----------|----------------|---------------|
| repo-name | ~/Code/{{workspace}}/repo-name | main | via pipeline |

## Accounts & Environments
| Account | ID | Profile | Purpose |
|---------|-----|---------|---------|
| account_name | 123456789012 | profile_name | purpose_definition |

## Conventions
- Branch naming: (project-specific conventions here)
- Commit messages: (semantic-release variant if applicable)
- Deploy process: (how to get code to production)

## Credentials & Auth
- Where are API keys stored: (e.g., ~/.zshrc.local, 1Password, SSM)
- Docker registry: (e.g., docker login to...)
- Git host: (GitHub, GitLab, etc.)
- AWS login: (SSO command or profile names)

## Notes & Files
- Standup notes: ~/Code/{{workspace}}/notes/standups/
- Learnings: ~/Code/{{workspace}}/notes/learnings/
- Tmp working docs: ~/Code/{{workspace}}/tmp/

## AI-Specific Notes
- (Any preferences specific to this workspace that override the globals)
- (e.g., "Use internal-dd.example.com not app.datadoghq.com")
