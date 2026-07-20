---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: unsora
  displayName: "Unsora"
  version: "1.0.0"
  description: "Unsora's official hosted MCP server. Generate video, images, and music, build AI influencers, cut clips, make thumbnails, and schedule posts with your Unsora account."
  tags: ["unsora", "video", "image-generation", "media", "social-media"]
  category: "ai"
  author: "unsora"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16: AS clerk.tryunsora.com (vendor's own Clerk-hosted
# authorization server), DCR at /oauth/register. Scopes omitted: the AS
# advertises identity scopes + offline_access; the client requests the
# advertised default so token refresh keeps working.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.tryunsora.com/mcp"

env: []
---

# Unsora MCP Server

Unsora's official hosted MCP server. Agents can generate videos, images, and music, build AI influencer content, cut clips, caption footage, create thumbnails, and schedule social posts.

## How authentication works

1. Click **Connect account** on the Unsora card.
2. An Unsora sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Generation volume is metered against your Unsora plan.
- Post scheduling publishes to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
