---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: vistasocial
  displayName: "Vista Social"
  version: "1.0.0"
  description: "Vista Social's official hosted MCP server. Schedule posts, manage profiles, and report across social networks with your Vista Social account."
  tags: ["vista-social", "scheduling", "social-media", "reporting"]
  category: "social-media"
  author: "vistasocial"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16 (social content sweep). AS vistasocial.com/api/integration/mcp, DCR at /api/oauth/clients.
# Scopes omitted: the client requests the AS's advertised default, which
# keeps offline_access intact for token refresh where the vendor offers it.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.vistasocial.com/mcp"

env: []
---

# Vista Social MCP Server

Vista Social's official hosted MCP server. Schedule posts, manage profiles, and report across social networks.

## How authentication works

1. Click **Connect account** on the Vista Social card.
2. A Vista Social sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Publishing tools post to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
