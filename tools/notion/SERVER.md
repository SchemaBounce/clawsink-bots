---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: notion
  displayName: "Notion"
  version: "1.0.0"
  description: "Notion workspace tools for pages, databases, and knowledge management"
  tags: ["notion", "productivity", "knowledge-base", "documentation", "wiki"]
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
# The engine in core-api uses these blocks to verify credentials and
# probe upstream reachability without per-server Go code.
#
# Previous metadata noted "method: composio" — that was aspirational
# documentation; the actual runtime auth is direct NOTION_API_KEY as
# a Bearer token, matching the curated mcp_validation.go path.
auth:
  type: http_bearer
  token_env: NOTION_API_KEY

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "notion-mcp-server@1.0.1"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed OAuth
  # connection. Leaving these blank uses the workspace's Composio integration for
  # this service; provide values only to override the managed connection. Marked
  # required:true previously, which made the setup/reconnect modal demand
  # credentials the managed flow already covers.
  - name: NOTION_API_KEY
    description: "Notion Internal Integration Token"
    required: false
    sensitive: true

validation:
  request:
    method: GET
    url: https://api.notion.com/v1/users/me
    headers:
      # Notion requires an explicit API version header on every call.
      # See https://developers.notion.com/reference/versioning.
      Notion-Version: "2022-06-28"
      Accept: application/json
  expect:
    status: 200
    extract:
      authenticated_as_field: name
  on_status:
    "401": { state: needs_setup, message: "Notion rejected the integration token (401). Generate a fresh internal integration token at https://www.notion.so/profile/integrations." }
    "403": { state: needs_setup, message: "Notion integration lacks required capabilities (403). Grant the integration access to the workspace pages or databases it needs." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.notion.com/v1/users/me
    headers:
      Notion-Version: "2022-06-28"
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

tools:
  - name: search
    description: "Search across all pages and databases"
    category: search
  - name: get_page
    description: "Get a page and its content"
    category: pages
  - name: create_page
    description: "Create a new page"
    category: pages
  - name: update_page
    description: "Update page properties"
    category: pages
  - name: get_database
    description: "Get database schema and properties"
    category: databases
  - name: query_database
    description: "Query a database with filters and sorts"
    category: databases
  - name: create_database_item
    description: "Add a new item to a database"
    category: databases
  - name: get_block_children
    description: "Get child blocks of a page or block"
    category: blocks
  - name: append_block_children
    description: "Append content blocks to a page"
    category: blocks
  - name: list_users
    description: "List workspace users"
    category: users
  - name: get_user
    description: "Get user details"
    category: users
---

# Notion MCP Server

Provides Notion workspace tools for bots that manage knowledge bases, documentation, and structured data in Notion databases.

## Which Bots Use This

- **knowledge-base-curator** -- Manages knowledge base articles and documentation in Notion
- **meeting-summarizer** -- Publishes meeting summaries and action items to Notion pages
- **documentation-writer** -- Updates documentation pages in Notion workspace

## Setup

1. Create an Internal Integration at [notion.so/my-integrations](https://www.notion.so/my-integrations)
2. Share the pages/databases you want the bots to access with the integration
3. Add the integration token to your workspace secrets as `NOTION_API_KEY`
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Notion server instance across all knowledge management bots:

```yaml
mcpServers:
  - ref: "tools/notion"
    reason: "Knowledge management bots need Notion access for documentation and knowledge base operations"
```
