---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: asana-remote
  displayName: "Asana (Official)"
  version: "1.0.0"
  description: "Asana's official hosted MCP server. Connect with your Asana account; no API key or Composio setup needed."
  tags: ["tasks", "project-management", "work", "collaboration"]
  category: "productivity"
  author: "asana"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and notion-remote. There is NO pasted
# credential: the platform runs the consent flow against the vendor's own
# authorization server and keeps the access token fresh. The env spec is empty
# on purpose; a declared var would render a credential form no one can fill.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.asana.com/mcp"

env: []
---

# Asana (Official) MCP Server

Asana's official hosted MCP server. Connect with your Asana account; no API key or Composio setup needed.

## How authentication works

1. Click **Connect account** on the Asana (Official) card.
2. A Asana (Official) sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- No scopes pin: the authorization server advertises none, so the scope parameter is omitted.
- Tools are served by the vendor and discovered at session start (tasks, projects, and workspaces).
- Separate from the Composio-routed tools/asana toolkit; prefer this entry for Asana's own hosted server.
