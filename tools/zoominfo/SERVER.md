---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: zoominfo
  displayName: "ZoomInfo"
  version: "1.0.0"
  description: "ZoomInfo's official hosted MCP server. Look up verified B2B contact and company data, enrich accounts, and pull intent signals with your ZoomInfo account."
  tags: ["zoominfo", "b2b-data", "sales", "crm"]
  category: "crms-sales"
  author: "zoominfo"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (CRM and sales sweep). AS mcp.zoominfo.com, DCR verified.
# Scopes omitted: the client requests the AS's advertised default, which
# keeps offline_access intact for token refresh where the vendor offers it.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.zoominfo.com/mcp"

env: []
---

# ZoomInfo MCP Server

ZoomInfo's official hosted MCP server. Look up verified B2B contact and company data, enrich accounts, and pull intent signals with your ZoomInfo account.

## How authentication works

1. Click **Connect account** on the ZoomInfo card.
2. A ZoomInfo sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
- Write-class tools (creating or updating CRM records, enrolling prospects,
  sending outreach) follow the platform's approval rules for agent actions.
