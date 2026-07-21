---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: crunchbase
  displayName: "Crunchbase"
  version: "1.0.0"
  description: "Crunchbase's official hosted MCP server. Look up company, funding, and people data from Crunchbase."
  tags: ["crunchbase", "company-data", "funding", "market-intelligence"]
  category: "analytics"
  author: "crunchbase"
  license: "Proprietary"

# MCP-spec OAuth 2.1 challenge + RFC 8414 discovery, live-probed 2026-07-21:
# AS https://www.crunchbase.com serves metadata (authorization_endpoint
# www.crunchbase.com/oauth/authorize, token_endpoint
# oauth.crunchbase.com/token) but offers NO RFC 7591 DCR, so this entry uses
# the pinned-client path (P2-2): client resolved from a
# SchemaBounce-registered Crunchbase OAuth client
# (CRUNCHBASE_MCP_OAUTH_CLIENT_ID / CRUNCHBASE_MCP_OAUTH_CLIENT_SECRET).
# UNLIKE the other pinned entries in this catalog, Crunchbase has no public
# self-serve developer portal for this: full API/MCP access requires an
# Enterprise or Applications license, and the OAuth client is issued by
# Crunchbase's team on request. PRECONDITION: contact Crunchbase (via the
# workspace's Crunchbase account rep, or the API sales form at
# about.crunchbase.com/products/crunchbase-api) and request an OAuth client
# for the hosted MCP server with redirect URI
#   <api-base>/api/v1/oauth/mcp/callback
# for every environment that serves this tile. See
# clawsink-bots/docs/PINNED_CLIENT_REGISTRATIONS.md for the full runbook.
# Scopes are pinned to the two scopes Crunchbase's AS advertises.
auth:
  type: oauth2_mcp
  client_id_env: CRUNCHBASE_MCP_OAUTH_CLIENT_ID
  client_secret_env: CRUNCHBASE_MCP_OAUTH_CLIENT_SECRET
  scopes:
    - "offline_access"
    - "lists.read"

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.crunchbase.com/mcp"

env: []
---

# Crunchbase MCP Server

Crunchbase's official hosted MCP server. Look up company, funding round, acquisition, and people data from Crunchbase.

## How authentication works

1. Click **Connect account** on the Crunchbase card.
2. A Crunchbase sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on Crunchbase's side; run the connect flow again.

## Notes

- This tile only works once the platform's Crunchbase OAuth client is provisioned. Crunchbase issues that client through its Enterprise/API sales process, not a self-serve developer console; see the operator runbook.
- Tools are served by Crunchbase and discovered at session start.
