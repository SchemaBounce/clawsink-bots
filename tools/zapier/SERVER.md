---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: zapier
  displayName: "Zapier"
  version: "2.0.0"
  description: "Zapier's official hosted MCP server. Run actions across your connected Zapier apps; no API key or Composio setup."
  tags: ["zapier", "automation", "workflow", "integration"]
  category: "automation"
  author: "zapier"
  license: "Proprietary"

# Migrated from the Composio-routed toolkit to Zapier's official hosted remote
# (remote hosted OAuth is the default; we no longer pay Composio for managed auth).
# Existing connections keep their serverRef and reconnect once via the OAuth flow.
# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16: AS mcp.zapier.com, DCR at /api/v1/oauth/register.
# Scopes omitted: the AS advertises identity scopes only; the client requests
# the advertised default.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.zapier.com/api/mcp/mcp"

env: []
---

# Zapier MCP Server

Zapier's official hosted MCP server. Agents can run actions across the apps connected to your Zapier account.

## How authentication works

1. Click **Connect account** on the Zapier card.
2. A Zapier sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by Zapier and reflect the actions you have configured for MCP in your Zapier account.
- Replaces the Composio-routed Zapier toolkit. An existing connection shows Reconnect once, then uses OAuth.
