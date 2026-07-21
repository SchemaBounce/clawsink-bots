---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: launchdarkly
  displayName: "LaunchDarkly"
  version: "1.0.0"
  description: "LaunchDarkly's official hosted MCP server. Manage feature flags, AgentControl configs, and query observability data (logs, traces, errors) from your LaunchDarkly account."
  tags: ["launchdarkly", "feature-flags", "observability", "developer-tools"]
  category: "developer-tools"
  author: "launchdarkly"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (popular-tools sweep). AS mcp.launchdarkly.com,
# DCR verified. Scopes omitted: the client requests the AS's advertised
# default (reader, writer, observability), which keeps token refresh intact.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.launchdarkly.com/mcp/launchdarkly"

env: []
---

# LaunchDarkly MCP Server

LaunchDarkly's official hosted MCP server. Manage feature flags, AgentControl configs, and query observability data (logs, traces, errors, dashboards) from your LaunchDarkly account.

## How authentication works

1. Click **Connect account** on the LaunchDarkly card.
2. A LaunchDarkly sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by LaunchDarkly and discovered at session start (feature
  flags, AgentControl configs, observability queries).
- Flag changes and other write-class tools follow the platform's approval
  rules for agent actions.
