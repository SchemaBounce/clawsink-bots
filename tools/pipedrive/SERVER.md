---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: pipedrive
  displayName: "Pipedrive"
  version: "2.0.0"
  description: "Pipedrive CRM, deals, contacts, activities, and sales pipeline"
  tags: ["pipedrive", "crm", "sales", "deals", "pipeline"]
  category: "crms-sales"
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "PIPEDRIVE"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like PIPEDRIVE_*."
transport:
  # Remote streamable-HTTP. The scoped, per-connected-account Composio MCP URL
  # is resolved automatically at connection time and stored on the
  # connection's transport_config, where the gateway reads it. There is no
  # local command; sessions connect by URL.
  #
  # Was `npx -y pipedrive-mcp-server@1.0.2` until 2026-08-12. That pin publishes
  # no bin, so npx could not determine an executable and the child exited before
  # the MCP handshake. It was also the wrong shape: core-api resolves a Composio
  # instance URL at connect time and only "leaves transport_config untouched"
  # when that fails, which made this stdio block the fallback the gateway would
  # try to spawn.
  type: "streamable-http"
env:
  # Optional. Leave blank to use your connected account.
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your Pipedrive account is then connected inside Composio."
    required: false
    sensitive: true
tools:
  - name: list_deals
    description: "List deals"
    category: deals
  - name: get_deal
    description: "Get deal details"
    category: deals
  - name: create_deal
    description: "Create a deal"
    category: deals
  - name: update_deal
    description: "Update a deal"
    category: deals
  - name: list_persons
    description: "List persons"
    category: persons
  - name: create_person
    description: "Create a person"
    category: persons
  - name: list_activities
    description: "List activities"
    category: activities
  - name: create_activity
    description: "Create an activity"
    category: activities
  - name: list_pipelines
    description: "List pipelines"
    category: pipelines
  - name: search_items
    description: "Search across deals, persons, and organizations"
    category: deals
---

# Pipedrive MCP Server

Provides Pipedrive CRM tools for bots that manage deals, contacts, activities, and sales pipelines.

## Which Bots Use This

- **sales-pipeline** -- Deal management, activity tracking, and pipeline analytics for sales workflows

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key.
2. In Composio, connect your Pipedrive account under the Pipedrive toolkit.
3. The server starts automatically when a bot that references it runs.

## Team Usage

Add to your TEAM.md to share a single Pipedrive server instance across sales bots:

```yaml
mcpServers:
  - ref: "tools/pipedrive"
    reason: "Sales bots need Pipedrive access for deal and activity management"
    config:
      default_pipeline: "default"
```
