---
title: Observability Standards
description: Monitoring, APM, dashboards, and alerting best practices
tags: [observability, monitoring, datadog, apm]
last_updated: 2026-07-26
---

# Observability Standards

## Monitor Design

### on_missing_data Strategy Selection

| Strategy | Use When |
|----------|----------|
| `default` | Technology-specific monitors (not all services use Redis/Postgres) |
| `show_and_notify_no_data` | Critical services where absence of data IS an incident |
| Wrap in `default_zero()` | Counters that should be 0 when healthy (errors, restarts) |
| **Never** use `resolve` | Silently hides real problems when data stops |

### Threshold Alignment

Query comparator value MUST match the `critical` threshold. `< 95` in query → critical = `95`. Warning is independent.

### Cumulative Counter Anti-Pattern

Raw cumulative counters as thresholds fire permanently once crossed (e.g., pod hits 5 lifetime restarts → alert forever). Use `change()` function to detect new events only.

## APM Instrumentation

### Auto-Instrumentation

Most runtimes auto-instrument HTTP + DB clients. Key limitation: ORMs with native binary engines (Prisma/Rust) bypass language-level instrumentation — use OpenTelemetry bridge packages.

### DB Service Name Overrides

```yaml
DD_MYSQL_SERVICE: "my-app-mysql"
DD_POSTGRES_SERVICE: "my-app-postgres"
DD_MONGODB_SERVICE: "my-app-mongodb"
DD_REDIS_SERVICE: "my-app-redis"
```

Without these, all DB traces show as generic `service:mysql`.

**Conflict warning:** If DD_SERVICE/DD_ENV are set via pod label fieldRefs in the Helm chart, do NOT also set them in the `env:` block.

## Dashboard Design

### Template Variables
- Always set a `prefix` (e.g., `kube_cluster_name`)
- Reference with `{$variable_name}` in queries
- Use presets to link multiple variables (one click sets both)
- `prefix: null` won't work — Datadog needs a prefix for substitution

### Rate vs Count
- **Never** cumulative counters for real-time dashboards (only go up)
- **Always** use `.as_rate()` for traffic visualization
- Rate widgets update in minutes; cumulative takes 24+ hours to show changes

### Scale Comparison
When comparing two sources with vastly different scales (e.g., blue/green during cutover):
- Separate widgets with independent y-axes
- Fixed layout (`reflow_type: "fixed"`) for consistent grid

## N+1 Query Detection

### Symptoms
- High latency (10-50s) with 200 OK (not errors)
- 70-80% of trace time in main service (not downstream)
- Low CPU/memory (not resource constrained)

### Common Patterns
```javascript
// BAD — N queries
Promise.all(ids.map(id => Model.findById(id)))

// GOOD — 1 batch query
Model.find({ _id: { $in: ids } })
```

### Investigation Workflow
1. Filter traces by `@duration:>5s`
2. Check waterfall — where is time spent?
3. If main service → DB/computation issue
4. Read handler code → look for per-item queries
5. Fix with batch queries or DataLoader

## AWS Integration vs Agent

| What You Need | Solution |
|--------------|----------|
| CloudWatch metrics for managed services (RDS, ELB) | AWS Integration (IAM role) |
| Pod-level metrics, APM traces | Datadog Agent (DaemonSet) |
| Query-level DB metrics | Agent with Database Monitoring |
| Custom app metrics | Agent + DogStatsD or OpenMetrics |

**You cannot install the agent on managed services.** Integration collects via API.

## OpenMetrics/Prometheus

### Namespace Doubling
OpenMetrics check with `namespace: x` prepends `x.` to metrics. If source metrics already have prefix → `x.x_metric_name`. Dashboard queries must use doubled form.

### Pod Annotations
Use `annotations` (not `podAnnotations`) — chart mapping varies. Verify which key your chart uses.

## Custom Service Metrics

```python
from prometheus_client import Gauge, generate_latest

my_gauge = Gauge("my_metric", "Description", ["env", "severity"])

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": "text/plain"}
```

Always emit zero values for all label combinations to prevent "No Data" on dashboards.

## Blue/Green Monitoring

### During Cutover (15-min pause between increments)
- APM error rates on target cluster
- Synthetic health checks
- Pod health and readiness
- ALB target group health
- Team channels for flagged issues

Alerts have 5-10 min evaluation windows. 15-min pause ensures alerts fire before more traffic shifts.
