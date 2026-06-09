---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: bigquery
  displayName: "BigQuery"
  version: "1.0.0"
  description: "Google BigQuery data warehouse. SQL queries, datasets, and tables"
  tags: ["bigquery", "google", "data-warehouse", "analytics", "sql"]
  category: "databases"
  author: "schemabounce"
  license: "MIT"
transport:
  # The previous "https://mcp.googleapis.com/bigquery/sse" path was dead: host resolves
  # but that exact path returns HTTP 404, so it was not a live MCP server.
  # Replaced 2026-05-25 with the community @ergut/mcp-bigquery-server (stdio via npx,
  # gateway-compatible). Verified live: registry.npmjs.org returns HTTP 200 for v1.0.4.
  # Repo: https://github.com/ergut/mcp-bigquery-server  npm: @ergut/mcp-bigquery-server
  #
  # Auth model: this package uses Application Default Credentials. Point
  # GOOGLE_APPLICATION_CREDENTIALS at a service-account JSON key (the existing env block
  # already matches). The project must be passed as a CLI flag, so GCP_PROJECT_ID is
  # interpolated into args below. Note: this server is read-only (queries + schema
  # inspection); it does NOT support create_dataset, so that tool is removed below.
  #
  # Google ships an official REMOTE BigQuery MCP server at https://bigquery.googleapis.com/mcp
  # (verified live 2026-05-25: HTTP 405 on GET, 411 on POST). It is the more official option,
  # but it requires OAuth 2.0 + IAM (roles/mcp.toolUser) and explicitly rejects API keys and
  # service-account-key env auth, so it does NOT fit this catalog's GOOGLE_APPLICATION_CREDENTIALS
  # env block or the gateway's stdio model. Revisit if/when the gateway supports remote OAuth MCP.
  type: "stdio"
  command: "npx"
  args: ["-y", "@ergut/mcp-bigquery-server@1.0.4", "--project-id", "${GCP_PROJECT_ID}"]
env:
  - name: GOOGLE_APPLICATION_CREDENTIALS
    description: "Path to GCP service account JSON key (used as Application Default Credentials)"
    required: true
  - name: GCP_PROJECT_ID
    description: "Google Cloud project ID (passed to the server via --project-id)"
    required: true
tools:
  - name: query
    description: "Execute SQL query"
    category: queries
  - name: list_datasets
    description: "List datasets"
    category: datasets
  - name: list_tables
    description: "List tables in dataset"
    category: tables
  - name: get_table_schema
    description: "Get table schema"
    category: tables
  - name: get_query_results
    description: "Get query job results"
    category: queries
---

# BigQuery MCP Server

Provides Google BigQuery tools for bots that need to run SQL queries against large datasets, explore schemas, and manage datasets.

## Which Bots Use This

- **data-analyst** — Analytics queries, dataset exploration, and schema inspection

## Setup

1. Create a GCP service account with BigQuery access (`roles/bigquery.dataViewer` + `roles/bigquery.jobUser`)
2. Download the JSON key file
3. Add `GOOGLE_APPLICATION_CREDENTIALS` (path to key file) and `GCP_PROJECT_ID` to your workspace secrets
4. The server runs locally over stdio via `npx @ergut/mcp-bigquery-server` when a bot that references it runs

This server provides read-only BigQuery access (SQL queries plus schema and dataset inspection). It does not create or modify datasets.

## Team Usage

Add to your TEAM.md to share a single BigQuery server instance across bots:

```yaml
mcpServers:
  - ref: "tools/bigquery"
    reason: "Bots need BigQuery access for analytics queries and dataset exploration"
    config:
      default_dataset: "analytics"
```
