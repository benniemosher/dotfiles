---
title: Terraform Standards
description: Patterns for state management, module design, provider constraints, and common gotchas
tags: [terraform, infrastructure, iac]
last_updated: 2026-07-26
---

# Terraform Standards

## State Management

### Per-Module Lock Files

For repos with multiple modules, each gets its own `.terraform.lock.hcl`. Commit lock files for reproducibility. Generate with `terraform init -upgrade`.

### Backend Strategy

- **Module repos** (reusable libraries): no backend — they have no state
- **Deployment repos** (infrastructure stacks): backend per module/environment
- State names should encode both environment and module for uniqueness

### Plugin Cache

Set `TF_PLUGIN_CACHE_DIR` for faster init. **Warning:** parallel `terraform init` + shared cache = race condition. Use `--parallelism-limit=1` in pre-commit hooks.

## Provider Version Constraints

```hcl
terraform {
  required_version = "~> 1.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.41"
    }
  }
}
```

Always verify which versions are available in your CI image before setting constraints. CI images often lag behind the latest release.

## for_each Patterns

### Use Keyed Maps (Not Lists)

```hcl
# BAD — positional index shifts when items added/removed
for index, arn in local.roles : "role_${index}" => { ... }

# GOOD — stable named keys, no destroy/recreate cascades
variable "ingress_rules" {
  type = map(object({
    description = string
    cidr_blocks = list(string)
  }))
}
```

`for_each` accepts `map` or `set(string)` — NOT lists of objects. Convert with `toset()` or map comprehension.

## Security Group Rules

### Never Mix Inline and Standalone

When a SG has both an inline `ingress` block and a standalone `aws_security_group_rule` for the same rule, every plan creates an infinite loop (removes inline → recreates standalone → repeat).

**Fix:** Use ONLY standalone `aws_security_group_rule` resources with keyed maps:

```hcl
resource "aws_security_group" "this" {
  name = "my-sg"
  # NO inline ingress/egress blocks
}

resource "aws_security_group_rule" "ingress" {
  for_each          = var.ingress_rules
  type              = "ingress"
  security_group_id = aws_security_group.this.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = "tcp"
  cidr_blocks       = each.value.cidr_blocks
}
```

## Module File Organization

```
module/
├── backend.tf          # backend block only
├── provider.tf         # terraform + required_providers + provider
├── data.tf             # data sources (alphabetized)
├── variables.tf        # variables (alphabetized, use tfsort)
├── outputs.tf          # outputs (alphabetized)
├── main.tf             # resources (alphabetized by type then name)
└── .terraform.lock.hcl # committed
```

## Prefer Data Sources Over jsonencode

```hcl
# BAD
policy = jsonencode({ Version = "2012-10-17", Statement = [...] })

# GOOD — type checking, references, readable
data "aws_iam_policy_document" "this" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}
```

## Import Ordering

When resources use `for_each` with keys derived from other resources, import order matters. Import the key-generating resource first. If nested `for_each` across 3+ types with cross-references, delete-and-recreate is faster than fighting import ordering.

## Testing (tftest)

```hcl
# tests/basic.tftest.hcl
run "validates_config" {
  command = plan    # plan-only, no AWS resources created
  variables { name = "test" }
  assert {
    condition     = aws_rds_cluster.this.engine == "aurora-postgresql"
    error_message = "Engine must be aurora-postgresql"
  }
}
```

Free, fast (seconds), catches syntax/type/logic bugs. Still requires credentials for provider init.

## CI/CD for Module Repos

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == "main"'
    - if: '$CI_COMMIT_TAG'   # Required for publish job!
```

All three rules needed: MR for validation, main for release detection, tag for publishing.

**Squash merge gotcha:** Commit message becomes MR title. If title lacks the right prefix, semantic release won't bump.

## Common Gotchas

| Gotcha | Fix |
|--------|-----|
| Null variables in trivy/checkov | Add `.trivyignore` |
| `count = list != ""` (always 0) | Type mismatch — compare correctly |
| `cidr_blocks = each.value` (needs list) | Use `[each.value]` |
| Helm provider 3.1.2 strict schema | Pin to `3.1.1` |
| `path.module` in upstream != your wrapper | Use `abspath()` |
| `sensitive()` hides plan diffs | Verify via separate decode |
| Variables declared but never referenced | Dead code — values go nowhere |
| `object({})` type strips extra keys | Use `map(string)` for tags |
| Backend auth in pre-commit | Use `-backend=false` |
