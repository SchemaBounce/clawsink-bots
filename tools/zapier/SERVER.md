---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: zapier
  displayName: "Zapier"
  version: "1.0.0"
  description: "Zapier automation, trigger zaps, list workflows, and manage connections"
  tags: ["zapier", "automation", "workflow", "integration"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "ZAPIER"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like ZAPIER_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "zapier-mcp@0.0.1"]
env:
  - name: ZAPIER_API_KEY
    description: "Zapier API key from zapier.com/app/developer"
    required: true
tools:
  - name: list_zaps
    description: "List all zaps in the account"
    category: zaps
  - name: trigger_zap
    description: "Trigger a zap via webhook"
    category: zaps
  - name: get_zap
    description: "Get details of a specific zap"
    category: zaps
  - name: list_actions
    description: "List available actions for an app"
    category: actions
  - name: search_apps
    description: "Search the Zapier app directory"
    category: apps
---

# Zapier MCP Server

Provides Zapier API tools for triggering zaps, listing workflows, and searching the app directory.

## Which Bots Use This

- **executive-assistant** -- Triggers workflow automations for recurring administrative tasks
- **devops-automator** -- Orchestrates cross-platform automation chains via Zapier integrations

## Setup

1. Log in to [Zapier](https://zapier.com/) and navigate to Developer settings
2. Generate an API key
3. Add `ZAPIER_API_KEY` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Zapier server instance across bots:

```yaml
mcpServers:
  - ref: "tools/zapier"
    reason: "Bots need Zapier access to trigger and manage cross-platform automations"
    config: {}
```
