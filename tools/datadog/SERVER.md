---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: datadog
  displayName: "Datadog"
  version: "1.0.0"
  description: "Datadog observability, metrics, logs, traces, and monitors"
  tags: ["datadog", "monitoring", "metrics", "logs", "apm"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "sse"
  url: "https://mcp.datadoghq.com/sse"
env:
  - name: DD_API_KEY
    description: "Datadog API key"
    required: true
  - name: DD_APP_KEY
    description: "Datadog Application key"
    required: true
  - name: DD_SITE
    description: "Datadog site e.g. datadoghq.com or datadoghq.eu"
    required: false
tools:
  - name: query_metrics
    description: "Query time-series metrics"
    category: metrics
  - name: search_logs
    description: "Search and filter logs"
    category: logs
  - name: list_monitors
    description: "List configured monitors"
    category: monitors
  - name: get_monitor
    description: "Get monitor details and status"
    category: monitors
  - name: create_monitor
    description: "Create a new monitor"
    category: monitors
  - name: query_traces
    description: "Search APM traces"
    category: apm
  - name: get_dashboards
    description: "List dashboards"
    category: metrics
  - name: get_incidents
    description: "List active incidents"
    category: incidents
  - name: get_slo_status
    description: "Get SLO status"
    category: monitors
---

# Datadog MCP Server

Provides Datadog observability tools for bots that need real-time metrics, log analysis, trace inspection, and incident management.

## Which Bots Use This

- **sre-devops** -- Metric queries, incident correlation, and monitor management for on-call workflows
- **infra-monitor** -- Alerting, SLO tracking, and proactive infrastructure monitoring

## Setup

1. Create a Datadog API key and Application key from your Datadog organization settings
2. Add `DD_API_KEY` and `DD_APP_KEY` to your workspace secrets
3. Optionally set `DD_SITE` if your org uses a non-default Datadog site (e.g. `datadoghq.eu`)
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Datadog server instance across SRE bots:

```yaml
mcpServers:
  - ref: "tools/datadog"
    reason: "SRE bots need Datadog access for metrics, logs, and incident management"
    config:
      default_environment: "production"
```
