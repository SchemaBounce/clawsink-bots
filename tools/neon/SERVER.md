---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: neon
  displayName: "Neon"
  version: "1.0.0"
  description: "Neon's official hosted MCP server. Connect with your Neon account to manage serverless Postgres projects and branches."
  tags: ["database", "postgres", "serverless", "branching"]
  category: "developer-tools"
  author: "neon"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp
  scopes: ["read", "write"]

transport:
  # Official hosted remote MCP endpoint (SSE). Nothing runs in our
  # gateway; sessions connect by URL with the platform-managed bearer token.
  type: "sse"
  url: "https://mcp.neon.tech/sse"

env: []
---

# Neon MCP Server

Neon's official hosted MCP server. Connect with your Neon account to manage serverless Postgres projects and branches.

## How authentication works

1. Click **Connect account** on the Neon card.
2. A Neon sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to read, write.
- Tools are served by the vendor and discovered at session start (projects, branches, and databases).
- This server uses the SSE transport.
