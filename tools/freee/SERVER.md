---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: freee
  displayName: "freee"
  version: "1.0.0"
  description: "Japanese accounting, HR, and invoicing platform. Connects to freee's official hosted MCP server with your freee account."
  tags: ["accounting", "finance", "invoicing", "hr", "japan", "erp"]
  category: "finance"
  author: "freee"
  license: "Apache-2.0"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR).
# There is NO pasted credential: the platform's generic OAuth client runs the
# consent flow against freee's authorization server and keeps the access token
# fresh (single-use rotating refresh tokens, handled server-side). The env
# spec below is intentionally empty — a declared env var would render a
# credential form the user can never fill.
auth:
  type: oauth2_mcp
  scopes: ["mcp:read", "mcp:write"]

transport:
  # freee's official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.freee.co.jp/mcp"

env: []

# No validation/healthProbe blocks: there is nothing to probe before the user
# consents (no token exists), and after consent the runtime MCP handshake owns
# the health verdict. Tools are discovered live at session start.
---

# freee MCP Server

Connects SchemaBounce agents to [freee](https://www.freee.co.jp/), the Japanese
accounting, HR, and invoicing platform, through freee's official hosted MCP
server at `mcp.freee.co.jp`.

## How authentication works

1. Click **Connect account** on the freee card.
2. A freee sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh.
   Agents never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on freee's side; run the connect flow again.

## Notes

- Requested scopes: `mcp:read`, `mcp:write` (freee's advertised set).
- Tools are served by freee and discovered at session start; the set spans
  accounting, HR, invoicing, and related freee APIs.
- freee rotates refresh tokens on every use. The platform serializes token
  refresh, so multiple agents can share the connection safely.
