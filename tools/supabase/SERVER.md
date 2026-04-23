---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: supabase
  displayName: "Supabase"
  version: "1.0.0"
  description: "Supabase, database, auth, storage, and edge functions"
  tags: ["supabase", "database", "auth", "storage", "postgres"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "supabase-mcp@1.5.0"]
env:
  - name: SUPABASE_URL
    description: "Supabase project URL"
    required: true
  - name: SUPABASE_SERVICE_ROLE_KEY
    description: "Service role key from the Supabase dashboard"
    required: true
tools:
  - name: query
    description: "Execute a SQL query against the database"
    category: database
  - name: list_tables
    description: "List all tables in the database"
    category: database
  - name: get_schema
    description: "Get the schema of a specific table"
    category: database
  - name: list_users
    description: "List authenticated users"
    category: auth
  - name: list_buckets
    description: "List storage buckets"
    category: storage
  - name: list_functions
    description: "List edge functions"
    category: functions
  - name: manage_policies
    description: "Manage row-level security policies"
    category: database
---

# Supabase MCP Server

Provides Supabase tools for bots that manage databases, auth users, storage buckets, and edge functions on the Supabase platform.

## Which Bots Use This

- **data-analyst** -- Queries databases and inspects schemas for analysis and reporting
- **software-architect** -- Manages database schemas, RLS policies, and edge function deployments

## Setup

1. Get your Supabase project URL and service role key from the [Supabase dashboard](https://supabase.com/dashboard)
2. Add `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Supabase server instance across bots:

```yaml
mcpServers:
  - ref: "tools/supabase"
    reason: "Bots need Supabase access for database queries, auth management, and storage"
    config:
      default_schema: "public"
```
