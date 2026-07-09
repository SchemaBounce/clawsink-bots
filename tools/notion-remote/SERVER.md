---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: notion-remote
  displayName: "Notion (Official)"
  version: "1.0.0"
  description: "Notion's official hosted MCP server. Connect with your Notion account; no API key or integration setup needed."
  tags: ["notes", "docs", "wiki", "productivity", "knowledge-base"]
  category: "productivity"
  author: "notion"
  license: "Proprietary"

# MCP-spec OAuth 2.1 — same generic flow as freee. No scopes pin: Notion's
# authorization server advertises none, so the scope parameter is omitted.
# Distinct from tools/notion (the Composio-routed toolkit): this entry talks
# to Notion's own hosted endpoint with a workspace-consented grant.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.notion.com/mcp"

env: []
---

# Notion (Official) MCP Server

Connects SchemaBounce agents to [Notion's official hosted MCP server](https://mcp.notion.com)
with a workspace-consented OAuth grant.

## How authentication works

1. Click **Connect account** on the Notion (Official) card.
2. A Notion sign-in window opens. Pick the pages the workspace may access and
   approve.
3. The platform stores the grant; agents get a fresh token at session start.

## Notes

- Notion issues long-lived tokens without an advertised expiry; the platform
  refreshes only when Notion signals the token is stale.
- Tools are served by Notion and discovered at session start (search, page
  read/write, database queries, comments).
- This is separate from the Composio-routed `tools/notion` toolkit. Prefer
  this entry when you want Notion's own hosted server and first-party tools.
