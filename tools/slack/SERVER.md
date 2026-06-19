---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: slack
  displayName: "Slack"
  version: "1.0.0"
  description: "Slack workspace tools for channels, messages, and user management"
  tags: ["slack", "messaging", "channels", "notifications"]
  category: "communication"
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-slack@2025.4.25"]
env:
  - name: SLACK_BOT_TOKEN
    description: "Slack Bot User OAuth Token (xoxb-...)"
    required: true
    sensitive: true
  - name: SLACK_TEAM_ID
    description: "Slack workspace/team ID"
    required: true

# Declarative auth + validation (SchemaBounce MCP_CONNECTION_VALIDATION_SPEC).
# Replaces the hardcoded Go slackValidator. NOTE: Slack's auth.test returns HTTP
# 200 even for an INVALID token (body {"ok":false,"error":"invalid_auth"}), so a
# status-only check would be a false-green — body_contains '"ok":true' is the
# real auth discriminator.
auth:
  type: http_bearer
  token_env: SLACK_BOT_TOKEN
validation:
  request:
    method: POST
    url: "https://slack.com/api/auth.test"
  expect:
    status: 200
    body_contains: '"ok":true'
  on_status:
    "default": { state: needs_setup, message: "Slack bot token rejected — re-add a valid xoxb- token" }
healthProbe:
  request:
    method: POST
    url: "https://slack.com/api/auth.test"
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300
tools:
  - name: slack_list_channels
    description: "List public channels in the workspace"
    category: channels
  - name: slack_post_message
    description: "Post a message to a channel"
    category: messages
  - name: slack_reply_to_thread
    description: "Reply to a message thread"
    category: messages
  - name: slack_add_reaction
    description: "Add an emoji reaction to a message"
    category: messages
  - name: slack_get_channel_history
    description: "Get recent messages from a channel"
    category: channels
  - name: slack_get_thread_replies
    description: "Get replies in a message thread"
    category: messages
  - name: slack_get_users
    description: "List users in the workspace"
    category: users
  - name: slack_get_user_profile
    description: "Get a user's profile information"
    category: users
---

# Slack MCP Server

Provides Slack workspace tools for bots that need to post updates, read channels, and interact with team communications.

## Which Bots Use This

- **executive-assistant** -- Posts briefings to leadership channels
- **customer-support** -- Monitors support channels
- **sre-devops** -- Posts incident alerts and status updates
- **release-manager** -- Announces releases to engineering channels
- **uptime-manager** -- Posts status updates during incidents

## Setup

1. Create a Slack App in your workspace with Bot Token Scopes: `channels:read`, `chat:write`, `reactions:write`, `search:read`, `users:read`
2. Install the app and copy the Bot User OAuth Token
3. Add `SLACK_BOT_TOKEN` and `SLACK_TEAM_ID` in the MCP connection setup

## Team Usage

```yaml
mcpServers:
  - ref: "tools/slack"
    reason: "Team bots post updates and alerts to Slack channels"
    config:
      default_channel: "#ops-alerts"
```
