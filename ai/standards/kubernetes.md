---
title: Kubernetes Standards
description: Resource right-sizing, health probes, deployment strategies, and reliability patterns
tags: [kubernetes, eks, reliability]
last_updated: 2026-07-26
---

# Kubernetes Standards

## Resource Right-Sizing Methodology

Query historical metrics (minimum 6 months) with two aggregations:
- **avg across pods** → request recommendations (scheduler reservations)
- **max across pods** → limit recommendations (OOMKill/throttle thresholds)

### CPU
| Metric | Multiplier | Purpose |
|--------|-----------|---------|
| Request | 1.5× avg-of-avg | Scheduler reservation |
| Limit | 2× max-of-max | Throttle threshold |

Nice values: 50, 100, 150, 200, 250, 300, 400, 500, 750, 1000, 1500, 2000m

### Memory
| Metric | Multiplier | Purpose |
|--------|-----------|---------|
| Request | 1.25× avg-of-avg | Scheduler reservation |
| Limit | 1.5× max-of-max | OOMKill threshold |

Nice values: 64, 128, 192, 256, 384, 512, 768, 1024, 1536, 2048, 3072, 4096Mi

### Ephemeral Storage
Same methodology as memory. Exceeding limit → kubelet eviction (like OOMKill).

## Health Probes

### Interaction Model

```
startupProbe running    → liveness + readiness DISABLED
startupProbe succeeds   → stops forever; liveness + readiness take over
startupProbe fails      → pod killed and restarted
```

### Recommended Pattern

```yaml
startupProbe:
  httpGet: { path: /health, port: 8080 }
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 30      # 155s max startup budget
  timeoutSeconds: 3
livenessProbe:
  httpGet: { path: /health, port: 8080 }
  periodSeconds: 10
  failureThreshold: 3       # kills after 30s sustained failure
  timeoutSeconds: 3
readinessProbe:
  httpGet: { path: /health, port: 8080 }
  periodSeconds: 5
  failureThreshold: 3
  timeoutSeconds: 3
```

Set `failureThreshold × periodSeconds` to at least 3× measured startup time.

## Deployment Strategies

### Zero-Downtime Rolling Update

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: "0"     # MUST be string — integer 0 is falsy in Go templates
    maxSurge: "1"
```

### Helm Go Template Falsy-Zero Bug

Integer `0` is falsy in Go templates and falls through to chart defaults (typically 25%). Always quote: `"0"`.

## Pod Disruption Budgets

```yaml
spec:
  minAvailable: 1    # Standard (low replica count)
  # OR
  maxUnavailable: 2  # High replica count (30+ pods)
```

## Pod Anti-Affinity

Soft scheduling spreads pods across nodes without blocking:

```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values: ["my-service"]
          topologyKey: kubernetes.io/hostname
```

## HPA + Replica Count

When HPA is enabled with `autoscaleMin: 1`, it overrides deployment replicas. **Set BOTH:**
```yaml
replicaCount: 2
autoscaleMin: 2
```

## Helm Gotchas

| Issue | Cause | Fix |
|-------|-------|-----|
| Selector change breaks in-place upgrade | `matchLabels` is immutable | Delete+recreate on inactive cluster |
| Shared namespace resource conflicts | Same name, different release | Use unique `releaseName` prefix |
| Values silently ignored | Feature doesn't exist in chart version | Verify with `helm template` against exact CI chart version |
| Strategy not rendered | Old chart version lacks template | Check chart source, not local checkout |

## Blue/Green DNS Cutover

| Step | New | Old | Wait |
|------|----:|----:|------|
| 1 | 25% | 75% | 15 min |
| 2 | 50% | 50% | 15 min |
| 3 | 75% | 25% | 15 min |
| 4 | 100% | 0% | continuous |

15-min pauses allow alerts (5-10 min evaluation windows) to fire before shifting more traffic.

## Node Termination

Two-layer approach:
1. **NTH (Node Termination Handler):** Cordons/drains nodes on spot interruption or scheduled events
2. **App-level SIGTERM:** Graceful shutdown — finish requests, close connections, flush buffers

## Secret Rotation

- **Env vars:** Requires pod restart for new values
- **Volume mounts:** Auto-updates in ~60s, no restart needed — prefer this for rotation-safe secrets
