---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: sqlite
  displayName: "SQLite"
  version: "1.0.0"
  description: "SQLite database, queries, schema inspection, and in-memory databases"
  tags: ["sqlite", "database", "sql", "embedded"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "mcp-server-sqlite@0.0.2"]
env:
  - name: SQLITE_DB_PATH
    description: "Path to SQLite database file, defaults to in-memory"
    required: false
tools:
  - name: query
    description: "Execute a SQL query against the database"
    category: queries
  - name: list_tables
    description: "List all tables in the database"
    category: schema
  - name: describe_table
    description: "Get the schema of a specific table"
    category: schema
  - name: create_table
    description: "Create a new table"
    category: schema
---

# SQLite MCP Server

Provides SQLite database tools for bots that need lightweight, embedded SQL queries, schema inspection, and local data analysis.

## Which Bots Use This

- **data-analyst** -- Runs SQL queries against local datasets for ad-hoc analysis and reporting

## Setup

1. Optionally set `SQLITE_DB_PATH` to point to an existing SQLite database file
2. If no path is provided, the server uses an in-memory database
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single SQLite server instance across bots:

```yaml
mcpServers:
  - ref: "tools/sqlite"
    reason: "Bots need local SQL access for data analysis and temporary storage"
    config:
      db_path: "/data/analytics.db"
```
