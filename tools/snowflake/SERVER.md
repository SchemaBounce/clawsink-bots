---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: snowflake
  displayName: "Snowflake"
  version: "1.0.0"
  description: "Snowflake data warehouse — SQL queries, warehouses, databases, and stages"
  tags: ["snowflake", "data-warehouse", "analytics", "sql", "cloud"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "snowflake-mcp-server@1.0.4"]
env:
  - name: SNOWFLAKE_ACCOUNT
    description: "Snowflake account identifier"
    required: true
  - name: SNOWFLAKE_USER
    description: "Snowflake username"
    required: true
  - name: SNOWFLAKE_PASSWORD
    description: "Snowflake password"
    required: true
  - name: SNOWFLAKE_WAREHOUSE
    description: "Snowflake warehouse name"
    required: false
  - name: SNOWFLAKE_DATABASE
    description: "Snowflake database name"
    required: false
tools:
  - name: query
    description: "Execute SQL query"
    category: queries
  - name: list_databases
    description: "List available databases"
    category: databases
  - name: list_schemas
    description: "List schemas in a database"
    category: databases
  - name: list_tables
    description: "List tables in a schema"
    category: databases
  - name: describe_table
    description: "Get table schema and columns"
    category: databases
  - name: list_warehouses
    description: "List compute warehouses"
    category: warehouses
  - name: get_query_history
    description: "Get recent query history"
    category: queries
---

# Snowflake MCP Server

Provides Snowflake data warehouse tools for bots that need to run SQL queries, explore databases and schemas, and manage warehouses.

## Which Bots Use This

- **data-analyst** — Analytics queries, schema exploration, and warehouse management

## Setup

1. Prepare your Snowflake account identifier and credentials
2. Add `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, and `SNOWFLAKE_PASSWORD` to your workspace secrets
3. Optionally set `SNOWFLAKE_WAREHOUSE` and `SNOWFLAKE_DATABASE` for default context
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Snowflake server instance across bots:

```yaml
mcpServers:
  - ref: "tools/snowflake"
    reason: "Bots need Snowflake access for analytics queries and data exploration"
    config:
      default_warehouse: "COMPUTE_WH"
      default_database: "ANALYTICS"
```
