---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: miro
  displayName: "Miro"
  version: "1.0.0"
  description: "Miro's official hosted MCP server. Read and update Miro boards with your Miro account."
  tags: ["miro", "whiteboard", "collaboration", "design", "diagrams"]
  category: "design"
  author: "miro"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR), live-probed
# 2026-07-16: AS mcp.miro.com, DCR at /register. Advertised scopes are
# boards:read, boards:write, openid, email (no offline_access advertised),
# so the functional pair is pinned per the least-privilege scope rule.
auth:
  type: oauth2_mcp
  scopes: ["boards:read", "boards:write"]

transport:
  type: "streamable-http"
  url: "https://mcp.miro.com/mcp"

env: []
---

# Miro MCP Server

Miro's official hosted MCP server. Agents can read board content and create or update items on Miro boards.

## How authentication works

1. Click **Connect account** on the Miro card.
2. A Miro sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to boards:read, boards:write.
- Tools are served by the vendor and discovered at session start.
