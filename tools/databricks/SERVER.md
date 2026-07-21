---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: databricks
  displayName: "Databricks SQL"
  version: "1.0.0"
  description: "Databricks managed MCP server for SQL. Run governed SQL against your Databricks workspace warehouse from agents."
  tags: ["databricks", "sql", "data-warehouse", "analytics"]
  category: "databases"
  author: "databricks"
  license: "Proprietary"

# Per-tenant URL template (first catalog entry using the mechanism; design in
# docs/research/2026-07-21-per-tenant-mcp-pattern.md). Every Databricks
# customer has a unique workspace host, so the transport URL carries a
# {DATABRICKS_WORKSPACE_URL} placeholder declared as a plain env entry below.
# The connect form collects it, the connection stores it as a non-secret
# Variable, and core-api substitutes it where the URL becomes launchable
# (config publish + validation transport). Auth is a workspace personal
# access token sent as a standard Bearer header via the injection template.
auth:
  injection:
    header_name: Authorization
    header_template: "Bearer {DATABRICKS_TOKEN}"

transport:
  type: "streamable-http"
  url: "{DATABRICKS_WORKSPACE_URL}/api/2.0/mcp/sql"

env:
  - name: DATABRICKS_WORKSPACE_URL
    description: "Your Databricks workspace URL including https://, e.g. https://dbc-a1b2c3d4-e5f6.cloud.databricks.com (no trailing slash)"
    required: true
  - name: DATABRICKS_TOKEN
    description: "Databricks personal access token (workspace Settings, Developer, Access tokens) or a service principal token"
    required: true
    sensitive: true

# Cheap authenticated read: spark-versions is available on every workspace
# and proves both the host and the token in one call.
validation:
  request:
    method: GET
    url: "{DATABRICKS_WORKSPACE_URL}/api/2.0/clusters/spark-versions"
    headers:
      Accept: application/json
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Databricks rejected the token (401). Generate a new personal access token under workspace Settings, Developer, Access tokens." }
    "403": { state: needs_setup, message: "The token's account lacks workspace access (403). Use a token from an account with workspace access." }
    "404": { state: needs_setup, message: "Workspace host returned 404. Check DATABRICKS_WORKSPACE_URL is the full https://... workspace URL with no trailing slash." }
    "default": { state: failed }
  timeout_ms: 8000
---

# Databricks SQL MCP Server

Databricks' managed MCP server for SQL. Agents run governed SQL against your workspace warehouse.

## How to connect

1. Find your workspace URL: it is the address in your browser when you are
   logged into Databricks, e.g. https://dbc-a1b2c3d4-e5f6.cloud.databricks.com
2. Generate a personal access token: workspace Settings, Developer,
   Access tokens, Generate new token. Copy it right away; it is shown once.
   A service principal token also works and outlives individual accounts.
3. Click **Connect** on the Databricks card, enter the workspace URL and the
   token, and save. Validation runs a read-only API call to confirm both.

## Notes

- One connection covers the SQL managed server. Genie spaces, Unity Catalog
  functions, and AI search use different per-workspace paths; connect those
  through Add custom MCP server for now.
- Tools are served by Databricks and discovered at session start.
