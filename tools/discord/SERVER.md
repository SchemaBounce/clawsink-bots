---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: discord
  displayName: "Discord"
  version: "1.0.0"
  description: "Discord bot integration — messages, channels, and server management"
  tags: ["discord", "chat", "community", "messaging"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "discord-mcp-server@1.0.1"]
env:
  - name: DISCORD_BOT_TOKEN
    description: "Discord bot token from discord.com/developers"
    required: true
tools:
  - name: send_message
    description: "Send a message to a channel"
    category: messages
  - name: read_messages
    description: "Read recent messages from a channel"
    category: messages
  - name: list_channels
    description: "List channels in a guild"
    category: channels
  - name: list_guilds
    description: "List guilds the bot is a member of"
    category: guilds
  - name: create_channel
    description: "Create a new channel in a guild"
    category: channels
  - name: add_reaction
    description: "Add a reaction to a message"
    category: messages
  - name: get_user
    description: "Get details of a Discord user"
    category: guilds
---

# Discord MCP Server

Provides Discord bot tools for sending messages, managing channels, and interacting with server communities.

## Which Bots Use This

- **devrel** -- Manages developer community channels, responds to questions, posts announcements
- **customer-support** -- Monitors community support channels for customer issues
- **community-manager** -- Moderates discussions, tracks engagement metrics
- **marketing-coordinator** -- Posts product updates and announcements

## Setup

1. Create a Discord bot at the [Discord Developer Portal](https://discord.com/developers/applications)
2. Copy the bot token and add it to your workspace secrets as `DISCORD_BOT_TOKEN`
3. Invite the bot to your server with appropriate permissions
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Discord server instance across bots:

```yaml
mcpServers:
  - ref: "tools/discord"
    reason: "Community bots need Discord access for engagement and support"
    config:
      default_guild_id: "your-guild-id"
```
