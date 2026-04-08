---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: schemabounce
  displayName: "SchemaBounce"
  version: "1.0.0"
  description: "SchemaBounce platform — workspaces, pipelines, schemas, drift, ADL, and analytics"
  tags: ["schemabounce", "platform", "pipelines", "schemas", "drift", "adl", "analytics"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "streamable-http"
  url: "${SCHEMABOUNCE_MCP_URL}/mcp"
env:
  - name: SCHEMABOUNCE_MCP_URL
    description: "SchemaBounce MCP service URL (managed by platform)"
    required: true
  - name: KOLUMN_CLIENT_ID
    description: "SchemaBounce service account client ID"
    required: true
  - name: KOLUMN_CLIENT_SECRET
    description: "SchemaBounce service account client secret"
    required: true
tools:
  - name: schemabounce_list_workspaces
    description: "List all accessible workspaces"
    category: workspaces
  - name: schemabounce_get_workspace_overview
    description: "Get workspace overview with environment and pipeline counts"
    category: workspaces
  - name: schemabounce_list_environments
    description: "List environments in a workspace"
    category: environments
  - name: schemabounce_get_pipeline_health
    description: "Get pipeline health metrics for an environment"
    category: pipelines
  - name: schemabounce_list_routes
    description: "List pipeline routes in an environment"
    category: pipelines
  - name: schemabounce_get_route_detail
    description: "Get detailed route configuration and status"
    category: pipelines
  - name: schemabounce_get_schema_state
    description: "Get current schema state for an environment"
    category: schemas
  - name: schemabounce_get_drift_report
    description: "Get schema drift detection report"
    category: schemas
  - name: schemabounce_get_source_status
    description: "Get source connection status and health"
    category: sources
  - name: schemabounce_search_catalog
    description: "Search the schema catalog across environments"
    category: catalog
  - name: schemabounce_get_agent_insights
    description: "Get AI agent activity insights and metrics"
    category: agents
  - name: schemabounce_query_usage
    description: "Query platform usage and billing metrics"
    category: analytics
  - name: schemabounce_get_audit_log
    description: "Get audit log entries for compliance and tracking"
    category: analytics
  - name: schemabounce_execute_query
    description: "Execute a read-only SQL query against environment databases"
    category: queries
  - name: schemabounce_adl_status
    description: "Get ADL (Agent Data Layer) infrastructure status"
    category: adl
  - name: schemabounce_adl_query
    description: "Query ADL records by entity type with filters"
    category: adl
  - name: schemabounce_adl_get_record
    description: "Get a single ADL record by ID"
    category: adl
  - name: schemabounce_adl_upsert_record
    description: "Create or update an ADL record"
    category: adl
  - name: schemabounce_adl_delete_record
    description: "Delete an ADL record"
    category: adl
  - name: schemabounce_adl_memory
    description: "Read or write agent private memory"
    category: adl
  - name: schemabounce_adl_actions
    description: "Get agent action history and logs"
    category: adl
  - name: schemabounce_adl_update_config
    description: "Update ADL agent configuration"
    category: adl
  - name: schemabounce_adl_bulk_upsert
    description: "Bulk create or update ADL records"
    category: adl
  - name: schemabounce_adl_bulk_delete
    description: "Bulk delete ADL records"
    category: adl
  - name: schemabounce_adl_graph_add_edge
    description: "Add an edge to the ADL knowledge graph"
    category: graph
  - name: schemabounce_adl_graph_list_edges
    description: "List edges in the ADL knowledge graph"
    category: graph
  - name: schemabounce_adl_graph_delete_edge
    description: "Delete an edge from the ADL knowledge graph"
    category: graph
  - name: schemabounce_adl_graph_neighbors
    description: "Find neighbor entities in the ADL knowledge graph"
    category: graph
  - name: schemabounce_adl_semantic_search
    description: "Semantic vector search across ADL records"
    category: search
---

# SchemaBounce MCP Server

Provides full read/write access to the SchemaBounce platform for agents that manage workspaces, monitor pipelines, track schema drift, query analytics, and interact with the Agent Data Layer.

This is the **core platform MCP server** — every bot deployed on SchemaBounce can access their workspace's data through these 29 tools.

## Which Bots Use This

Every bot has implicit access to ADL tools via the standard tool set. This MCP server extends that with platform-level operations:

- **sre-devops** — Monitor pipeline health, check environment status, query audit logs
- **data-analyst** — Execute read-only SQL queries, search the schema catalog, query usage metrics
- **executive-assistant** — Get workspace overviews, agent insights, usage analytics

## Setup

This server is managed by the SchemaBounce platform. Agents deployed in a workspace automatically receive credentials via the runtime environment. No manual setup required.

For external access (CI/CD, scripts), create a Service Account in Workspace Settings:

1. Navigate to Workspace Settings > Service Accounts
2. Create a service account with appropriate permissions
3. Use the client ID and secret as `KOLUMN_CLIENT_ID` and `KOLUMN_CLIENT_SECRET`

## Team Usage

All bots implicitly have access to ADL tools. For platform-level operations, add explicitly:

```yaml
mcpServers:
  - ref: "tools/schemabounce"
    reason: "Access workspace analytics, pipeline health, and schema drift reports"
```
