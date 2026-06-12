---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: hubspot
  displayName: "HubSpot"
  version: "1.0.0"
  description: "HubSpot CRM, contacts, deals, companies, and marketing automation"
  tags: ["hubspot", "crm", "marketing", "sales", "contacts"]
  category: "crms-sales"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
auth:
  type: http_bearer
  token_env: PRIVATE_APP_ACCESS_TOKEN

# Transport switched to the official HubSpot stdio MCP package (verified 2026-05-25).
# The previous remote endpoint `https://mcp.hubspot.com/sse` returned HTTP 404 on the
# exact path (host root returns 401, but /sse, /mcp, /v1/sse, and POST /mcp all 404),
# so it was not a usable MCP transport. HubSpot's GA remote server (mcp.hubspot.com)
# also requires an interactive OAuth 2.0 flow, not the static private-app token in the
# `env:` block below, so the remote URL cannot be wired up with this auth model anyway.
#
# `@hubspot/mcp-server` is HubSpot's official npm package (scope @hubspot), pinned to
# 0.4.0 (latest dist-tag, verified HTTP 200 at registry.npmjs.org). It runs over stdio
# via npx and authenticates with a HubSpot private app access token via the
# PRIVATE_APP_ACCESS_TOKEN env var.
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@hubspot/mcp-server@0.4.0"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed OAuth
  # connection. Leaving these blank uses the workspace's Composio integration for
  # this service; provide values only to override the managed connection. Marked
  # required:true previously, which made the setup/reconnect modal demand
  # credentials the managed flow already covers.
  # NOTE: the official package reads PRIVATE_APP_ACCESS_TOKEN (renamed from the old
  # HUBSPOT_ACCESS_TOKEN). Update workspace secrets to use the new key.
  - name: PRIVATE_APP_ACCESS_TOKEN
    description: "HubSpot private app access token"
    required: false
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

Provides HubSpot CRM tools for bots that manage contacts, deals, companies, and marketing pipelines. Runs HubSpot's official `@hubspot/mcp-server` package over stdio (npx), authenticated with a HubSpot private app access token.

## Which Bots Use This

- **sales-pipeline** -- Deal tracking, pipeline stage management, and contact enrichment for sales workflows
- **marketing-manager** -- Contact list management, company records, and marketing pipeline analytics

## Setup

1. Create a HubSpot private app with the required scopes (CRM objects, contacts, deals)
2. Copy the access token from the private app settings
3. Add `PRIVATE_APP_ACCESS_TOKEN` to your workspace secrets
4. The server starts automatically when a bot that references it runs (it launches `npx -y @hubspot/mcp-server@0.4.0`)

## Team Usage

Add to your TEAM.md to share a single HubSpot server instance across sales and marketing bots:

```yaml
mcpServers:
  - ref: "tools/hubspot"
    reason: "Sales and marketing bots need HubSpot access for CRM data and pipeline management"
    config:
      default_pipeline: "default"
```
