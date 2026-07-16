---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mercury
  displayName: "Mercury"
  version: "1.0.0"
  description: "Mercury's official hosted MCP server. Read business banking accounts, transactions, and statements with your Mercury account."
  tags: ["mercury", "banking", "finance", "transactions", "treasury"]
  category: "finance"
  author: "mercury"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR), live-probed
# 2026-07-16: AS mcp.mercury.com, DCR at /register. The AS advertises only
# read + offline_access (read-only banking data by design); scopes omitted so
# the client requests that advertised default, including offline_access for
# refresh tokens.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.mercury.com/mcp"

env: []
---

# Mercury MCP Server

Mercury's official hosted MCP server. Agents can read business bank account balances, transactions, and statements for reporting and reconciliation. The vendor's OAuth surface is read-only.

## How authentication works

1. Click **Connect account** on the Mercury card.
2. A Mercury sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- The vendor advertises read-only scopes; agents cannot move money through this server.
- Tools are served by the vendor and discovered at session start.
