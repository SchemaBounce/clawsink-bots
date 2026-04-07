---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: postgres
  displayName: "PostgreSQL"
  version: "1.0.0"
  description: "PostgreSQL database — queries, schema inspection, and data exploration"
  tags: ["postgres", "postgresql", "database", "sql"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-postgres@0.6.2"]
env:
  - name: POSTGRES_CONNECTION_STRING
    description: "PostgreSQL connection string e.g. postgresql://user:pass@host:5432/db"
    required: true
tools:
  - name: query
    description: "Execute read-only SQL query"
    category: queries
  - name: list_tables
    description: "List all tables in the database"
    category: schema
  - name: describe_table
    description: "Get table schema and columns"
    category: schema
  - name: list_schemas
    description: "List database schemas"
    category: schema
---

# PostgreSQL MCP Server

Provides PostgreSQL database tools for bots that need to query data, inspect schemas, and explore database structures.

## Which Bots Use This

- **data-analyst** — Database exploration, ad-hoc queries, and schema inspection

## Setup

1. Prepare a PostgreSQL connection string with read-only credentials
2. Add `POSTGRES_CONNECTION_STRING` to your workspace secrets
3. The server starts automatically when a bot that references it runs

**Note:** Read-only by default for safety. Use a dedicated read-only database user to prevent accidental writes.

## Team Usage

Add to your TEAM.md to share a single PostgreSQL server instance across bots:

```yaml
mcpServers:
  - ref: "tools/postgres"
    reason: "Bots need database access for analytics queries and schema inspection"
    config:
      default_schema: "public"
```
