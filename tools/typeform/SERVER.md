---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: typeform
  displayName: "Typeform"
  version: "1.0.0"
  description: "Typeform's official hosted MCP server. Read forms and read or write contacts in your Typeform account."
  tags: ["typeform", "forms", "surveys", "marketing"]
  category: "marketing"
  author: "typeform"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (popular-tools sweep). AS api.typeform.com, DCR
# verified. Scopes omitted: the client requests the AS's advertised default
# (offline_access, accounts:read, forms:read, forms:write, images:read,
# images:write), which keeps token refresh intact. Early-access beta per
# Typeform's own docs: read-only forms access, basic read-write on contacts.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://api.typeform.com/mcp"

env: []
---

# Typeform MCP Server

Typeform's official hosted MCP server (early-access beta). Read forms and read or write contacts in your Typeform account.

## How authentication works

1. Click **Connect account** on the Typeform card.
2. A Typeform sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Typeform's server is in beta: forms access is read-only, contacts access is
  read and write.
- Tools are served by Typeform and discovered at session start.
- Write-class tools follow the platform's approval rules for agent actions.
