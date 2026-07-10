---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: atlassian
  displayName: "Atlassian (Jira, Confluence)"
  version: "1.0.0"
  description: "Atlassian's official hosted MCP server for Jira and Confluence. Connect with your Atlassian account; one grant covers both."
  tags: ["jira", "confluence", "issues", "wiki", "project-management"]
  category: "productivity"
  author: "atlassian"
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
  url: "https://mcp.atlassian.com/v1/mcp"

env: []
---

# Atlassian (Jira, Confluence) MCP Server

Atlassian's official hosted MCP server for Jira and Confluence. Connect with your Atlassian account; one grant covers both.

## How authentication works

1. Click **Connect account** on the Atlassian (Jira, Confluence) card.
2. A Atlassian (Jira, Confluence) sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- No scopes pin: the authorization server advertises none, so the scope parameter is omitted.
- Tools are served by the vendor and discovered at session start (issues, projects, pages, and search across Jira and Confluence).
- One connection covers every Atlassian site your account can reach. Atlassian's authorization server lives on a separate host (cf.mcp.atlassian.com); the platform follows the issuer automatically.
