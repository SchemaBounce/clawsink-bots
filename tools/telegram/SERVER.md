---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: telegram
  displayName: "Telegram"
  version: "1.0.0"
  description: "Telegram bot API, messages, channels, groups, and media"
  tags: ["telegram", "messaging", "bot", "chat"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "TELEGRAM"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like TELEGRAM_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "telegram-mcp@0.1.20"]
env:
  - name: TELEGRAM_BOT_TOKEN
    description: "Telegram bot token from @BotFather"
    required: true
tools:
  - name: send_message
    description: "Send a text message to a chat"
    category: messages
  - name: get_updates
    description: "Get incoming updates from Telegram"
    category: messages
  - name: send_photo
    description: "Send a photo to a chat"
    category: media
  - name: send_document
    description: "Send a document to a chat"
    category: media
  - name: get_chat
    description: "Get information about a chat"
    category: chats
  - name: list_chat_members
    description: "List members of a chat"
    category: chats
  - name: edit_message
    description: "Edit an existing message"
    category: messages
  - name: delete_message
    description: "Delete a message from a chat"
    category: messages
---

# Telegram MCP Server

Provides Telegram Bot API tools for sending messages, managing channels and groups, and sharing media.

## Which Bots Use This

- **customer-support** -- Monitors and responds to customer messages in Telegram channels
- **marketing-manager** -- Sends broadcast messages and media to Telegram subscriber channels

## Setup

1. Create a bot via [@BotFather](https://t.me/BotFather) on Telegram and copy the bot token
2. Add `TELEGRAM_BOT_TOKEN` to your workspace secrets
3. Add the bot to your target channels or groups
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Telegram server instance across bots:

```yaml
mcpServers:
  - ref: "tools/telegram"
    reason: "Bots need Telegram access for customer messaging and broadcasts"
    config:
      default_parse_mode: "HTML"
```
