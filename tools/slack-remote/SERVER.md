---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: slack-remote
  displayName: "Slack Search (hosted)"
  version: "1.0.0"
  description: "Slack's official hosted MCP server. Agents search the messages and files you can see in Slack, with your own permissions, when you ask them to."
  tags: ["slack", "search", "messaging", "knowledge"]
  category: "communication"
  author: "slack"
  license: "Proprietary"

# Slack's authorization server has no dynamic client registration, so this
# entry uses the pinned-client path: endpoints pinned below, client supplied by
# the platform. Slack issues a user token (the person's own permissions), which
# is why this server is meant to be connected as a Personal connection.
# Scopes are read-only search scopes; Slack grants only what the person approves.
auth:
  type: oauth2_mcp
  client_id_env: SLACK_CLIENT_ID
  client_secret_env: SLACK_CLIENT_SECRET
  authorization_endpoint: "https://slack.com/oauth/v2_user/authorize"
  token_endpoint: "https://slack.com/api/oauth.v2.user.access"
  scopes:
    - "search:read.public"
    - "search:read.private"
    - "search:read.im"
    - "search:read.mpim"
    - "search:read.files"
    - "search:read.users"

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.slack.com/mcp"

env: []
---

# Slack Search MCP Server (hosted)

Slack's official hosted MCP server. Agents search the messages and files you can
see in Slack, using your own Slack permissions. SchemaBounce does not copy or
store Slack content; results are returned to the agent for the current request.

## How authentication works

1. Click **Connect account** on the Slack Search card and choose **Personal**.
2. A Slack sign-in window opens. Approve the search access you want to grant.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

Search covers only what you can see. Private channels, direct messages and group
direct messages are searched only if you approve those permissions. It runs only
when you start the request (chat or a manual run). Scheduled and automated runs
have no person behind them and never use your Slack account.

If the connection shows **Reconnect**, the grant expired or was revoked on
Slack's side; run the connect flow again.

## How this differs from the "slack" tool

The existing `slack` tool uses a bot token and acts as an app in the channels it
is invited to. This entry connects to Slack's own hosted server as you, and is
for searching your workspace.

## Notes

- A workspace admin must allow the app in your Slack workspace. Slack limits its
  hosted MCP server to apps published in the Slack Marketplace and internal apps.
- Workspace guests cannot use Slack search through this server.
- Tools are served by Slack and discovered at session start.
