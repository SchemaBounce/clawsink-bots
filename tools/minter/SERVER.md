---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: minter
  displayName: "Minter.io"
  version: "1.0.0"
  description: "Minter.io's official hosted MCP server. Query Instagram and social analytics reports from Minter.io with your Minter.io account."
  tags: ["minter", "instagram", "analytics", "reporting"]
  category: "analytics"
  author: "minter"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16 (social content sweep). AS minter.io, DCR at /oauth/register.
# Scopes omitted: the client requests the AS's advertised default, which
# keeps offline_access intact for token refresh where the vendor offers it.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://minter.io/mcp"

env: []
---

# Minter.io MCP Server

Minter.io's official hosted MCP server. Query Instagram and social analytics reports from Minter.io.

## How authentication works

1. Click **Connect account** on the Minter.io card.
2. A Minter.io sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Publishing tools post to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
