---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: hubspot
  displayName: "HubSpot"
  version: "1.0.0"
  description: "HubSpot CRM, contacts, deals, companies, and marketing automation"
  tags: ["hubspot", "crm", "marketing", "sales", "contacts"]
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
auth:
  type: http_bearer
  token_env: HUBSPOT_ACCESS_TOKEN

transport:
  type: "sse"
  url: "https://mcp.hubspot.com/sse"
env:
  - name: HUBSPOT_ACCESS_TOKEN
    description: "HubSpot private app access token"
    required: true
    sensitive: true

# /crm/v3/objects/contacts?limit=1 is the lightest CRM endpoint —
# returns 200 even when zero contacts exist, 401 on bad token.
validation:
  request:
    method: GET
    url: https://api.hubapi.com/crm/v3/objects/contacts?limit=1
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "HubSpot rejected the access token (401). Verify the private app token at https://app.hubspot.com/settings (Account > Integrations > Private Apps)." }
    "403": { state: needs_setup, message: "Private app lacks required scopes (403). Grant at least crm.objects.contacts.read." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.hubapi.com/crm/v3/objects/contacts?limit=1
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

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
