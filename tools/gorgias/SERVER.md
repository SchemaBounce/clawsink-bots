---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: gorgias
  displayName: "Gorgias"
  version: "1.0.0"
  description: "Gorgias' official hosted MCP server. Connect with your Gorgias account to work with tickets and customers."
  tags: ["support", "helpdesk", "ecommerce", "customers"]
  category: "support"
  author: "gorgias"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.gorgias.com/mcp"

env: []
---

# Gorgias MCP Server

Gorgias' official hosted MCP server. Connect with your Gorgias account to work with tickets and customers.

## How authentication works

1. Click **Connect account** on the Gorgias card.
2. A Gorgias sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- No scopes pin: the client requests the server's advertised default set (including the refresh-token scope), so token refresh keeps working.
- Tools are served by the vendor and discovered at session start (tickets, customers, and macros).
- The consent screen is broad because Gorgias advertises granular per-resource scopes; the client requests its advertised default set.
