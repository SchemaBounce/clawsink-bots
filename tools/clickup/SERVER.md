---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: clickup
  displayName: "ClickUp"
  version: "1.0.0"
  description: "ClickUp's official hosted MCP server. Connect with your ClickUp account; no API key or local setup."
  tags: ["tasks", "project-management", "docs", "work"]
  category: "productivity"
  author: "clickup"
  license: "Proprietary"

# This entry replaces the stdio ClickUp entry: remote hosted OAuth is the default so we no
# longer pay for managed/API-key auth. The serverRef is unchanged; an existing
# connection shows Reconnect once, then uses OAuth.
# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp
  scopes: ["read", "write"]

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.clickup.com/mcp"

env: []
---

# ClickUp MCP Server

ClickUp's official hosted MCP server. Connect with your ClickUp account; no API key or local setup.

## How authentication works

1. Click **Connect account** on the ClickUp card.
2. A ClickUp sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to read, write.
- Tools are served by the vendor and discovered at session start (tasks, lists, docs, and spaces).
- Replaces the stdio ClickUp entry. An existing connection shows Reconnect once, then uses OAuth.
