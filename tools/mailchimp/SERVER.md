---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mailchimp
  displayName: "Mailchimp"
  version: "2.0.0"
  description: "Mailchimp email marketing via Composio. Manage campaigns, audiences, members, templates, and campaign reports."
  tags: ["mailchimp", "email", "marketing", "campaigns", "newsletters", "composio"]
  category: "crms-sales"
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "MAILCHIMP"
  setupReason: "Authorized via Composio against your Mailchimp account. The agent calls execute_composio_tool with MAILCHIMP_* action names (e.g. MAILCHIMP_LIST_CAMPAIGNS, MAILCHIMP_SEND_CAMPAIGN, MAILCHIMP_ADD_OR_UPDATE_LIST_MEMBER)."
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
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your Mailchimp account is then connected inside Composio."
    required: false
    sensitive: true

tools:
  - name: list_campaigns
    description: "List email campaigns"
    category: campaigns
  - name: get_campaign
    description: "Get a campaign's details"
    category: campaigns
  - name: create_campaign
    description: "Create an email campaign"
    category: campaigns
  - name: send_campaign
    description: "Send a campaign"
    category: campaigns
  - name: list_audiences
    description: "List audiences (lists)"
    category: audiences
  - name: list_members
    description: "List members of an audience"
    category: members
  - name: add_member
    description: "Add or update a member in an audience"
    category: members
  - name: get_campaign_report
    description: "Get a campaign's performance report"
    category: reports
  - name: list_templates
    description: "List email templates"
    category: templates
---

# Mailchimp MCP Server

Provides Mailchimp email marketing via Composio's managed gateway. Covers campaign management, audiences, members, templates, and campaign reports.

## Auth Model: Composio (MAILCHIMP)

This server is backed by the Composio MAILCHIMP toolkit (272 tools). Authentication is managed by Composio. Bots call `execute_composio_tool` with `MAILCHIMP_*` action names. The friendly tools above map to real toolkit actions such as `MAILCHIMP_LIST_CAMPAIGNS`, `MAILCHIMP_GET_CAMPAIGN`, `MAILCHIMP_SEND_CAMPAIGN`, `MAILCHIMP_GET_LISTS_INFO`, `MAILCHIMP_LIST_MEMBERS`, and `MAILCHIMP_ADD_OR_UPDATE_LIST_MEMBER`.

## External Requirements

- A **Mailchimp account**, connected in Composio under the Mailchimp toolkit.

## Which Bots Use This

- **marketing-growth** -- Campaign management, audience segmentation, and performance tracking.
- **content-scheduler** -- Newsletter scheduling and email template management.

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key.
2. In Composio, connect your Mailchimp account under the Mailchimp toolkit.
3. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/mailchimp"
    reason: "Marketing bots need Mailchimp access for email campaigns, audience management, and analytics"
```
