---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: make
  displayName: "Make"
  version: "1.0.0"
  description: "Make's official hosted MCP server. Run scenarios and manage the contents of your Make account."
  tags: ["make", "automation", "workflow", "integromat"]
  category: "automation"
  author: "make"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (popular-tools sweep). Protected-resource metadata at
# mcp.make.com points to AS issuer https://www.make.com/mcp; DCR verified
# (registration_endpoint present). Scopes omitted: none advertised by the AS,
# and grant_types_supported includes refresh_token so token refresh keeps
# working with whatever scope the authorization grants.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.make.com/"

env: []
---

# Make MCP Server

Make's official hosted MCP server. Run scenarios and manage the contents of your Make account.

## How authentication works

1. Click **Connect account** on the Make card.
2. A Make sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Running a scenario can trigger real side effects in every app that
  scenario touches. Scenario-run tools follow the platform's approval rules
  for agent actions.
- Tools are served by Make and discovered at session start.
