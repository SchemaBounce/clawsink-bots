---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: hubspot
  displayName: "HubSpot"
  version: "1.0.0"
  description: "HubSpot CRM — contacts, deals, companies, and marketing automation"
  tags: ["hubspot", "crm", "marketing", "sales", "contacts"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "sse"
  url: "https://mcp.hubspot.com/sse"
env:
  - name: HUBSPOT_ACCESS_TOKEN
    description: "HubSpot private app access token"
    required: true
tools:
  - name: list_contacts
    description: "List contacts"
    category: contacts
  - name: create_contact
    description: "Create a contact"
    category: contacts
  - name: get_contact
    description: "Get contact details"
    category: contacts
  - name: update_contact
    description: "Update a contact"
    category: contacts
  - name: list_deals
    description: "List deals"
    category: deals
  - name: create_deal
    description: "Create a deal"
    category: deals
  - name: list_companies
    description: "List companies"
    category: companies
  - name: create_company
    description: "Create a company"
    category: companies
  - name: search_objects
    description: "Search CRM objects"
    category: contacts
  - name: list_pipelines
    description: "List deal pipelines"
    category: pipelines
  - name: get_pipeline_stages
    description: "Get pipeline stage definitions"
    category: pipelines
---

# HubSpot MCP Server

Provides HubSpot CRM tools for bots that manage contacts, deals, companies, and marketing pipelines. OAuth-gated -- connect via Composio for managed auth.

## Which Bots Use This

- **sales-pipeline** -- Deal tracking, pipeline stage management, and contact enrichment for sales workflows
- **marketing-manager** -- Contact list management, company records, and marketing pipeline analytics

## Setup

1. Create a HubSpot private app with the required scopes (CRM objects, contacts, deals)
2. Copy the access token from the private app settings
3. Add `HUBSPOT_ACCESS_TOKEN` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single HubSpot server instance across sales and marketing bots:

```yaml
mcpServers:
  - ref: "tools/hubspot"
    reason: "Sales and marketing bots need HubSpot access for CRM data and pipeline management"
    config:
      default_pipeline: "default"
```
