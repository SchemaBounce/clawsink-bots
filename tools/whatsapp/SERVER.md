---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: whatsapp
  displayName: "WhatsApp"
  version: "1.0.0"
  description: "WhatsApp Business API, messages, templates, and media"
  tags: ["whatsapp", "messaging", "business", "chat"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "WHATSAPP"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like WHATSAPP_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "whatsapp-mcp@0.1.3"]
env:
  - name: WHATSAPP_ACCESS_TOKEN
    description: "WhatsApp Business API access token"
    required: true
  - name: WHATSAPP_PHONE_NUMBER_ID
    description: "WhatsApp Business phone number ID"
    required: true
tools:
  - name: send_message
    description: "Send a text message to a phone number"
    category: messages
  - name: send_template
    description: "Send a pre-approved template message"
    category: templates
  - name: send_media
    description: "Send an image, video, or document"
    category: media
  - name: get_message_status
    description: "Get delivery status of a sent message"
    category: messages
  - name: list_templates
    description: "List approved message templates"
    category: templates
  - name: get_business_profile
    description: "Get the WhatsApp Business profile"
    category: messages
---

# WhatsApp MCP Server

Provides WhatsApp Business API tools for sending messages, managing templates, and sharing media with customers.

## Which Bots Use This

- **customer-support** -- Handles customer inquiries via WhatsApp Business
- **sales-pipeline** -- Sends follow-up messages and templates to prospects

## Setup

1. Set up a WhatsApp Business account and create an app in the [Meta Developer Portal](https://developers.facebook.com/)
2. Generate a permanent access token and note your phone number ID
3. Add `WHATSAPP_ACCESS_TOKEN` and `WHATSAPP_PHONE_NUMBER_ID` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single WhatsApp server instance across bots:

```yaml
mcpServers:
  - ref: "tools/whatsapp"
    reason: "Bots need WhatsApp access for customer communication and sales outreach"
    config:
      default_language: "en"
```
