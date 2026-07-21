---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: chargebee
  displayName: "Chargebee"
  version: "1.0.0"
  description: "Chargebee's official hosted MCP server. Look up customers, subscriptions, invoices, and payments and answer questions from Chargebee's docs."
  tags: ["chargebee", "billing", "subscriptions", "finance", "invoicing"]
  category: "finance"
  author: "chargebee"
  license: "Proprietary"

# MCP-spec OAuth 2.1 challenge + RFC 8414 discovery, live-probed 2026-07-21:
# AS https://app.chargebee.com/mcp serves metadata (authorization_endpoint
# app.chargebee.com/oauth2/authorize, token_endpoint
# app.chargebee.com/oauth2/token) but offers NO RFC 7591 DCR, so this entry
# uses the pinned-client path (P2-2): client resolved from a
# SchemaBounce-registered Chargebee OAuth app (CHARGEBEE_MCP_OAUTH_CLIENT_ID).
# Chargebee's AS advertises token_endpoint_auth_methods_supported: ["none"]
# only; it is a PUBLIC client (PKCE, no client secret), so no
# client_secret_env is set here; do not add one. PRECONDITION: register the
# OAuth app in the Chargebee dashboard (Settings > Configure Chargebee > API
# & Webhooks > OAuth Apps > Create an OAuth App) with redirect URI
#   <api-base>/api/v1/oauth/mcp/callback
# for every environment that serves this tile. See
# clawsink-bots/docs/PINNED_CLIENT_REGISTRATIONS.md for the full runbook. No
# scopes are pinned: Chargebee's AS metadata advertises none, and the MCP
# server's access is scoped to the site the OAuth app was created on.
auth:
  type: oauth2_mcp
  client_id_env: CHARGEBEE_MCP_OAUTH_CLIENT_ID

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.chargebee.com/mcp"

env: []
---

# Chargebee MCP Server

Chargebee's official hosted MCP server. Look up customer, subscription, invoice, and payment data from a connected Chargebee site, and answer questions using Chargebee's product docs and API reference.

## How authentication works

1. Click **Connect account** on the Chargebee card.
2. A Chargebee sign-in window opens. Approve access for the site tied to the registered OAuth app.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on Chargebee's side; run the connect flow again.

## Notes

- Data access is limited to the single Chargebee site the platform's OAuth app was registered against. A workspace that needs a different site needs its own registered app; see the runbook.
- Tools are served by Chargebee and discovered at session start.
