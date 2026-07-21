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

# API-key auth (switched from oauth2_mcp 2026-07-21): the vendor documents
# Authorization Bearer with dashboard-issued uns_live_... keys
# (tryunsora.com/docs/get-started), and the OAuth path is blocked on prod
# until the core-api DCR scope fix (9abd17fe8) deploys - Clerk rejects the
# scope-less dynamic client with invalid_scope. The env name MUST contain
# "token": the runtime derives the Authorization Bearer header from the
# name (buildRemoteAuthHeaderTemplates); an "api_key" name would derive
# X-Api-Key and 401. Revisit OAuth after the DCR fix ships.
auth:
  injection:
    header_name: Authorization
    header_template: "Bearer {UNSORA_API_TOKEN}"

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.tryunsora.com/mcp"

env:
  - name: UNSORA_API_TOKEN
    description: "Unsora API key (uns_live_...) from tryunsora.com, API keys page"
    required: true
    sensitive: true
---

# Unsora MCP Server

Unsora's official hosted MCP server. Agents can generate videos, images, and music, build AI influencer content, cut clips, caption footage, create thumbnails, and schedule social posts.

## How authentication works

1. In Unsora, open the API keys page and click **New API Key**. Copy the
   uns_live_... key right away; it is shown once.
2. Click **Connect** on the Unsora card and paste the key.
3. The platform stores the key encrypted. Agents never see it; it is
   injected as the Authorization header at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Generation volume is metered against your Unsora plan.
- Post scheduling publishes to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
