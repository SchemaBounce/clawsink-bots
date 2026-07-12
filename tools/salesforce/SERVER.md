---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: salesforce
  displayName: "Salesforce"
  version: "1.0.0"
  description: "Salesforce CRM, accounts, contacts, opportunities, and cases"
  tags: ["salesforce", "crm", "sales", "leads", "opportunities"]
  category: "crms-sales"
  author: "schemabounce"
  license: "MIT"
# AUTH GAP (verified 2026-05-25): The official @salesforce/mcp server does NOT use
# Composio managed-OAuth or env-var access tokens. It authorizes against orgs you have
# logged in locally via the Salesforce CLI (`sf org login web`). The composio block below
# is retained as the SchemaBounce-managed-auth aspiration, but it is NOT how this server
# authenticates today. Until a Composio bridge or a Salesforce-hosted remote endpoint with
# a public URL exists, this server requires local CLI org auth and is not end-to-end
# managed-OAuth in the SchemaBounce workspace. Do not claim managed OAuth works here.
auth:
  method: "composio"
  composioToolkit: "SALESFORCE"
  setupReason: "Aspirational managed-OAuth via Composio. See AUTH GAP note above: the underlying official server actually uses local Salesforce CLI org authorization, not Composio, today."
# Previous transport was url: "https://mcp.salesforce.com/sse" -- that host does NOT resolve
# (DNS failure, curl rc=6), it was a fabricated/dead endpoint and has been removed.
# Replaced with the official Salesforce DX MCP Server: npm @salesforce/mcp (stdio transport),
# verified published version 0.30.12 (registry.npmjs.org returns 200). Source:
# https://github.com/salesforcecli/mcp -- maintained by Salesforce (Apache-2.0).
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@salesforce/mcp@0.30.12", "--orgs", "DEFAULT_TARGET_ORG", "--toolsets", "all"]
env:
  - name: SF_MCP_AUTH
    description: "Local Salesforce CLI org authorization is required before launch: run `sf org login web` to authorize the target org. The server reads CLI-stored org credentials; it does not accept an access token via env var. This is a setup prerequisite, not a secret value to inject."
    required: false
    sensitive: true
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

Provides Salesforce CRM tools for bots that manage accounts, contacts, opportunities, and support cases. Backed by the official Salesforce DX MCP Server (`@salesforce/mcp`, stdio transport).

> Auth gap (verified 2026-05-25): the official server authenticates against orgs you have logged into locally with the Salesforce CLI (`sf org login web`). It does not use Composio managed-OAuth or an env-var access token, so this entry is not end-to-end managed-OAuth in a SchemaBounce workspace yet. The prior `https://mcp.salesforce.com/sse` endpoint was fabricated (DNS does not resolve) and has been removed.

## Which Bots Use This

- **sales-pipeline** -- Opportunity tracking, account management, and SOQL queries for pipeline analytics
- **customer-support** -- Case creation, contact lookup, and account health monitoring

## Setup

1. Install the Salesforce CLI and authorize your org: `sf org login web`
2. Confirm the org is the default target (`sf config set target-org <alias>`) so `--orgs DEFAULT_TARGET_ORG` resolves
3. The runtime launches the server via `npx -y @salesforce/mcp@0.30.12 --orgs DEFAULT_TARGET_ORG --toolsets all`
4. The server reads CLI-stored org credentials at launch (no access token env var)

Note: this requires the Salesforce CLI and a local org login on the host running the server. It is not yet wired to Composio managed-OAuth or to a Salesforce-hosted remote endpoint with a public URL.

## Team Usage

Add to your TEAM.md to share a single Salesforce server instance across sales and support bots:

```yaml
mcpServers:
  - ref: "tools/salesforce"
    reason: "Sales and support bots need Salesforce access for CRM data and case management"
    config:
      default_api_version: "v59.0"
```
