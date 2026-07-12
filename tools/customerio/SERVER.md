---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: customerio
  displayName: "Customer.io"
  version: "1.0.0"
  description: "Customer.io's official hosted MCP server. Connect with your Customer.io account to work with people and campaigns."
  tags: ["marketing", "messaging", "automation", "email"]
  category: "communication"
  author: "customer-io"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp
  scopes: ["read", "write"]

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.customer.io/mcp"

env: []
---

# Customer.io MCP Server

Customer.io's official hosted MCP server. Connect with your Customer.io account to work with people and campaigns.

## How authentication works

1. Click **Connect account** on the Customer.io card.
2. A Customer.io sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to read, write.
- Tools are served by the vendor and discovered at session start (people, campaigns, and broadcasts).
- Pinned to read/write; the sensitive-read, live-write, and configure scopes are left out (least privilege).
