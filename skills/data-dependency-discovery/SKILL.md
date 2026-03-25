---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: data-dependency-discovery
  displayName: "Data Dependency Discovery"
  version: "1.0.0"
  description: "Autonomously discovers missing data dependencies and proposes pipelines to fill gaps. Universal skill — baked into every bot for self-assessment."
  tags: ["infrastructure", "discovery", "pipelines", "autonomy", "platform"]
  author: "schemabounce"
  license: "MIT"
---

# Data Dependency Discovery

Autonomously discovers missing data dependencies and proposes pipelines to fill gaps.

## Usage

This is a **platform skill** — automatically included in every bot's capabilities. It enables the self-pipeline discovery flywheel: bot activates, discovery runs, gaps surface, pipelines get proposed, human approves, data flows, bot performs better.

## When to Use

Runs automatically via the default discovery workflow (daily schedule). Can also be invoked manually by asking the agent to "check your data dependencies" or "discover what data you're missing."

## Required Tools

- `adl_list_entity_types` — check what data exists in the workspace
- `adl_query_records` — verify entity types have actual records
- `adl_list_connectors` — discover available SaaS connectors (104+)
- `adl_list_pipeline_routes` — check existing data pipeline infrastructure
- `adl_list_workspace_sources` — check configured data sources
- `adl_propose_pipeline_route` — propose new pipelines for gaps (human approval required)
- `adl_write_record` — write discovery results for dashboard tracking
- `adl_add_memory` — store dependency status across runs
