---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: freshdesk
  displayName: "Freshdesk"
  version: "1.0.0"
  description: "Freshdesk helpdesk -- tickets, contacts, agents, and canned responses"
  tags: ["freshdesk", "helpdesk", "support", "tickets"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "freshdesk-mcp-server"]
env:
  - name: FRESHDESK_DOMAIN
    description: "Your Freshdesk domain e.g. mycompany.freshdesk.com"
    required: true
  - name: FRESHDESK_API_KEY
    description: "Freshdesk API key from Profile Settings"
    required: true
tools:
  - name: list_tickets
    description: "List tickets with optional filters"
    category: tickets
  - name: get_ticket
    description: "Get a ticket by ID"
    category: tickets
  - name: create_ticket
    description: "Create a new ticket"
    category: tickets
  - name: update_ticket
    description: "Update an existing ticket"
    category: tickets
  - name: reply_to_ticket
    description: "Reply to a ticket"
    category: tickets
  - name: list_contacts
    description: "List contacts"
    category: contacts
  - name: list_agents
    description: "List agents"
    category: agents
  - name: search_tickets
    description: "Search tickets with query"
    category: tickets
  - name: list_canned_responses
    description: "List canned responses"
    category: agents
---

# Freshdesk MCP Server

Provides Freshdesk helpdesk tools for bots that manage support tickets, track contacts, and coordinate agent responses.

**Note:** No published npm package exists yet. This server definition is a placeholder for when a community package becomes available, or can be connected via the Composio integration gateway.

## Which Bots Use This

- **customer-support** -- Triages tickets, sends replies, and manages support queues

## Setup

1. Get your API key from Freshdesk Profile Settings (top right > Profile Settings > API Key)
2. Add `FRESHDESK_DOMAIN` and `FRESHDESK_API_KEY` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Freshdesk server instance across bots:

```yaml
mcpServers:
  - ref: "tools/freshdesk"
    reason: "Support bots need Freshdesk access for ticket management"
    config:
      default_group: "Support"
```
