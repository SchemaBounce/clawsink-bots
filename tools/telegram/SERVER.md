---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: telegram
  displayName: "Telegram"
  version: "2.0.0"
  description: "Telegram bot API via Composio. Broadcast messages to channels and chats, read updates and chat history, and read chat info and members through a connected Telegram bot."
  tags: ["telegram", "messaging", "social", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "TELEGRAM"
  setupReason: "Authorized via Composio against a Telegram bot you connect with a @BotFather token. The agent calls execute_composio_tool with TELEGRAM_* action names (e.g. TELEGRAM_SEND_MESSAGE, TELEGRAM_GET_UPDATES, TELEGRAM_GET_CHAT_HISTORY)."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@composio/mcp@1.0.9"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio connection.
  # Leaving this blank uses the workspace's Composio integration for this
  # service; provide a value only to override the managed connection. Do not
  # mark this required:true, that makes the setup/reconnect modal demand a key
  # the Composio flow already covers.
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your Telegram bot token from @BotFather is then connected inside Composio."
    required: false
    sensitive: true

tools:
  - name: send_message
    description: "Send a text message to a channel or chat by chat id, 1 to 4096 characters (publish action, gate behind approval)"
    category: messages
  - name: get_updates
    description: "Receive incoming updates via long polling"
    category: messages
  - name: get_chat_history
    description: "Read chat history messages for a chat id"
    category: messages
  - name: get_chat
    description: "Read information about a chat"
    category: chats
  - name: get_chat_member
    description: "Read a member's status in a chat"
    category: chats
  - name: get_chat_administrators
    description: "List the administrators of a chat"
    category: chats
---

# Telegram MCP Server

Provides Telegram bot tools via Composio, backed by a Telegram bot you connect once. Covers channel and chat broadcasts, update polling, chat history reads, and chat info reads.

## Auth Model: Composio (TELEGRAM)

This server is backed by the Composio TELEGRAM toolkit (18 tools). Authentication uses an API key model: a Telegram bot token from @BotFather, connected in Composio. Bots call `execute_composio_tool` with `TELEGRAM_*` action names. The friendly tools above are a curated subset that map to real toolkit actions:

| Friendly tool | Composio action |
|---------------|-----------------|
| send_message | TELEGRAM_SEND_MESSAGE |
| get_updates | TELEGRAM_GET_UPDATES |
| get_chat_history | TELEGRAM_GET_CHAT_HISTORY |
| get_chat | TELEGRAM_GET_CHAT |
| get_chat_member | TELEGRAM_GET_CHAT_MEMBER |
| get_chat_administrators | TELEGRAM_GET_CHAT_ADMINISTRATORS |

## Posting Is Approval-Gated

`send_message` posts publicly to a channel or chat. The `social-publishing` skill holds every broadcast behind explicit human approval before it goes live. Update polling and chat reads are not gated.

## External Requirements

- A **Telegram bot** created via [@BotFather](https://t.me/BotFather). Copy the bot token it gives you.
- That bot token connected in Composio under the Telegram toolkit.
- The bot added to the target channel or group as an **administrator** so it can post.

## Which Bots Use This

- **social-media-manager** -- Broadcasts approved posts to Telegram channels after human approval, and reads channel history. Posting runs behind the approval gate.
- **social-media-monitor** -- Reads channel history for community monitoring. Monitoring only, no posting.

## Setup

1. Create a bot via [@BotFather](https://t.me/BotFather) and copy the bot token.
2. Add the bot to your target channel or group as an administrator.
3. Sign up at [composio.dev](https://composio.dev) and get your API key.
4. In Composio, connect your bot under the Telegram toolkit using the @BotFather token.
5. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/telegram"
    reason: "Social bots need Telegram access for approved channel broadcasts and community monitoring"
```
