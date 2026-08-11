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

# OAuth 2.1 auth. Unsora's /mcp endpoint is a Clerk-backed OAuth protected
# resource: it rejects a static API key sent as an Authorization Bearer
# header and requires a session token from the OAuth flow instead. The
# generic oauth2_mcp dynamic-client-registration flow is deployed and
# working: discovery -> DCR at /oauth/register -> PKCE -> consent -> token.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the OAuth access token.
  type: "streamable-http"
  url: "https://mcp.tryunsora.com/mcp"
---

# Unsora MCP Server

Unsora's official hosted MCP server. Agents can generate videos, images, and music, build AI influencer content, cut clips, caption footage, create thumbnails, and schedule social posts.

## How authentication works

1. Click **Connect** on the Unsora card. A popup opens Unsora's sign-in.
2. Sign in to your Unsora account and approve the requested access.
3. The platform stores the resulting OAuth token encrypted and refreshes it
   automatically. Agents never see it; it is sent at session start.

No API key to copy or paste. If the connection shows **Reconnect**, the grant
expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- Generation volume is metered against your Unsora plan.
- Post scheduling publishes to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
