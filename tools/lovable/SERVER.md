---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: lovable
  displayName: "Lovable"
  version: "1.0.0"
  description: "Lovable's official hosted MCP server. Manage Lovable projects and generated applications with your Lovable account."
  tags: ["lovable", "app-builder", "ai", "prototyping"]
  category: "developer-tools"
  author: "lovable"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16 (registry sweep; vendor-published entry on
# registry.modelcontextprotocol.io with a DNS-verified namespace). Scopes
# omitted: the client requests the AS's advertised default, which keeps
# offline_access intact for token refresh.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.lovable.dev"

env: []
---

# Lovable MCP Server

Lovable's official hosted MCP server. Manage Lovable projects and generated applications.

## How authentication works

1. Click **Connect account** on the Lovable card.
2. A Lovable sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
