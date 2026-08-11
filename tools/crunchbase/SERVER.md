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

# Crunchbase's authorization server has no RFC 8414 metadata and no RFC 7591
# dynamic client registration, so this entry uses the pinned-client path:
# endpoints pinned below, client supplied by the platform. Scopes are pinned
# to the two scopes Crunchbase's authorization server advertises.
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

- This tile only works once the platform's Crunchbase OAuth client is provisioned. Crunchbase issues that client through its Enterprise/API sales process, not a self-serve developer console.
- Tools are served by Crunchbase and discovered at session start.
