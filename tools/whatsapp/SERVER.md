---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: whatsapp
  displayName: "WhatsApp"
  version: "2.0.0"
  description: "WhatsApp Business messaging via Composio. Send text, template, and media messages, list templates, and read the business profile through the WhatsApp Business API."
  tags: ["whatsapp", "messaging", "business", "chat", "composio"]
  category: "communication"
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "WHATSAPP"
  setupReason: "Authorized via Composio against your WhatsApp Business account. The agent calls execute_composio_tool with WHATSAPP_* action names (e.g. WHATSAPP_SEND_MESSAGE, WHATSAPP_SEND_TEMPLATE_MESSAGE, WHATSAPP_GET_MESSAGE_TEMPLATES)."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@composio/mcp@1.0.9"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio connection.
  # Leaving this blank uses the workspace's Composio integration for this service;
  # provide a value only to override the managed connection. Do not mark this
  # required:true, that makes the setup/reconnect modal demand a key the Composio
  # flow already covers.
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your WhatsApp Business account is then connected inside Composio."
    required: false
    sensitive: true

tools:
  - name: send_message
    description: "Send a text message to a WhatsApp Business contact"
    category: messages
  - name: send_template
    description: "Send a pre-approved template message, required for business-initiated conversations outside the 24-hour window"
    category: messages
  - name: send_media
    description: "Send an image, document, or other media message"
    category: messages
  - name: list_templates
    description: "List the account's approved message templates"
    category: templates
  - name: get_business_profile
    description: "Read the WhatsApp Business profile"
    category: profile
---

# WhatsApp MCP Server

Provides WhatsApp Business messaging via Composio's managed gateway. Covers text, template, and media messages, template listing, and the business profile.

## Auth Model: Composio (WHATSAPP)

This server is backed by the Composio WHATSAPP toolkit (17 tools). Authentication is managed by Composio against your WhatsApp Business account. Bots call `execute_composio_tool` with `WHATSAPP_*` action names. The friendly tools above map to real toolkit actions such as `WHATSAPP_SEND_MESSAGE`, `WHATSAPP_SEND_TEMPLATE_MESSAGE`, `WHATSAPP_SEND_MEDIA`, and `WHATSAPP_GET_MESSAGE_TEMPLATES`.

## Business Accounts Only

The WhatsApp toolkit uses the WhatsApp Business API. It supports WhatsApp Business accounts, not personal accounts. Delivery state arrives by webhook, so there is no polling action for message status.

## External Requirements

- A **Meta WhatsApp Business account** and a registered business phone number, connected in Composio.
- Business-initiated messages outside the 24-hour customer-service window must use an approved template.

## Which Bots Use This

- **customer-support** -- Handles customer inquiries over WhatsApp Business.
- **sales-pipeline** -- Sends follow-up and template messages to prospects.

WhatsApp is a customer-comms channel. It is not part of the social-media-manager publishing suite.

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key.
2. In Composio, connect your WhatsApp Business account under the WhatsApp toolkit.
3. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/whatsapp"
    reason: "Customer-comms bots need WhatsApp Business messaging for inquiries and follow-ups"
```
