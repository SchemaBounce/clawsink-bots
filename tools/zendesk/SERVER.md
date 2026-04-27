---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: zendesk
  displayName: "Zendesk"
  version: "1.0.0"
  description: "Zendesk support -- tickets, users, organizations, and knowledge base"
  tags: ["zendesk", "support", "helpdesk", "tickets", "customer-service"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "ZENDESK"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like ZENDESK_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "zendesk-mcp@1.0.0"]
env:
  - name: ZENDESK_SUBDOMAIN
    description: "Your Zendesk subdomain e.g. mycompany"
    required: true
  - name: ZENDESK_EMAIL
    description: "Zendesk agent email address"
    required: true
  - name: ZENDESK_API_TOKEN
    description: "Zendesk API token"
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
  - name: search_tickets
    description: "Search tickets with query"
    category: tickets
  - name: list_users
    description: "List users"
    category: users
  - name: list_organizations
    description: "List organizations"
    category: organizations
  - name: search_articles
    description: "Search knowledge base articles"
    category: knowledge-base
  - name: list_groups
    description: "List agent groups"
    category: users
  - name: add_comment
    description: "Add a comment to a ticket"
    category: tickets
---

# Zendesk MCP Server

Provides Zendesk support tools for bots that manage tickets, monitor customer issues, and search knowledge base articles.

## Which Bots Use This

- **customer-support** -- Triages tickets, responds to customers, and escalates critical issues
- **escalation-coordinator** -- Monitors SLA breaches and routes tickets to the right teams

## Setup

1. Generate a Zendesk API token at Admin Center > Apps and integrations > Zendesk API > Zendesk API Settings
2. Add `ZENDESK_SUBDOMAIN`, `ZENDESK_EMAIL`, and `ZENDESK_API_TOKEN` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Zendesk server instance across bots:

```yaml
mcpServers:
  - ref: "tools/zendesk"
    reason: "Support bots need Zendesk access for ticket management and customer communication"
    config:
      default_group: "Support"
```
