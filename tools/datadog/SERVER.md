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
  # Official Datadog Bits AI MCP Server (GA March 2026), hosted by Datadog.
  # Verified live 2026-05-25: curl returns 401 (auth required) on the path below.
  # The previous "https://mcp.datadoghq.com/sse" path was dead (HTTP 404) and is not a real MCP endpoint.
  # Transport is Streamable HTTP, not SSE. For non-US1 sites swap the host (e.g. mcp.datadoghq.eu).
  # Docs: https://docs.datadoghq.com/bits_ai/mcp_server/  Repo: https://github.com/datadog-labs/mcp-server
  # No npm/pypi package is published; this is a Datadog-managed remote service only.
  type: "streamable-http"
  url: "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp"
env:
  # AUTH-MODEL GAP: Datadog's MCP server uses OAuth 2.0 as the primary auth method;
  # API + Application key headers are an alternative for when OAuth is not feasible.
  # The key-header path sends DD-API-KEY and DD-APPLICATION-KEY HTTP headers. If this
  # catalog/gateway only supports OAuth-less remote MCPs via env-injected key headers,
  # confirm the gateway maps DD_API_KEY -> DD-API-KEY and DD_APPLICATION_KEY -> DD-APPLICATION-KEY.
  # OAuth 2.0 login flow is NOT representable in this env: block and is unsupported here.
  - name: DD_API_KEY
    description: "Datadog API key (sent as DD-API-KEY header)"
    required: true
  # Renamed from DD_APP_KEY: Datadog's documented header/var is DD_APPLICATION_KEY (DD-APPLICATION-KEY header).
  - name: DD_APPLICATION_KEY
    description: "Datadog Application key (sent as DD-APPLICATION-KEY header)"
    required: true
  - name: DD_SITE
    description: "Datadog site e.g. datadoghq.com or datadoghq.eu (must match the transport host)"
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

This connects to Datadog's official Bits AI MCP Server (https://docs.datadoghq.com/bits_ai/mcp_server/), a Datadog-hosted remote service over Streamable HTTP. There is no local binary to install for the remote path and no npm/pypi package; Datadog also ships a `datadog_mcp_cli` stdio binary for cases where remote auth is unreliable, but that is out of scope for this remote entry.

1. Create a scoped Datadog API key and Application key from a service account with only the permissions your bots need
2. Add `DD_API_KEY` and `DD_APPLICATION_KEY` to your workspace secrets (these are sent as the `DD-API-KEY` and `DD-APPLICATION-KEY` headers)
3. Optionally set `DD_SITE` and the transport host to match your Datadog site (e.g. `mcp.datadoghq.eu` for EU)
4. The server starts automatically when a bot that references it runs

Auth caveat: Datadog's MCP server prefers OAuth 2.0. The API-key-header method used here is the documented fallback. If a connection is rejected, verify the gateway forwards the two key headers correctly and that the keys are not OAuth-only scoped.

## Team Usage

Add to your TEAM.md to share a single Datadog server instance across SRE bots:

```yaml
mcpServers:
  - ref: "tools/datadog"
    reason: "SRE bots need Datadog access for metrics, logs, and incident management"
    config:
      default_environment: "production"
```
