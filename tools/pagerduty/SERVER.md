---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: pagerduty
  displayName: "PagerDuty"
  version: "1.0.0"
  description: "PagerDuty incident management — incidents, services, and on-call schedules"
  tags: ["pagerduty", "incidents", "oncall", "alerting"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "sse"
  url: "https://mcp.composio.dev/pagerduty"
env:
  - name: PAGERDUTY_API_KEY
    description: "PagerDuty REST API key"
    required: true
tools:
  - name: list_incidents
    description: "List incidents"
    category: incidents
  - name: get_incident
    description: "Get incident details"
    category: incidents
  - name: create_incident
    description: "Create a new incident"
    category: incidents
  - name: acknowledge_incident
    description: "Acknowledge an incident"
    category: incidents
  - name: resolve_incident
    description: "Resolve an incident"
    category: incidents
  - name: list_services
    description: "List PagerDuty services"
    category: services
  - name: list_oncalls
    description: "List current on-call users"
    category: oncall
  - name: list_schedules
    description: "List on-call schedules"
    category: oncall
  - name: trigger_event
    description: "Trigger a PagerDuty event"
    category: events
---

# PagerDuty MCP Server

Provides PagerDuty incident management tools for bots that need to create, acknowledge, and resolve incidents, query on-call schedules, and manage service health.

**Note:** No published npm package exists yet. This server definition is a placeholder for when a community package becomes available, or can be connected via the Composio integration gateway.

## Which Bots Use This

- **sre-devops** -- Incident creation, acknowledgment, resolution, and on-call routing during operational incidents
- **infra-monitor** -- Proactive incident triggering and service health monitoring

## Setup

1. Create a PagerDuty REST API key from your PagerDuty account under Integrations > API Access Keys
2. Add `PAGERDUTY_API_KEY` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single PagerDuty server instance across SRE bots:

```yaml
mcpServers:
  - ref: "tools/pagerduty"
    reason: "SRE bots need PagerDuty access for incident management and on-call coordination"
    config:
      default_escalation_policy: "primary"
```
