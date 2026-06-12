---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: discord
  displayName: "Discord"
  version: "2.0.0"
  description: "Discord account and community reads via Composio managed-OAuth. List the connected account's servers, read server-widget presence, resolve invites, and read user profiles and linked connections."
  tags: ["discord", "community", "social", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "DISCORD"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent calls execute_composio_tool with DISCORD_* action names (e.g. DISCORD_LIST_MY_GUILDS, DISCORD_GET_GUILD_WIDGET, DISCORD_GET_MY_USER)."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@composio/mcp@1.0.9"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed OAuth
  # connection. Leaving this blank uses the workspace's Composio integration for
  # this service; provide a value only to override the managed connection. Do not
  # mark this required:true, that makes the setup/reconnect modal demand a key the
  # managed OAuth flow already covers.
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your Discord account is then connected inside Composio via OAuth."
    required: false
    sensitive: true

tools:
  - name: list_my_guilds
    description: "List the Discord servers the connected account belongs to"
    category: community
  - name: get_my_guild_member
    description: "Get the connected account's membership details in a server"
    category: community
  - name: get_guild_widget
    description: "Read a server's public widget: online member count, voice channels, and instant invite"
    category: community
  - name: get_guild_template
    description: "Retrieve a server template's structure"
    category: community
  - name: resolve_invite
    description: "Resolve a Discord invite code to its server and channel metadata"
    category: community
  - name: get_my_user
    description: "Get the connected account's own profile"
    category: profile
  - name: get_user
    description: "Retrieve a Discord user's public profile by id"
    category: profile
  - name: list_my_connections
    description: "List third-party accounts linked to the connected Discord account"
    category: profile
  - name: list_sticker_packs
    description: "List the available Discord sticker packs"
    category: profile
---

# Discord MCP Server

Provides Discord account and community read tools via Composio's managed-OAuth gateway. Covers the connected account's server list and membership, public server-widget presence, invite resolution, and user profile reads.

## Auth Model: Composio

This server is backed by the Composio DISCORD toolkit (27 tools). Authentication is managed by Composio. The user connects their Discord account in Composio via OAuth once, then bots call `execute_composio_tool` with `DISCORD_*` action names. The friendly tools above map to real toolkit actions such as `DISCORD_LIST_MY_GUILDS`, `DISCORD_GET_GUILD_WIDGET`, `DISCORD_GET_MY_GUILD_MEMBER`, and `DISCORD_INVITE_RESOLVE`.

No manual API key is required. The workspace's Composio-managed OAuth connection covers authentication, so the `COMPOSIO_API_KEY` env field is optional and acts only as an override.

## Scope: Account and Community Reads, Not Channel Messaging

The Composio DISCORD toolkit is an account-level OAuth integration. It reads the connected account's servers, membership, server-widget presence, invites, profile, and linked connections. It does not send messages to channels and does not read channel message history. Posting and channel-message reads need a separate Discord bot-token integration (the Composio DISCORDBOT toolkit), which is not wired here. Bots that reference this server should treat it as a read-only community-context source.

## External Requirements

- A **Discord account** connected in Composio via OAuth.
- The connected account must be a member of the servers you want to read.
- Server-widget reads (`get_guild_widget`) only return data for servers that have the widget enabled in Server Settings.

## Which Bots Use This

- **social-media-manager** -- Reads server membership and presence for community context. It does not post to Discord.
- **social-media-monitor** -- Reads server membership and server-widget presence for community-health signals. Monitoring only, no posting.

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key.
2. Add `COMPOSIO_API_KEY` to your workspace secrets if you want to override the managed connection. Otherwise leave it blank.
3. In Composio, connect your Discord account via OAuth under the Discord toolkit.
4. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/discord"
    reason: "Community bots need read access to Discord servers and presence for community context"
```
