---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: discord
  displayName: "Discord"
  version: "2.1.0"
  description: "Discord community management via Composio. Post and read channel messages, add reactions, read servers and members, and manage channels through a connected Discord bot."
  tags: ["discord", "community", "social", "messaging", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "DISCORDBOT"
  setupReason: "Authorized via Composio's managed gateway against a connected Discord bot. The agent calls execute_composio_tool with DISCORDBOT_* action names (e.g. DISCORDBOT_CREATE_MESSAGE, DISCORDBOT_LIST_MESSAGES, DISCORDBOT_ADD_MY_MESSAGE_REACTION)."
transport:
  # Remote streamable-HTTP. The scoped, per-connected-account Composio MCP URL is
  # resolved at connection time (ComposioOAuthClient.EnsureMcpInstanceURL) and stored
  # on the connection's transport_config, where the gateway reads it. There is no
  # local command: the former `npx @composio/mcp` recipe was a CLI that serves no MCP
  # tools and exits before the handshake (gateway child_exited / start 500).
  type: "streamable-http"
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed
  # connection. Leaving this blank uses the workspace's Composio integration for
  # this service; provide a value only to override the managed connection. Do not
  # mark this required:true, that makes the setup/reconnect modal demand a key the
  # managed flow already covers.
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your Discord bot is then connected inside Composio."
    required: false
    sensitive: true

tools:
  - name: create_message
    description: "Post a message to a Discord channel (publish action, gate behind approval)"
    category: messages
  - name: list_messages
    description: "Read recent messages from a channel, with a 1 to 100 limit and author filtering"
    category: messages
  - name: get_message
    description: "Get a single message by id"
    category: messages
  - name: get_channel
    description: "Retrieve a channel's metadata"
    category: channels
  - name: delete_message
    description: "Delete a message the bot posted, or moderate a channel message"
    category: messages
  - name: add_reaction
    description: "Add an emoji reaction to a message"
    category: engagement
  - name: get_guild
    description: "Read a Discord server's settings and metadata"
    category: community
  - name: get_guild_member
    description: "Get a member's profile and roles in a server"
    category: community
  - name: create_channel
    description: "Create a channel in a server"
    category: channels
  - name: create_webhook
    description: "Create a channel webhook for automated posting"
    category: channels
---

# Discord MCP Server

Provides Discord community management tools via Composio's managed gateway, backed by a connected Discord bot. Covers channel posting and message reads, reactions, server and member reads, and channel management.

## Auth Model: Composio (DISCORDBOT)

This server is backed by the Composio DISCORDBOT toolkit (165 tools). Authentication is managed by Composio against a Discord bot you connect once. Bots call `execute_composio_tool` with `DISCORDBOT_*` action names. The friendly tools above are a curated subset that map to real toolkit actions such as `DISCORDBOT_CREATE_MESSAGE`, `DISCORDBOT_LIST_MESSAGES`, `DISCORDBOT_GET_CHANNEL`, and `DISCORDBOT_ADD_MY_MESSAGE_REACTION`.

No manual API key is required for the gateway. The workspace's Composio connection covers authentication, so the `COMPOSIO_API_KEY` env field is optional and acts only as an override.

## Posting Is Approval-Gated

`create_message` posts publicly to a channel. The `social-publishing` skill holds every post behind explicit human approval before it goes live. Reading messages, reactions, and reads are not gated.

## External Requirements

- A **Discord bot application** (create one at discord.com/developers), invited to your server.
- The bot needs the **Message Content intent** enabled to read channel message text, plus channel permissions for the actions you use (Send Messages, Manage Messages, Manage Channels).
- The bot connected in Composio under the DISCORDBOT toolkit.

## Which Bots Use This

- **social-media-manager** -- Posts approved community updates, replies, and reactions to Discord channels, and reads channel context. Posting runs behind the approval gate.
- **social-media-monitor** -- Reads recent channel messages and server context for brand mentions and community health. Monitoring only, no posting.

## Setup

1. Create a Discord bot at [discord.com/developers](https://discord.com/developers/applications), enable the Message Content intent, and invite it to your server.
2. Sign up at [composio.dev](https://composio.dev) and get your API key.
3. In Composio, connect your Discord bot under the DISCORDBOT toolkit.
4. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/discord"
    reason: "Community bots need Discord access to post approved updates and read channel activity"
```
