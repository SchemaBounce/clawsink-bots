---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: gmail
  displayName: "Gmail"
  version: "1.0.0"
  description: "Gmail email management — send, read, search, and organize messages"
  tags: ["google", "gmail", "email", "messaging"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@gongrzhe/server-gmail-autoauth-mcp@1.1.11"]
env:
  - name: GOOGLE_CLIENT_ID
    description: "Google OAuth client ID"
    required: true
  - name: GOOGLE_CLIENT_SECRET
    description: "Google OAuth client secret"
    required: true
  - name: GOOGLE_REDIRECT_URI
    description: "Google OAuth redirect URI"
    required: true
tools:
  - name: send_email
    description: "Send an email"
    category: messages
  - name: read_email
    description: "Read a specific email"
    category: messages
  - name: search_emails
    description: "Search emails with query"
    category: messages
  - name: list_threads
    description: "List email threads"
    category: threads
  - name: reply_to_email
    description: "Reply to an email thread"
    category: threads
  - name: create_draft
    description: "Create a draft email"
    category: drafts
  - name: list_labels
    description: "List Gmail labels"
    category: labels
  - name: modify_labels
    description: "Add/remove labels from messages"
    category: labels
---

# Gmail MCP Server

Provides Gmail API tools for bots that send, read, search, and organize email messages.

## Which Bots Use This

- **sales-pipeline** -- Sends follow-up emails and tracks prospect communication
- **customer-support** -- Reads incoming tickets and sends responses
- **executive-assistant** -- Manages inbox, drafts replies, and organizes messages with labels

## Setup

1. Create a Google Cloud project and enable the Gmail API
2. Create OAuth 2.0 credentials (client ID and secret)
3. Add `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `GOOGLE_REDIRECT_URI` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Gmail server instance across bots:

```yaml
mcpServers:
  - ref: "tools/gmail"
    reason: "Bots need email access for customer communication and follow-ups"
    config:
      default_label: "INBOX"
```
