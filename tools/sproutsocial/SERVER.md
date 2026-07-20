---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: sproutsocial
  displayName: "Sprout Social"
  version: "1.0.0"
  description: "Sprout Social's official hosted MCP server. Manage social publishing, engagement, and reporting in Sprout Social with your Sprout Social account."
  tags: ["sprout-social", "social-media", "publishing", "engagement"]
  category: "social-media"
  author: "sproutsocial"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16 (social content sweep). AS identity.sproutsocial.com (tenant-scoped issuer), DCR served from mcp.sproutsocial.com.
# Scopes omitted: the client requests the AS's advertised default, which
# keeps offline_access intact for token refresh where the vendor offers it.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.sproutsocial.com/mcp"

env: []
---

# Sprout Social MCP Server

Sprout Social's official hosted MCP server. Manage social publishing, engagement, and reporting in Sprout Social.

## How authentication works

1. Click **Connect account** on the Sprout Social card.
2. A Sprout Social sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Publishing tools post to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
