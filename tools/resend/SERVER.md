---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: resend
  displayName: "Resend"
  version: "1.0.0"
  description: "Resend's official hosted MCP server. Connect with your Resend account to send and manage email."
  tags: ["email", "transactional", "messaging", "developer-tools"]
  category: "communication"
  author: "resend"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp
  scopes: ["full_access"]

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.resend.com/mcp"

env: []
---

# Resend MCP Server

Resend's official hosted MCP server. Connect with your Resend account to send and manage email.

## How authentication works

1. Click **Connect account** on the Resend card.
2. A Resend sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to full_access.
- Tools are served by the vendor and discovered at session start (emails, domains, and audiences).
- Pinned to full_access so every Resend tool works; effectful sends route through the Inbox Actions queue.
