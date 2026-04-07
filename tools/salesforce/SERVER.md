---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: salesforce
  displayName: "Salesforce"
  version: "1.0.0"
  description: "Salesforce CRM — accounts, contacts, opportunities, and cases"
  tags: ["salesforce", "crm", "sales", "leads", "opportunities"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "sse"
  url: "https://mcp.salesforce.com/sse"
env:
  - name: SALESFORCE_INSTANCE_URL
    description: "Salesforce instance URL"
    required: true
  - name: SALESFORCE_ACCESS_TOKEN
    description: "Salesforce access token"
    required: true
tools:
  - name: query_soql
    description: "Run a SOQL query"
    category: search
  - name: list_accounts
    description: "List accounts"
    category: accounts
  - name: get_account
    description: "Get account details"
    category: accounts
  - name: create_account
    description: "Create an account"
    category: accounts
  - name: list_contacts
    description: "List contacts"
    category: contacts
  - name: list_opportunities
    description: "List opportunities"
    category: opportunities
  - name: create_opportunity
    description: "Create an opportunity"
    category: opportunities
  - name: update_opportunity
    description: "Update an opportunity"
    category: opportunities
  - name: list_cases
    description: "List support cases"
    category: cases
  - name: create_case
    description: "Create a support case"
    category: cases
  - name: search
    description: "Run a SOSL search"
    category: search
---

# Salesforce MCP Server

Provides Salesforce CRM tools for bots that manage accounts, contacts, opportunities, and support cases. OAuth-gated -- connect via Composio for managed auth.

## Which Bots Use This

- **sales-pipeline** -- Opportunity tracking, account management, and SOQL queries for pipeline analytics
- **customer-support** -- Case creation, contact lookup, and account health monitoring

## Setup

1. Create a Salesforce Connected App with appropriate OAuth scopes
2. Obtain an access token via OAuth 2.0 flow (use Composio for managed auth)
3. Add `SALESFORCE_INSTANCE_URL` and `SALESFORCE_ACCESS_TOKEN` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Salesforce server instance across sales and support bots:

```yaml
mcpServers:
  - ref: "tools/salesforce"
    reason: "Sales and support bots need Salesforce access for CRM data and case management"
    config:
      default_api_version: "v59.0"
```
