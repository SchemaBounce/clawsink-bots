---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: socialchamp
  displayName: "Social Champ"
  version: "1.0.0"
  description: "Social Champ's official hosted MCP server. Schedule and manage social posts with Social Champ with your Social Champ account."
  tags: ["social-champ", "scheduling", "social-media", "publishing"]
  category: "social-media"
  author: "socialchamp"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16 (social content sweep). AS mcp.socialchamp.com, DCR at /oauth2/mcp/register. Scopes pinned to read_profile + manage_post (manage_team excluded, least privilege; no offline_access advertised so the pin cannot break refresh).
auth:
  type: oauth2_mcp
  scopes: ["read_profile", "manage_post"]

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.socialchamp.com/mcp"

env: []
---

# Social Champ MCP Server

Social Champ's official hosted MCP server. Schedule and manage social posts with Social Champ.

## How authentication works

1. Click **Connect account** on the Social Champ card.
2. A Social Champ sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Publishing tools post to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
