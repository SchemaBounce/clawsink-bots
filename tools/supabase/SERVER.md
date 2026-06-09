---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: supabase
  displayName: "Supabase"
  version: "1.0.0"
  description: "Supabase, database, auth, storage, and edge functions"
  tags: ["supabase", "database", "auth", "storage", "postgres"]
  category: "databases"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
# Supabase REST API uses Bearer auth on the service role key + a
# matching apikey header. Per-tenant URL via {SUPABASE_URL}.
auth:
  type: http_bearer
  token_env: SUPABASE_SERVICE_ROLE_KEY

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
    sensitive: true

# Hit the PostgREST root — returns the OpenAPI schema with HTTP 200
# when the service key is valid. The apikey header is also required
# alongside the bearer (Supabase quirk — duplication is intentional).
validation:
  request:
    method: GET
    url: "{SUPABASE_URL}/rest/v1/"
    headers:
      apikey: "{SUPABASE_SERVICE_ROLE_KEY}"
      Accept: application/json
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Supabase rejected the service role key (401). Check the key under Project Settings > API and update SUPABASE_SERVICE_ROLE_KEY." }
    "403": { state: needs_setup, message: "Service role key permissions insufficient (403)." }
    "404": { state: needs_setup, message: "Supabase project URL returned 404 — verify SUPABASE_URL is the full https://...supabase.co project URL." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: "{SUPABASE_URL}/rest/v1/"
    headers:
      apikey: "{SUPABASE_SERVICE_ROLE_KEY}"
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

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
