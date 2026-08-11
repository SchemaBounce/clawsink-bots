---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: github-remote
  displayName: "GitHub (hosted)"
  version: "1.0.0"
  description: "GitHub's official hosted MCP server. Connect with your GitHub account; no personal access token to paste."
  tags: ["git", "repos", "issues", "pull-requests", "actions", "engineering"]
  category: "developer-tools"
  author: "github"
  license: "Proprietary"

# GitHub's authorization server has no RFC 8414 metadata and no RFC 7591
# dynamic client registration, so this entry uses the pinned-client path:
# endpoints pinned below, client supplied by the platform. Scopes are omitted
# on purpose: a GitHub App's permissions come from the app configuration, and
# GitHub ignores the scope parameter for App authorizations.
auth:
  type: oauth2_mcp
  client_id_env: GH_MCP_CLIENT_ID
  client_secret_env: GH_MCP_CLIENT_SECRET
  authorization_endpoint: "https://github.com/login/oauth/authorize"
  token_endpoint: "https://github.com/login/oauth/access_token"

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://api.githubcopilot.com/mcp/"

env: []
---

# GitHub MCP Server (hosted)

GitHub's official hosted MCP server. Connect with your GitHub account; no personal access token to paste.

## How authentication works

1. Click **Connect account** on the GitHub (hosted) card.
2. A GitHub sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on
GitHub's side; run the connect flow again.

## How this differs from the "github" tool

The existing `github` tool runs GitHub's MCP server inside the platform gateway
and authenticates with a personal access token (or your connected GitHub from
Settings, Git Connections). This entry connects to GitHub's own hosted server
at `api.githubcopilot.com` instead: GitHub operates the server, tools update as
GitHub ships them, and auth is a one-click account connection.

## Notes

- Access rights come from the SchemaBounce GitHub App's permissions and the
  repositories you grant during consent.
- Tools are served by GitHub and discovered at session start (repos, issues,
  pull requests, actions, code search).
