---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: agentmail
  displayName: "AgentMail"
  version: "1.0.0"
  description: "Email identity for AI agents. Send, receive, and manage email"
  tags: ["email", "communication", "identity", "presence", "inbox"]
  author: "agentmail"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "agentmail-mcp@0.2.2"]
env:
  - name: AGENTMAIL_API_KEY
    description: "API key from agentmail.dev"
    required: true
tools:
  - name: list_inboxes
    description: "List all inboxes for the agent"
    category: inbox
  - name: get_inbox
    description: "Get details for a specific inbox"
    category: inbox
  - name: create_inbox
    description: "Create a new inbox with a username and domain"
    category: inbox
  - name: delete_inbox
    description: "Delete an inbox"
    category: inbox
  - name: list_threads
    description: "List email threads in an inbox"
    category: threads
  - name: get_thread
    description: "Get a specific thread with all its messages"
    category: threads
  - name: get_attachment
    description: "Download an attachment from a message"
    category: messages
  - name: send_message
    description: "Send a new email from an inbox"
    category: messages
  - name: reply_to_message
    description: "Reply to an existing email message"
    category: messages
  - name: forward_message
    description: "Forward a message to another recipient"
    category: messages
  - name: update_message
    description: "Update message properties such as read status"
    category: messages
---

# AgentMail MCP Server

Provides full email identity for AI agents. Agents get their own email address and can send, receive, search, and manage email conversations — enabling persistent external communication.

## Which Bots Use This

- **executive-assistant** — Sends daily briefings and reports via email
- **customer-support** — Emails customers with ticket updates and resolutions
- **accountant** — Sends financial reports and invoice summaries
- **sales-pipeline** — Follows up with prospects via email
- **compliance-auditor** — Sends audit findings to stakeholders
- **hr-onboarding** — Emails new hire onboarding materials

## Setup

1. Sign up at [agentmail.dev](https://agentmail.dev) and get your API key
2. Add `AGENTMAIL_API_KEY` to your workspace secrets
3. Each agent that needs email will have an inbox auto-provisioned on activation

## Presence Integration

When a bot declares `presence.email.provider: agentmail`, the platform automatically:
1. Creates an inbox for the agent (e.g., `accountant@ws-acme.agents.schemabounce.com`)
2. Stores the inbox ID in `agent_external_identities`
3. Grants the agent access to AgentMail MCP tools

## Team Usage

```yaml
mcpServers:
  - ref: "tools/agentmail"
    reason: "Team bots need email for external communication"
    config: {}
```
