---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: coda
  displayName: "Coda"
  version: "1.0.0"
  description: "Coda's official hosted MCP server. Read and write Coda docs, tables, and rows using plain-language requests against your Coda account."
  tags: ["coda", "docs", "productivity"]
  category: "productivity"
  author: "coda"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (popular-tools sweep). AS coda.io, DCR verified.
# Scopes omitted: the client requests the AS's single advertised scope
# (mcp:all).
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://coda.io/apis/mcp"

env: []
---

# Coda MCP Server

Coda's official hosted MCP server. Read and write Coda docs, tables, and rows using plain-language requests against your Coda account.

## How authentication works

1. Click **Connect account** on the Coda card.
2. A Coda sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Access is scoped to the docs and tables the connecting user can already see
  in Coda.
- Tools are served by Coda and discovered at session start.
- Write-class tools (editing docs, rows) follow the platform's approval rules
  for agent actions.
