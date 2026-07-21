---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: instantly
  displayName: "Instantly"
  version: "1.0.0"
  description: "Instantly's official hosted MCP server. Manage cold email campaigns, leads, and inbox placement with your Instantly account."
  tags: ["instantly", "cold-email", "sales", "crm"]
  category: "crms-sales"
  author: "instantly"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (CRM and sales sweep). AS api.instantly.ai, DCR verified.
# Scopes omitted: the client requests the AS's advertised default, which
# keeps offline_access intact for token refresh where the vendor offers it.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.instantly.ai/mcp"

env: []
---

# Instantly MCP Server

Instantly's official hosted MCP server. Manage cold email campaigns, leads, and inbox placement with your Instantly account.

## How authentication works

1. Click **Connect account** on the Instantly card.
2. A Instantly sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
- Write-class tools (creating or updating CRM records, enrolling prospects,
  sending outreach) follow the platform's approval rules for agent actions.
