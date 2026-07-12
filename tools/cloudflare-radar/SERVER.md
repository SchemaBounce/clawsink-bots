---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: cloudflare-radar
  displayName: "Cloudflare Radar"
  version: "1.0.0"
  description: "Cloudflare's official Radar MCP server. Query internet traffic, security, and adoption trends with your Cloudflare account."
  tags: ["internet", "traffic", "security", "trends"]
  category: "developer-tools"
  author: "cloudflare"
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
  url: "https://radar.mcp.cloudflare.com/mcp"

env: []
---

# Cloudflare Radar MCP Server

Cloudflare's official Radar MCP server. Query internet traffic, security, and adoption trends with your Cloudflare account.

## How authentication works

1. Click **Connect account** on the Cloudflare Radar card.
2. A Cloudflare Radar sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- No scopes pin: the client requests the server's advertised default set (including the refresh-token scope), so token refresh keeps working.
- Tools are served by the vendor and discovered at session start (traffic trends, BGP, DNS, and URL scans).
