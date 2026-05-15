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
auth:
  method: "composio"
  composioToolkit: "NOTION"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like NOTION_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "notion-mcp-server@1.0.1"]
env:
  - name: NOTION_API_KEY
    description: "Notion Internal Integration Token"
    required: true
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
