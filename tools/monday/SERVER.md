---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: monday
  displayName: "monday.com"
  version: "1.0.0"
  description: "monday.com's official hosted MCP server. Connect with your monday.com account to work with boards and items."
  tags: ["work-management", "project-management", "crm", "tasks"]
  category: "productivity"
  author: "monday"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint (SSE). Nothing runs in our
  # gateway; sessions connect by URL with the platform-managed bearer token.
  type: "sse"
  url: "https://mcp.monday.com/sse"

env: []
---

# monday.com MCP Server

monday.com's official hosted MCP server. Connect with your monday.com account to work with boards and items.

## How authentication works

1. Click **Connect account** on the monday.com card.
2. A monday.com sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- No scopes pin: the client requests the server's advertised default set (which includes the refresh-token scope), so token refresh keeps working.
- Tools are served by the vendor and discovered at session start (boards, items, and updates).
- This server uses the SSE transport.
