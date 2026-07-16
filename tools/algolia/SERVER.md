---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: algolia
  displayName: "Algolia"
  version: "1.0.0"
  description: "Algolia's official hosted MCP server. Manage search indices, records, and analytics with your Algolia account."
  tags: ["algolia", "search", "indexing", "analytics"]
  category: "developer-tools"
  author: "algolia"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR), live-probed
# 2026-07-16: AS dashboard.algolia.com, DCR at /2/oauth/register. Scopes
# omitted (resource metadata advertises only "public"); the client requests
# the advertised default.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.algolia.com/mcp"

env: []
---

# Algolia MCP Server

Algolia's official hosted MCP server. Agents can inspect and manage search indices, records, and search analytics.

## How authentication works

1. Click **Connect account** on the Algolia card.
2. An Algolia sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
