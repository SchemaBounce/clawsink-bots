---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: front
  displayName: "Front"
  version: "1.0.0"
  description: "Front's official hosted MCP server. Read and act on conversations, contacts, and the Front API using natural language."
  tags: ["front", "support", "customer-support", "inbox", "crms-sales"]
  category: "crms-sales"
  author: "front"
  license: "Proprietary"

# Front's authorization server has no RFC 8414 metadata and no RFC 7591
# dynamic client registration, so this entry uses the pinned-client path:
# endpoints pinned below, client supplied by the platform. The client is
# scoped to MCP Server feature access only; the scope below is the single
# scope Front's MCP server advertises.
auth:
  type: oauth2_mcp
  client_id_env: FRONT_MCP_OAUTH_CLIENT_ID
  client_secret_env: FRONT_MCP_OAUTH_CLIENT_SECRET
  scopes:
    - "feature:mcp"

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.frontapp.com/mcp"

env: []
---

# Front MCP Server

Front's official hosted MCP server. Read and act on conversations, contacts, and the Front API using natural language, backed by Front's own API documentation.

## How authentication works

1. Click **Connect account** on the Front card.
2. A Front sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on Front's side; run the connect flow again.

## Notes

- Authorization is user-scoped: an agent can only see and act on data the connecting Front user has permission to view.
- Tools are served by Front and discovered at session start.
