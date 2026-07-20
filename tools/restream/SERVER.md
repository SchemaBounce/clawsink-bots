---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: restream
  displayName: "Restream"
  version: "1.0.0"
  description: "Restream's official hosted MCP server. Manage live streams, channels, clips, and multistream destinations with your Restream account."
  tags: ["restream", "live-streaming", "clips", "multistreaming"]
  category: "social-media"
  author: "restream"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16 (social content sweep). AS mcp.restream.io (authz oauth.restream.io, DCR api.restream.io/oauth/register); granular read/write scopes advertised.
# Scopes omitted: the client requests the AS's advertised default, which
# keeps offline_access intact for token refresh where the vendor offers it.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.restream.io/mcp"

env: []
---

# Restream MCP Server

Restream's official hosted MCP server. Manage live streams, channels, clips, and multistream destinations.

## How authentication works

1. Click **Connect account** on the Restream card.
2. A Restream sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Publishing tools post to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
