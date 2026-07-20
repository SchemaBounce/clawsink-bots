---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: stytch
  displayName: "Stytch"
  version: "1.0.0"
  description: "Stytch's official hosted MCP server. Manage Stytch auth projects, settings, and API keys with your Stytch account."
  tags: ["stytch", "authentication", "identity", "developer-tools"]
  category: "developer-tools"
  author: "stytch"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR), live-probed
# 2026-07-16: AS is Stytch's own tenant domain (customers.stytch.com) with
# DCR at /v1/oauth2/register. Scopes omitted: the advertised set mixes
# identity and management scopes and includes offline_access; the client
# requests the advertised default.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.stytch.dev/mcp"

env: []
---

# Stytch MCP Server

Stytch's official hosted MCP server. Agents can inspect and manage Stytch projects, project settings, and API keys.

## How authentication works

1. Click **Connect account** on the Stytch card.
2. A Stytch sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Management scopes (manage:api_keys, manage:project_settings) are granted through the vendor's own consent screen.
- Tools are served by the vendor and discovered at session start.
