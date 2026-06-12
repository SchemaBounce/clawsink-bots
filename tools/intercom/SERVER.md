---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: intercom
  displayName: "Intercom"
  version: "1.0.0"
  description: "Intercom customer messaging -- conversations, contacts, and articles"
  tags: ["intercom", "messaging", "support", "customer-engagement"]
  category: "crms-sales"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
auth:
  type: http_bearer
  token_env: INTERCOM_ACCESS_TOKEN

transport:
  type: "sse"
  url: "https://mcp.intercom.com/sse"
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed OAuth
  # connection. Leaving these blank uses the workspace's Composio integration for
  # this service; provide values only to override the managed connection. Marked
  # required:true previously, which made the setup/reconnect modal demand
  # credentials the managed flow already covers.
  - name: INTERCOM_ACCESS_TOKEN
    description: "Intercom access token from Developer Hub"
    required: false
    sensitive: true

# /me returns the authenticated app's own admin user. Idempotent.
validation:
  request:
    method: GET
    url: https://api.intercom.io/me
    headers:
      Accept: application/json
      Intercom-Version: "2.11"
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Intercom rejected the access token (401). Regenerate at https://app.intercom.com/a/apps/_/developer-hub and update INTERCOM_ACCESS_TOKEN." }
    "403": { state: needs_setup, message: "Token lacks required permissions (403)." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.intercom.io/me
    headers:
      Intercom-Version: "2.11"
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

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
