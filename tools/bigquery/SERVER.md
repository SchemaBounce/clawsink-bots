---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: bigquery
  displayName: "BigQuery"
  version: "1.0.0"
  description: "Google BigQuery data warehouse. SQL queries, datasets, and tables"
  tags: ["bigquery", "google", "data-warehouse", "analytics", "sql"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "sse"
  url: "https://mcp.googleapis.com/bigquery/sse"
env:
  - name: GOOGLE_APPLICATION_CREDENTIALS
    description: "Path to GCP service account JSON key"
    required: true
  - name: GCP_PROJECT_ID
    description: "Google Cloud project ID"
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
  - name: create_dataset
    description: "Create a dataset"
    category: datasets
  - name: get_query_results
    description: "Get query job results"
    category: queries
---

# BigQuery MCP Server

Provides Google BigQuery tools for bots that need to run SQL queries against large datasets, explore schemas, and manage datasets.

## Which Bots Use This

- **data-analyst** — Analytics queries, dataset exploration, and schema inspection

## Setup

1. Create a GCP service account with BigQuery access
2. Download the JSON key file
3. Add `GOOGLE_APPLICATION_CREDENTIALS` (path to key file) and `GCP_PROJECT_ID` to your workspace secrets
4. The server connects via SSE when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single BigQuery server instance across bots:

```yaml
mcpServers:
  - ref: "tools/bigquery"
    reason: "Bots need BigQuery access for analytics queries and dataset exploration"
    config:
      default_dataset: "analytics"
```
