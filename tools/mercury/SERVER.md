---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mercury
  displayName: "Mercury"
  version: "1.0.0"
  description: "Mercury's official hosted MCP server. Work with business banking accounts, transactions, transfer requests, categories, budgets, and receipts through your Mercury account."
  tags: ["mercury", "banking", "finance", "transactions", "treasury"]
  category: "finance"
  author: "mercury"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR): AS mcp.mercury.com,
# DCR at /register. Scopes are omitted so the client requests what the vendor
# advertises. A sign-in on 2026-11-05 granted read, transactions:request,
# transactions:update, categories:create, categories:edit, transfers:request,
# budgets:manage, receipts:manage and offline_access.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.mercury.com/mcp"

env: []
---

# Mercury MCP Server

Mercury's official hosted MCP server. Agents can read business bank account balances, transactions, and statements, and can make the changes your sign-in allows, including requesting transfers.

## How authentication works

1. Click **Connect account** on the Mercury card.
2. A Mercury sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- This connection can write. Use the connection's tool list and the approval policy to choose which tools each agent may use and which ones wait for a person.
- Tools are served by the vendor and discovered at session start.
