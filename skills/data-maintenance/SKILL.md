---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: data-maintenance
  displayName: "Data Maintenance"
  version: "1.0.0"
  description: "Workspace data cleanup — stale record purging, memory compaction, and lifecycle management with dry-run safety."
  category: operations
  tags: ["maintenance", "cleanup", "retention", "memory-lifecycle", "data-hygiene"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_get_data_stats", "adl_get_namespace_stats", "adl_purge_stale_records", "adl_purge_memory_namespace", "adl_consolidate_memory", "adl_set_memory_ttl"]
data:
  producesEntityTypes: ["opt_recommendation"]
  consumesEntityTypes: []
---
# Data Maintenance

Reusable skill for workspace data hygiene. Any bot with data_maintenance capability can use this skill to safely clean up stale records, compact bloated memory namespaces, and manage memory lifecycle.

## Capabilities

- **Stale record purging** — identify and remove records past their retention window
- **Memory namespace compaction** — consolidate fragmented memory entries
- **Memory lifecycle management** — set TTLs and enforce retention policies
- **Dry-run safety** — all destructive operations preview impact before execution

## When to Use

Use this skill when a bot needs to perform periodic data cleanup, enforce retention policies, or respond to storage pressure in a workspace.
