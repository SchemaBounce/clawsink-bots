---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: airtable
  displayName: "Airtable"
  version: "1.0.0"
  description: "Airtable databases -- records, tables, views, and automations"
  tags: ["airtable", "database", "spreadsheet", "no-code"]
  category: "databases"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
auth:
  type: http_bearer
  token_env: AIRTABLE_API_KEY

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "airtable-mcp-server@1.13.0"]
env:
  - name: AIRTABLE_API_KEY
    description: "Airtable personal access token from airtable.com/create/tokens"
    required: true
    sensitive: true

# /v0/meta/bases lists bases the token can access. Idempotent, no
# side effects, the simplest token-scope check.
validation:
  request:
    method: GET
    url: https://api.airtable.com/v0/meta/bases
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Airtable rejected the personal access token (401). Generate a new one at https://airtable.com/create/tokens and update AIRTABLE_API_KEY." }
    "403": { state: needs_setup, message: "Token lacks required scopes (403). Add at minimum 'schema.bases:read' on the token settings page." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.airtable.com/v0/meta/bases
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

tools:
  - name: list_bases
    description: "List all accessible bases"
    category: bases
  - name: list_tables
    description: "List tables in a base"
    category: tables
  - name: list_records
    description: "List records in a table"
    category: records
  - name: get_record
    description: "Get a single record by ID"
    category: records
  - name: create_record
    description: "Create a new record"
    category: records
  - name: update_record
    description: "Update an existing record"
    category: records
  - name: delete_record
    description: "Delete a record"
    category: records
  - name: search_records
    description: "Search records with filters"
    category: records
---

# Airtable MCP Server

Provides Airtable database tools for bots that manage structured data, track inventory, and coordinate projects.

## Which Bots Use This

- **data-analyst** -- Queries and analyzes data across Airtable bases
- **inventory-tracker** -- Manages stock levels and product catalogs
- **project-manager** -- Tracks tasks, milestones, and team assignments

## Setup

1. Create a personal access token at https://airtable.com/create/tokens with scopes for the bases you need
2. Add `AIRTABLE_API_KEY` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Airtable server instance across bots:

```yaml
mcpServers:
  - ref: "tools/airtable"
    reason: "Bots need Airtable access for structured data management"
    config:
      default_base: "appXXXXXXXXXXXXXX"
```
