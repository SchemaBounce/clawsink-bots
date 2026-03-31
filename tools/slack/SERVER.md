---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: slack
  displayName: "Slack"
  version: "1.0.0"
  description: "Slack workspace tools for channels, messages, and user management"
  tags: ["slack", "messaging", "channels", "notifications"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-slack"]
env:
  - name: SLACK_BOT_TOKEN
    description: "Slack Bot User OAuth Token (xoxb-...)"
    required: true
  - name: SLACK_TEAM_ID
    description: "Slack workspace/team ID"
    required: true
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
  - name: slack_search_messages
    description: "Search messages across the workspace"
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
3. Add `SLACK_BOT_TOKEN` and `SLACK_TEAM_ID` to your workspace secrets

## Team Usage

```yaml
mcpServers:
  - ref: "tools/slack"
    reason: "Team bots post updates and alerts to Slack channels"
    config:
      default_channel: "#ops-alerts"
```
