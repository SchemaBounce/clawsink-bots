---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: grafana
  displayName: "Grafana"
  version: "1.0.0"
  description: "Grafana observability, dashboards, Prometheus queries, and alerting"
  tags: ["grafana", "dashboards", "prometheus", "monitoring", "alerting"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "mcp-grafana-npx@1.0.1"]
env:
  - name: GRAFANA_URL
    description: "Grafana instance URL"
    required: true
  - name: GRAFANA_API_KEY
    description: "Grafana API key or service account token"
    required: true
tools:
  - name: search_dashboards
    description: "Search dashboards by name or tag"
    category: dashboards
  - name: get_dashboard
    description: "Get dashboard details and panels"
    category: dashboards
  - name: list_datasources
    description: "List configured datasources"
    category: datasources
  - name: query_prometheus
    description: "Execute a Prometheus query via Grafana"
    category: datasources
  - name: list_alerts
    description: "List active alerts"
    category: alerting
  - name: get_alert_rules
    description: "Get alert rule definitions"
    category: alerting
  - name: list_folders
    description: "List dashboard folders"
    category: dashboards
  - name: get_annotations
    description: "Get dashboard annotations"
    category: annotations
---

# Grafana MCP Server

Provides Grafana observability tools for bots that need dashboard access, Prometheus metric queries, and alert management.

## Which Bots Use This

- **sre-devops** -- Dashboard queries, Prometheus metric analysis, and alert rule management for on-call workflows
- **infra-monitor** -- Proactive dashboard monitoring, datasource health checks, and annotation tracking

## Setup

1. Create a Grafana service account with Viewer or Editor role from your Grafana instance administration settings
2. Generate an API key or service account token for the service account
3. Add `GRAFANA_URL` and `GRAFANA_API_KEY` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Grafana server instance across SRE bots:

```yaml
mcpServers:
  - ref: "tools/grafana"
    reason: "SRE bots need Grafana access for dashboards, metrics, and alerting"
    config:
      default_datasource: "prometheus"
```
