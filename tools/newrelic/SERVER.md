---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: newrelic
  displayName: "New Relic"
  version: "1.0.0"
  description: "New Relic's official hosted MCP server. Connect with your New Relic account to query APM, logs, and metrics."
  tags: ["observability", "apm", "monitoring", "logs"]
  category: "developer-tools"
  author: "new-relic"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.newrelic.com/mcp"

env: []
---

# New Relic MCP Server

New Relic's official hosted MCP server. Connect with your New Relic account to query APM, logs, and metrics.

## How authentication works

1. Click **Connect account** on the New Relic card.
2. A New Relic sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- No scopes pin: the client requests the server's advertised default set (including the refresh-token scope), so token refresh keeps working.
- Tools are served by the vendor and discovered at session start (APM, logs, metrics, and NRQL queries).
