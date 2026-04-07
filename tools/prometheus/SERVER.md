---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: prometheus
  displayName: "Prometheus"
  version: "1.0.0"
  description: "Prometheus metrics — PromQL queries, alerts, and targets"
  tags: ["prometheus", "metrics", "promql", "monitoring"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "prometheus-mcp@1.1.3"]
env:
  - name: PROMETHEUS_URL
    description: "Prometheus server URL e.g. http://localhost:9090"
    required: true
tools:
  - name: query_instant
    description: "PromQL instant query"
    category: queries
  - name: query_range
    description: "PromQL range query"
    category: queries
  - name: list_targets
    description: "List scrape targets"
    category: targets
  - name: list_alerts
    description: "List active alerts"
    category: alerts
  - name: list_rules
    description: "List alerting and recording rules"
    category: alerts
  - name: get_metadata
    description: "Get metric metadata"
    category: metadata
  - name: list_label_values
    description: "List values for a label"
    category: metadata
---

# Prometheus MCP Server

Provides direct Prometheus API access for bots that need to run PromQL queries, inspect scrape targets, and check alerting rules.

## Which Bots Use This

- **sre-devops** -- PromQL queries for incident investigation, target health checks, and alert rule inspection
- **data-analyst** -- Time-series metric analysis and trend detection via range queries

## Setup

1. Ensure your Prometheus instance is accessible from the workspace network
2. Add `PROMETHEUS_URL` to your workspace secrets (e.g. `http://prometheus.monitoring:9090`)
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Prometheus server instance across monitoring bots:

```yaml
mcpServers:
  - ref: "tools/prometheus"
    reason: "Bots need Prometheus access for metric queries and alert inspection"
    config:
      default_step: "15s"
```
