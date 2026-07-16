---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: workos
  displayName: "WorkOS"
  version: "1.0.0"
  description: "WorkOS's official hosted MCP server. Manage SSO, directory sync, and organizations with your WorkOS account."
  tags: ["workos", "sso", "identity", "enterprise", "developer-tools"]
  category: "developer-tools"
  author: "workos"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR), live-probed
# 2026-07-16: AS signin.workos.com, DCR at /oauth2/register. Scopes omitted:
# the AS advertises identity scopes + offline_access; the client requests
# the advertised default.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.workos.com/mcp"

env: []
---

# WorkOS MCP Server

WorkOS's official hosted MCP server. Agents can inspect and manage WorkOS organizations, SSO connections, and directory sync state.

## How authentication works

1. Click **Connect account** on the WorkOS card.
2. A WorkOS sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
