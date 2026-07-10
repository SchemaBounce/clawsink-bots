---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: sentry-remote
  displayName: "Sentry (Official)"
  version: "1.0.0"
  description: "Sentry's official hosted MCP server. Connect with your Sentry account to let agents read and triage issues."
  tags: ["errors", "monitoring", "observability", "debugging"]
  category: "developer-tools"
  author: "sentry"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and notion-remote. There is NO pasted
# credential: the platform runs the consent flow against the vendor's own
# authorization server and keeps the access token fresh. The env spec is empty
# on purpose; a declared var would render a credential form no one can fill.
auth:
  type: oauth2_mcp
  scopes: ["org:read", "project:write", "team:write", "event:write"]

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.sentry.dev/mcp"

env: []
---

# Sentry (Official) MCP Server

Sentry's official hosted MCP server. Connect with your Sentry account to let agents read and triage issues.

## How authentication works

1. Click **Connect account** on the Sentry (Official) card.
2. A Sentry (Official) sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to org:read, project:write, team:write, event:write.
- Tools are served by the vendor and discovered at session start (organizations, projects, issues, and events).
- Requested scopes: org:read, project:write, team:write, event:write. Separate from the API-token tools/sentry entry.
