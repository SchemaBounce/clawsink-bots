---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: craft
  displayName: "Craft"
  version: "1.0.0"
  description: "Craft's official hosted MCP server. Read and create Craft documents, notes, and daily notes with your Craft account."
  tags: ["craft", "documents", "notes", "writing"]
  category: "productivity"
  author: "craft"
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
  url: "https://mcp.craft.do/my/mcp"

env: []
---

# Craft MCP Server

Craft's official hosted MCP server. Read and create Craft documents, notes, and daily notes.

## How authentication works

1. Click **Connect account** on the Craft card.
2. A Craft sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
