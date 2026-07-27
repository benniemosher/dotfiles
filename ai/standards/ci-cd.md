---
title: CI/CD Standards
description: Pipeline optimization, caching, Docker builds, and deployment patterns
tags: [ci-cd, pipelines, docker, automation]
last_updated: 2026-07-26
---

# CI/CD Standards

## Docker Build Caching

### BuildKit Pattern

```yaml
variables:
  DOCKER_BUILDKIT: "1"
script:
  - docker pull ${REGISTRY}/${IMAGE}:latest || true
  - docker build
    --build-arg BUILDKIT_INLINE_CACHE=1
    --cache-from ${REGISTRY}/${IMAGE}:latest
    -t ${REGISTRY}/${IMAGE}:${CI_COMMIT_SHA}
    -t ${REGISTRY}/${IMAGE}:latest .
  - docker push ${REGISTRY}/${IMAGE}:${CI_COMMIT_SHA}
  - docker push ${REGISTRY}/${IMAGE}:latest
```

- `BUILDKIT_INLINE_CACHE=1` embeds cache metadata in image
- `--cache-from` uses previous image layers as cache
- `|| true` on pull so first build doesn't fail
- Push `:latest` so next build has a cache source

## Dependency Caching

### Lockfile-Based Keys

```yaml
cache:
  key:
    files:
      - yarn.lock  # or package-lock.json, requirements.txt
  paths:
    - node_modules/
  policy: pull-push
```

Cache invalidates only when deps actually change. For pip: `--cache-dir .pip-cache`.

## Container Registry Pull Policy

| Policy | Behavior | Use When |
|--------|----------|----------|
| `always` (default) | Contacts registry every job | Registry is fast and reliable |
| `if-not-present` | Only pulls if image missing locally | Registry is slow/unreliable, eliminates timeout hangs |

For self-hosted runners with slow registries, `if-not-present` prevents indefinite hangs at "Pulling docker image."

## Runner Scaling

### CPU Target Tracking

For I/O-bound CI jobs (most pipelines), standard 60% CPU target won't trigger because CPU stays low. Use 25% target instead, combined with scheduled scaling:

```
Business hours: min=2 (handle burst)
Off hours: min=1 (cost savings)
CPU target: 25% (catches actual load)
```

### Cleanup Script

Aggressive `docker system prune -af` every 5 minutes destroys all cached images. Fix:
```bash
docker image prune -af --filter "until=24h"
docker container prune -f --filter "until=1h"
docker volume prune -f
```

## Pipeline Optimization

### `changes:` Evaluates Per-Push

On subsequent pushes to an MR, `changes:` only checks files in the **latest push**, not the full MR diff. Remove `changes:` from test/build jobs on MR events if tests are fast enough to always run.

### Workflow Rules (GitLab)

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == "main"'
    - if: '$CI_COMMIT_TAG'
```

Missing `$CI_COMMIT_TAG` rule = publish/deploy jobs never run on tag pipelines.

### Never Override CI_COMMIT_TAG

Setting `CI_COMMIT_TAG: ${CI_COMMIT_SHA}` makes it always truthy, breaking any rule that checks for actual tags. Don't do it.

## Terraform in CI

### Plugin Cache

```bash
export TF_PLUGIN_CACHE_DIR=/opt/terraform-plugin-cache
mkdir -p $TF_PLUGIN_CACHE_DIR && chmod 777 $TF_PLUGIN_CACHE_DIR
```

If using Docker executor, volume-mount the cache directory into containers.

### Validate Without Backend

For MR validation jobs that don't need state access:
```bash
terraform init -backend=false
terraform validate
```

## Deploy Rules Pattern

| Branch | Deploys To |
|--------|-----------|
| Feature branches | dev only |
| `develop`/`development` | dev, qa, uat |
| `main`/`master` | stage, prod |
| `release/*` | ALL environments |
| Tags | prod only |

## Semantic Release

### Project Access Tokens

Group-level tokens often can't push to sub-namespace repos. Create per-project tokens:
1. Project → Settings → Access Tokens
2. Scopes: `write_repository`, `read_repository`
3. Set as CI variable: `GIT_SEMANTIC_RELEASE_TOKEN` (protected, masked)

### First Version Bootstrap

Semantic release can't bump from nothing. Create initial tag manually:
```bash
git commit --allow-empty -m "BREAKING CHANGE: initial release"
git tag -a 1.0.0 -m "Initial release"
git push origin main --tags
```

## Pipeline Stage Naming

Keep stages consistent across repos:
```yaml
stages:
  - validate
  - test
  - build
  - deploy-dev
  - deploy-stage
  - deploy-prod
```

For Terraform:
```yaml
stages:
  - Validate (Infrastructure)
  - Plan (Infrastructure)
  - Apply (Infrastructure)
```

Some CI components require exact stage names — always check component documentation.
