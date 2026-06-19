---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: pagerduty
  displayName: "PagerDuty"
  version: "1.0.0"
  description: "PagerDuty incident management, incidents, services, and on-call schedules"
  tags: ["pagerduty", "incidents", "oncall", "alerting"]
  category: "observability"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
# PagerDuty uses the non-standard "Authorization: Token token=<KEY>"
# scheme — use injection template.
auth:
  injection:
    header_name: Authorization
    header_template: "Token token={PAGERDUTY_API_KEY}"

transport:
  type: "sse"
  url: "https://mcp.composio.dev/pagerduty"
env:
  - name: PAGERDUTY_API_KEY
    description: "PagerDuty REST API key"
    required: true
    sensitive: true

# /abilities is the documented authentication-probe endpoint —
# returns the account's enabled abilities. Cheap, idempotent.
# PagerDuty requires Accept: application/vnd.pagerduty+json;version=2.
validation:
  request:
    method: GET
    url: https://api.pagerduty.com/abilities
    headers:
      Accept: "application/vnd.pagerduty+json;version=2"
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "PagerDuty rejected the API key (401). Create a new REST API key in your PagerDuty user profile and update PAGERDUTY_API_KEY." }
    "403": { state: needs_setup, message: "API key lacks required scopes (403)." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.pagerduty.com/abilities
    headers:
      Accept: "application/vnd.pagerduty+json;version=2"
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

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
2. Add `PAGERDUTY_API_KEY` in the MCP connection setup
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
