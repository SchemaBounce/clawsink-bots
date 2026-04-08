---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mailchimp
  displayName: "Mailchimp"
  version: "1.0.0"
  description: "Mailchimp email marketing — campaigns, audiences, templates, and analytics"
  tags: ["mailchimp", "email", "marketing", "campaigns", "newsletters"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@agentx-ai/mailchimp-mcp-server@1.1.1"]
env:
  - name: MAILCHIMP_API_KEY
    description: "Mailchimp API key from Account > Extras > API keys"
    required: true
  - name: MAILCHIMP_SERVER_PREFIX
    description: "Mailchimp server prefix e.g. us14"
    required: true
tools:
  - name: list_campaigns
    description: "List email campaigns"
    category: campaigns
  - name: get_campaign
    description: "Get campaign details"
    category: campaigns
  - name: create_campaign
    description: "Create an email campaign"
    category: campaigns
  - name: send_campaign
    description: "Send a campaign"
    category: campaigns
  - name: list_audiences
    description: "List audiences"
    category: audiences
  - name: list_members
    description: "List audience members"
    category: members
  - name: add_member
    description: "Add a member to an audience"
    category: members
  - name: search_members
    description: "Search audience members"
    category: members
  - name: list_templates
    description: "List email templates"
    category: templates
  - name: get_campaign_report
    description: "Get campaign performance report"
    category: reports
---

# Mailchimp MCP Server

Provides Mailchimp email marketing tools for bots that need to manage campaigns, audiences, templates, and track campaign analytics.

## Which Bots Use This

- **marketing-manager** — Campaign management, audience segmentation, and performance tracking
- **content-strategist** — Email template management and newsletter scheduling

## Setup

1. Get your API key from Mailchimp Account > Extras > API keys
2. Note your server prefix (the `usXX` part of your Mailchimp URL)
3. Add `MAILCHIMP_API_KEY` and `MAILCHIMP_SERVER_PREFIX` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Mailchimp server instance across bots:

```yaml
mcpServers:
  - ref: "tools/mailchimp"
    reason: "Bots need Mailchimp access for email campaigns, audience management, and analytics"
    config:
      default_audience: "main"
```
