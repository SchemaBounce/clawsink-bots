---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mysql
  displayName: "MySQL"
  version: "1.0.0"
  description: "MySQL database — queries, schema inspection, and data exploration"
  tags: ["mysql", "database", "sql", "mariadb"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@benborla29/mcp-server-mysql@2.0.8"]
env:
  - name: MYSQL_HOST
    description: "MySQL server hostname"
    required: true
  - name: MYSQL_PORT
    description: "MySQL server port (default 3306)"
    required: false
  - name: MYSQL_USER
    description: "MySQL username"
    required: true
  - name: MYSQL_PASSWORD
    description: "MySQL password"
    required: true
  - name: MYSQL_DATABASE
    description: "MySQL database name"
    required: true
tools:
  - name: query
    description: "Execute SQL query"
    category: queries
  - name: list_tables
    description: "List all tables in the database"
    category: schema
  - name: describe_table
    description: "Get table schema and columns"
    category: schema
  - name: list_databases
    description: "List available databases"
    category: schema
---

# MySQL MCP Server

Provides MySQL database tools for bots that need to query data, inspect schemas, and explore database structures. Also compatible with MariaDB.

## Which Bots Use This

- **data-analyst** — Database exploration, ad-hoc queries, and schema inspection

## Setup

1. Ensure your MySQL server is accessible from the workspace network
2. Add `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`, and `MYSQL_DATABASE` to your workspace secrets
3. Optionally set `MYSQL_PORT` if not using the default 3306
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single MySQL server instance across bots:

```yaml
mcpServers:
  - ref: "tools/mysql"
    reason: "Bots need MySQL access for analytics queries and data exploration"
    config:
      read_only: true
```
