---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: retool
  displayName: "Retool"
  version: "1.0.0"
  description: "Retool's official hosted MCP server. Connect with your Retool account to work with apps and resources."
  tags: ["internal-tools", "apps", "workflows", "dashboards"]
  category: "developer-tools"
  author: "retool"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp
  scopes: ["mcp:read", "mcp:write"]

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.retool.com/mcp"

env: []
---

# Retool MCP Server

Retool's official hosted MCP server. Connect with your Retool account to work with apps and resources.

## How authentication works

1. Click **Connect account** on the Retool card.
2. A Retool sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to mcp:read, mcp:write.
- Tools are served by the vendor and discovered at session start (apps, resources, and workflows).
