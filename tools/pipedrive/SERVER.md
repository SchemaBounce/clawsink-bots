---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: pipedrive
  displayName: "Pipedrive"
  version: "1.0.0"
  description: "Pipedrive CRM, deals, contacts, activities, and sales pipeline"
  tags: ["pipedrive", "crm", "sales", "deals", "pipeline"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "PIPEDRIVE"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like PIPEDRIVE_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "pipedrive-mcp-server@1.0.2"]
env:
  - name: PIPEDRIVE_API_TOKEN
    description: "Pipedrive API token from Settings > Personal preferences"
    required: true
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

1. Get your Pipedrive API token from Settings > Personal preferences > API in your Pipedrive account
2. Add `PIPEDRIVE_API_TOKEN` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Pipedrive server instance across sales bots:

```yaml
mcpServers:
  - ref: "tools/pipedrive"
    reason: "Sales bots need Pipedrive access for deal and activity management"
    config:
      default_pipeline: "default"
```
