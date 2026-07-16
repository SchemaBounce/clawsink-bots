---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: heroku
  displayName: "Heroku"
  version: "1.0.0"
  description: "Heroku's official hosted MCP server. Manage apps, dynos, add-ons, and deployments with your Heroku account."
  tags: ["heroku", "paas", "deployment", "cloud", "apps"]
  category: "cloud-infra"
  author: "heroku"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR), live-probed
# 2026-07-16: AS mcp.heroku.com, DCR at /reg. Scopes omitted: the AS
# advertises openid + offline_access and the client must request
# offline_access for refresh tokens; pinning would risk breaking refresh.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.heroku.com/mcp"

env: []
---

# Heroku MCP Server

Heroku's official hosted MCP server. Agents can list and manage apps, scale dynos, inspect add-ons, and trigger deployments.

## How authentication works

1. Click **Connect account** on the Heroku card.
2. A Heroku sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
