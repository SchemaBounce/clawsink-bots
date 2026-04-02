---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: composio
  displayName: "Composio"
  version: "1.0.0"
  description: "Unified SaaS integration gateway — 500+ app connections with managed OAuth"
  tags: ["saas", "integration", "oauth", "automation", "presence", "gmail", "calendar", "crm"]
  author: "composio"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@composio/mcp@latest"]
env:
  - name: COMPOSIO_API_KEY
    description: "API key from composio.dev"
    required: true
tools:
  - name: search_composio_tools
    description: "Discover available tools across 500+ connected SaaS applications"
    category: discovery
  - name: execute_composio_tool
    description: "Execute a tool through the Composio API (e.g., GMAIL_SEND_EMAIL)"
    category: execution
  - name: multi_execute_composio_tools
    description: "Execute multiple independent tools in parallel"
    category: execution
  - name: list_toolkits
    description: "List all available SaaS toolkits (Gmail, Slack, HubSpot, etc.)"
    category: discovery
  - name: initiate_connection
    description: "Establish a new OAuth connection to a SaaS application"
    category: connections
  - name: check_multiple_active_connections
    description: "Verify connection statuses across multiple toolkits"
    category: connections
  - name: get_required_parameters_for_connection
    description: "Get authentication requirements for a specific toolkit"
    category: connections
  - name: create_plan
    description: "Generate step-by-step execution plans for complex multi-tool workflows"
    category: planning
  - name: execute_agent
    description: "Handle complex multi-step workflows with reasoning"
    category: execution
  - name: get_tool_dependency_graph
    description: "Map related tools and dependencies for a toolkit"
    category: discovery
  - name: ask_oracle
    description: "Get guidance on how to plan and execute tasks with available tools"
    category: planning
---

# Composio MCP Server

Meta-gateway providing unified access to 500+ SaaS applications with managed OAuth. Instead of integrating each SaaS app individually, agents use Composio as a single entry point to Gmail, Google Calendar, HubSpot, Salesforce, Notion, Jira, and hundreds more.

## Which Bots Use This

- **accountant** — Connects to QuickBooks, Xero, and accounting SaaS
- **marketing-growth** — Manages HubSpot, Mailchimp, and ad platforms
- **sales-pipeline** — Accesses Salesforce, HubSpot CRM
- **hr-onboarding** — Integrates with BambooHR, Workday
- **content-scheduler** — Publishes to WordPress, Medium, social platforms
- **executive-assistant** — Manages Google Calendar, Outlook, and productivity tools
- **revops** — Connects CRM, billing, and analytics platforms

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key
2. Add `COMPOSIO_API_KEY` to your workspace secrets
3. Use `initiate_connection` to set up OAuth for specific SaaS apps

## How It Works

Composio is a **meta-MCP server** — it dynamically discovers and proxies tools from connected SaaS apps:

1. Agent calls `search_composio_tools` to find available tools (e.g., "Gmail send email")
2. Composio returns `GMAIL_SEND_EMAIL` tool definition with schema
3. Agent calls `execute_composio_tool` with tool name and parameters
4. Composio handles OAuth token refresh, rate limiting, and error handling

Tool names follow the pattern `{TOOLKIT}_{ACTION}` (e.g., `GMAIL_SEND_EMAIL`, `HUBSPOT_CREATE_CONTACT`).

## Team Usage

```yaml
mcpServers:
  - ref: "tools/composio"
    reason: "Team bots need SaaS integration for CRM, email, and productivity tools"
    config:
      toolkits: ["gmail", "google_calendar", "hubspot"]
```
