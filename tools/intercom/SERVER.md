---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: intercom
  displayName: "Intercom"
  version: "1.0.0"
  description: "Intercom customer messaging -- conversations, contacts, and articles"
  tags: ["intercom", "messaging", "support", "customer-engagement"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "INTERCOM"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like INTERCOM_*."
transport:
  type: "sse"
  url: "https://mcp.intercom.com/sse"
env:
  - name: INTERCOM_ACCESS_TOKEN
    description: "Intercom access token from Developer Hub"
    required: true
tools:
  - name: list_conversations
    description: "List conversations"
    category: conversations
  - name: get_conversation
    description: "Get a conversation by ID"
    category: conversations
  - name: reply_to_conversation
    description: "Reply to a conversation"
    category: conversations
  - name: list_contacts
    description: "List contacts"
    category: contacts
  - name: create_contact
    description: "Create a new contact"
    category: contacts
  - name: search_contacts
    description: "Search contacts with filters"
    category: contacts
  - name: list_articles
    description: "List help center articles"
    category: articles
  - name: create_article
    description: "Create a help center article"
    category: articles
  - name: list_tags
    description: "List tags"
    category: tags
---

# Intercom MCP Server

Provides Intercom customer messaging tools for bots that manage conversations, track contacts, and maintain help center content.

> **Note:** Intercom's MCP server is OAuth-gated and available for US-hosted workspaces only.

## Which Bots Use This

- **customer-support** -- Monitors and responds to customer conversations
- **sales-pipeline** -- Tracks leads and engages prospects through messaging

## Setup

1. Create an Intercom app in the Developer Hub and generate an access token
2. Add `INTERCOM_ACCESS_TOKEN` to your workspace secrets
3. The server connects via SSE to Intercom's hosted MCP endpoint

## Team Usage

Add to your TEAM.md to share a single Intercom server instance across bots:

```yaml
mcpServers:
  - ref: "tools/intercom"
    reason: "Bots need Intercom access for customer messaging and support"
    config:
      default_inbox: "main"
```
