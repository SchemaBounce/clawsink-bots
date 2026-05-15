---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mixpanel
  displayName: "Mixpanel"
  version: "1.0.0"
  description: "Mixpanel product analytics, events, funnels, retention, and user profiles"
  tags: ["mixpanel", "analytics", "product", "events", "funnels"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "MIXPANEL"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like MIXPANEL_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "mixpanel-mcp-server@2.0.2"]
env:
  - name: MIXPANEL_PROJECT_TOKEN
    description: "Mixpanel project token"
    required: true
  - name: MIXPANEL_API_SECRET
    description: "Required for data export APIs"
    required: false
tools:
  - name: query_events
    description: "Query events with filters"
    category: events
  - name: get_funnel
    description: "Get funnel conversion data"
    category: funnels
  - name: get_retention
    description: "Get retention data"
    category: retention
  - name: get_user_profile
    description: "Get user profile"
    category: users
  - name: search_users
    description: "Search user profiles"
    category: users
  - name: list_events
    description: "List event names"
    category: events
  - name: get_top_events
    description: "Get top events by volume"
    category: events
---

# Mixpanel MCP Server

Provides Mixpanel product analytics tools for bots that need to query events, analyze funnels, track retention, and explore user profiles.

## Which Bots Use This

- **data-analyst** — Product analytics queries, funnel analysis, and user segmentation
- **marketing-manager** — Campaign performance tracking, user behavior analysis, and conversion funnels

## Setup

1. Get your project token from Mixpanel project settings
2. Add `MIXPANEL_PROJECT_TOKEN` to your workspace secrets
3. Optionally add `MIXPANEL_API_SECRET` for data export APIs
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Mixpanel server instance across bots:

```yaml
mcpServers:
  - ref: "tools/mixpanel"
    reason: "Bots need Mixpanel access for product analytics and user behavior analysis"
    config:
      default_date_range: "30d"
```
