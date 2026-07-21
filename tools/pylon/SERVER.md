---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: pylon
  displayName: "Pylon"
  version: "1.0.0"
  description: "Pylon's official hosted MCP server. Search and manage support issues, accounts, and contacts from your Pylon workspace."
  tags: ["pylon", "support", "customer-support"]
  category: "support"
  author: "pylon"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (popular-tools sweep). AS o.auth.usepylon.com
# (Pylon's AuthKit-hosted authorization server), DCR verified. Scopes
# omitted: the client requests the AS's advertised default (openid, email,
# profile, offline_access), which keeps token refresh intact.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.usepylon.com/"

env: []
---

# Pylon MCP Server

Pylon's official hosted MCP server. Search and manage support issues, accounts, and contacts from your Pylon workspace.

## How authentication works

1. Click **Connect account** on the Pylon card.
2. A Pylon sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Access is scoped to whatever the connecting user can already see in the
  Pylon dashboard; no extra permissions are granted.
- Tools are served by Pylon and discovered at session start.
- Write-class tools follow the platform's approval rules for agent actions.
