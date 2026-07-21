---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: ashby
  displayName: "Ashby"
  version: "1.0.0"
  description: "Ashby's official hosted MCP server. Query your recruiting pipeline, prepare for interviews, and take actions in Ashby."
  tags: ["ashby", "recruiting", "ats", "hr"]
  category: "hr"
  author: "ashby"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (popular-tools sweep). AS mcp-auth.ashbyhq.com/oidc,
# DCR verified. Scopes omitted: the client requests the AS's advertised
# default (openid, mcp, offline_access), which keeps token refresh intact.
# Each connecting user completes their own OAuth flow; results are scoped to
# what that user can already see in Ashby.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.ashbyhq.com/mcp/v1"

env: []
---

# Ashby MCP Server

Ashby's official hosted MCP server. Query your recruiting pipeline, prepare for interviews, and take actions in Ashby.

## How authentication works

1. Click **Connect account** on the Ashby card.
2. An Ashby sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Ashby authenticates each connecting user individually; the server only
  returns data that user can already see in Ashby.
- Tools are served by Ashby and discovered at session start.
- Write-class tools follow the platform's approval rules for agent actions.
