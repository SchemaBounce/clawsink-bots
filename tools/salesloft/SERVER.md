---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: salesloft
  displayName: "Salesloft"
  version: "1.0.0"
  description: "Salesloft's official hosted MCP server. Read accounts, people, opportunities, and conversation data from your Salesloft workspace."
  tags: ["salesloft", "sales-engagement", "sales", "crm"]
  category: "crms-sales"
  author: "salesloft"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (CRM and sales sweep). AS mcp.salesloft.com, DCR verified.
# Scopes omitted: the client requests the AS's advertised default, which
# keeps offline_access intact for token refresh where the vendor offers it.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.salesloft.com/mcp"

env: []
---

# Salesloft MCP Server

Salesloft's official hosted MCP server. Read accounts, people, opportunities, and conversation data from your Salesloft workspace.

## How authentication works

1. Click **Connect account** on the Salesloft card.
2. A Salesloft sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
- Write-class tools (creating or updating CRM records, enrolling prospects,
  sending outreach) follow the platform's approval rules for agent actions.
