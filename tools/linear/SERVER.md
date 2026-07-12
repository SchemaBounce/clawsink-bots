---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: linear
  displayName: "Linear"
  version: "1.0.0"
  description: "Linear's official hosted MCP server. Connect with your Linear account; no API key or Composio setup."
  tags: ["issues", "project-management", "engineering", "sprints"]
  category: "developer-tools"
  author: "linear"
  license: "Proprietary"

# This entry replaces the Composio-routed Linear toolkit: remote hosted OAuth is the default
# so we no longer pay Composio for managed auth. Existing connections keep
# their serverRef and reconnect once via the OAuth flow.
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
  url: "https://mcp.linear.app/mcp"

env: []
---

# Linear MCP Server

Linear's official hosted MCP server. Connect with your Linear account; no API key or Composio setup.

## How authentication works

1. Click **Connect account** on the Linear card.
2. A Linear sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to read, write.
- Tools are served by the vendor and discovered at session start (issues, projects, cycles, and comments).
- Replaces the Composio-routed Linear toolkit. An existing connection shows Reconnect once, then uses OAuth.
