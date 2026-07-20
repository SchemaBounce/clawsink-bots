---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: postman
  displayName: "Postman"
  version: "1.0.0"
  description: "Postman's official hosted MCP server. Manage workspaces, collections, APIs, and environments with your Postman account."
  tags: ["postman", "api", "testing", "collections", "developer-tools"]
  category: "developer-tools"
  author: "postman"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR), live-probed
# 2026-07-16: AS mcp.postman.com, DCR at /register. No scopes advertised;
# omitted so the client requests the advertised default.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.postman.com/mcp"

env: []
---

# Postman MCP Server

Postman's official hosted MCP server. Agents can browse and manage Postman workspaces, collections, APIs, environments, and mocks.

## How authentication works

1. Click **Connect account** on the Postman card.
2. A Postman sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
