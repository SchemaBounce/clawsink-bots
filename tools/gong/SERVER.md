---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: gong
  displayName: "Gong"
  version: "1.0.0"
  description: "Gong's official hosted MCP server. Ask questions about accounts and deals and generate briefs from call and CRM activity in your Gong workspace."
  tags: ["gong", "sales", "revenue-intelligence", "calls", "crm"]
  category: "crms-sales"
  author: "gong"
  license: "Proprietary"

# MCP-spec OAuth 2.1 challenge + RFC 8414 discovery, live-probed 2026-07-21:
# AS https://mcp.gong.io serves metadata (authorization_endpoint
# app.gong.io/oauth2/authorize, token_endpoint
# app.gong.io/oauth2/generate-mcp-token) but offers NO RFC 7591 DCR, so this
# entry uses the pinned-client path (P2-2): client resolved from a
# SchemaBounce-registered Gong integration (GONG_MCP_OAUTH_CLIENT_ID /
# GONG_MCP_OAUTH_CLIENT_SECRET). PRECONDITION: register the integration in
# Gong Admin Center (Settings > Ecosystem > API > Integrations > Create
# Integration) with redirect URI
#   <api-base>/api/v1/oauth/mcp/callback
# for every environment that serves this tile. See
# clawsink-bots/docs/PINNED_CLIENT_REGISTRATIONS.md for the full runbook.
# Scopes are pinned to the three read-only tool scopes Gong's MCP server
# advertises; requesting less than the full set drops the matching tool from
# the session.
auth:
  type: oauth2_mcp
  client_id_env: GONG_MCP_OAUTH_CLIENT_ID
  client_secret_env: GONG_MCP_OAUTH_CLIENT_SECRET
  scopes:
    - "mcp:ai-ask:read"
    - "mcp:ai-briefer:read"
    - "mcp:ai-assistant:read"

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.gong.io/mcp"

env: []
---

# Gong MCP Server

Gong's official hosted MCP server. Ask natural-language questions about a single account or deal and generate a structured brief from call transcripts, tracked topics, and CRM activity in your Gong workspace.

## How authentication works

1. Click **Connect account** on the Gong card.
2. A Gong sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on Gong's side; run the connect flow again.

## Notes

- Tools are read-only: `ask_account`, `ask_deal`, and `generate_brief`. The server does not create, update, or delete data in Gong or a connected CRM.
- Which tools an agent can call depends on the scopes your Gong admin enabled when the integration was registered.
- Tools are served by Gong and discovered at session start.
