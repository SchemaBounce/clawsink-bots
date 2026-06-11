---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: schemabounce
  displayName: "SchemaBounce"
  version: "1.0.0"
  description: "SchemaBounce platform, workspaces, pipelines, schemas, drift, ADL, and analytics"
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
    sensitive: true
  - name: KOLUMN_CLIENT_SECRET
    description: "SchemaBounce service account client secret"
    required: true
    sensitive: true
tools:
  - name: sb_workspace_list
    description: "List the workspaces visible to the current credential"
    category: workspaces
  - name: sb_workspace_inspect
    description: "Full snapshot of one workspace: status, tier, members, environments"
    category: workspaces
  - name: sb_workspace_provision
    description: "Create a new workspace, optionally with initial environments and member invitations"
    category: workspaces
  - name: sb_workspace_archive
    description: "Archive a workspace (recoverable) or hard-delete it (irreversible cascade)"
    category: workspaces
  - name: sb_member_manage
    description: "List, add, remove, or change role of workspace members"
    category: workspaces
  - name: sb_env_list
    description: "List environments in a workspace"
    category: environments
  - name: sb_env_manage
    description: "Create, update, or delete an environment"
    category: environments
  - name: sb_env_promote
    description: "Copy resources between environments (routes, sinks, sources, secrets)"
    category: environments
  - name: sb_route_list
    description: "List pipeline routes in a workspace, optionally filtered by environment_id and/or status"
    category: pipeline
  - name: sb_route_inspect
    description: "Deep-dive on one route: config, HCL definition, deployment history, open PRs, and bound sinks/source"
    category: pipeline
  - name: sb_route_create
    description: "Create a pipeline route bound to an environment, with source config and sink bindings"
    category: pipeline
  - name: sb_route_update
    description: "Patch a route's name, source_config, or sink bindings"
    category: pipeline
  - name: sb_route_lifecycle
    description: "Deploy, pause, resume, or archive a pipeline route"
    category: pipeline
  - name: sb_source_manage
    description: "List/create/update/delete CDC sources, plus test connectivity and discover schema"
    category: sources
  - name: sb_source_inspect
    description: "Deep snapshot of one CDC source: status, replication lag, tables, downstream subscribers"
    category: sources
  - name: sb_cdc_resync
    description: "Restart CDC ingestion from a snapshot, a specific LSN, or a timestamp"
    category: sources
  - name: sb_sink_manage
    description: "List/create/update/delete sinks (env-scoped) plus test connectivity"
    category: sinks
  - name: sb_schema_state
    description: "Fetch the Kolumn state file and/or resource list, dependency graph, and statistics for an environment"
    category: schema
  - name: sb_drift_report
    description: "Workspace-wide or per-environment drift report (managed resources whose runtime state diverges from declared HCL)"
    category: schema
  - name: sb_drift_resolve
    description: "Re-sync drifted resources in an environment"
    category: schema
  - name: sb_catalog_search
    description: "Search the schema catalog for tables, columns, and assets"
    category: catalog
  - name: sb_query_run
    description: "Execute SQL through an analytics connection (read-only enforced by backend permissions)"
    category: queries
  - name: sb_credential_list
    description: "Unified list of service accounts, API keys, and OAuth clients"
    category: credentials
  - name: sb_credential_manage
    description: "Create/update/delete service accounts, API keys, and OAuth clients"
    category: credentials
  - name: sb_credential_rotate
    description: "Rotate a service account / admin SA / API key / OAuth client secret"
    category: credentials
  - name: sb_secret_manage
    description: "List/create/update/delete secrets within an environment"
    category: secrets
  - name: sb_secret_rotate
    description: "Rotate (replace value) or revoke (mark unusable) an env secret"
    category: secrets
  - name: sb_adl_status
    description: "ADL system status: tier, postgres/pgvector/AGE/redis/duckdb readiness, storage usage, connection info, data stats"
    category: adl
  - name: sb_adl_records
    description: "Query / get / upsert / delete records in the Agent Data Layer"
    category: adl
  - name: sb_adl_bulk
    description: "Bulk upsert or delete records (up to 1000)"
    category: adl
  - name: sb_adl_memory
    description: "Read/write agent memory (key/value store, namespaced)"
    category: adl
  - name: sb_adl_graph
    description: "Add/list/delete edges and traverse neighbors on the AGE-backed knowledge graph"
    category: adl
  - name: sb_adl_search
    description: "Semantic search over ADL records via pgvector embeddings"
    category: adl
  - name: sb_agent_manage
    description: "List/get/create/update/move/delete agents in the workspace, plus dispatch a chat message"
    category: agents
  - name: sb_bot_marketplace
    description: "Browse the marketplace (bots, teams, MCP tools) and activate bots/teams in the workspace"
    category: agents
  - name: sb_agent_lifecycle
    description: "Enable, disable, resume, restore, set run-mode, or kick off a run for a deployed agent"
    category: agents
  - name: sb_agent_runs
    description: "List, fetch, and aggregate agent-run records"
    category: agents
  - name: sb_agent_sessions
    description: "List sessions, fetch message history, or terminate a session for a deployed agent"
    category: agents
  - name: sb_agent_mcp_access
    description: "List/grant/revoke MCP-connection access for an agent, and store/check per-agent encrypted secrets"
    category: agents
  - name: sb_agent_proposals
    description: "List, approve, or reject agent-authored improvement proposals"
    category: agents
  - name: sb_llm_keys
    description: "List/set/verify/delete LLM provider API keys; list available models; read/write billing config"
    category: automation
  - name: sb_workflow_manage
    description: "List/get/create/update/delete workflows, trigger runs, and inspect run history"
    category: automation
  - name: sb_schedule_manage
    description: "Create/list/update/delete cron-scheduled tasks that trigger workflows or chat with agents on a schedule"
    category: automation
  - name: sb_automation_inspect
    description: "List the workspace's automations (scheduled, event-driven, manual) plus aggregate stats"
    category: automation
  - name: sb_audit_search
    description: "Filtered search across the workspace audit log"
    category: audit
  - name: sb_audit_export
    description: "Trigger an export of audit events (CSV / JSON / NDJSON)"
    category: audit
  - name: sb_billing_inspect
    description: "Snapshot of plan, addons, subscription, recent invoices, and credit balance for the workspace"
    category: billing
  - name: sb_billing_manage
    description: "Change plan, add/remove addons, generate Stripe checkout URL, or generate a customer-portal URL"
    category: billing
  - name: sb_sso_manage
    description: "Configure the workspace's SSO connection (OIDC or SAML), claim to role mappings, and fetch SAML metadata URL"
    category: sso
  - name: sb_files_manage
    description: "List/get/upload/delete files in the Agent Data Layer"
    category: files
  - name: sb_a2a_dispatch
    description: "Read an agent card and dispatch a JSON-RPC call to an A2A-protocol agent"
    category: a2a
---

# SchemaBounce MCP Server

Provides full read/write access to the SchemaBounce platform for agents that manage workspaces, monitor pipelines, track schema drift, query analytics, and interact with the Agent Data Layer.

This is the **core platform MCP server** with 51 tools across 10 domains. Every bot deployed on SchemaBounce can reach their workspace's data through these tools.

## Which Bots Use This

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
