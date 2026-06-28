---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: schemabounce
  displayName: "SchemaBounce"
  version: "1.0.0"
  description: "SchemaBounce platform, workspaces, pipelines, schemas, drift, ADL, and analytics"
  tags: ["schemabounce", "platform", "pipelines", "schemas", "drift", "adl", "analytics"]
  category: "platform"
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
  - name: sb_workspace
    description: "Workspaces and members. Actions: list, inspect, provision, archive, member_list, member_add, member_remove, member_update_role"
    category: workspaces
  - name: sb_env
    description: "Environments. Actions: list, create, update, delete, promote"
    category: environments
  - name: sb_route
    description: "Pipeline routes. Actions: list, inspect, create, update, lifecycle"
    category: pipeline
  - name: sb_source
    description: "CDC sources. Actions: inspect, list, create, update, delete, test, discover, cdc_resync"
    category: sources
  - name: sb_sink
    description: "Sinks (env-scoped). Actions: list, create, update, delete, test"
    category: sinks
  - name: sb_schema
    description: "Schema, drift, catalog, and queries. Actions: state, drift_report, drift_resolve, catalog_search, query_run"
    category: schema
  - name: sb_credential
    description: "Service accounts, API keys, OAuth clients, and env secrets. Actions: list, create_sa, update_sa, delete_sa, create_api_key, revoke_api_key, create_oauth_client, revoke_oauth_client, rotate, secret_list, secret_create, secret_update, secret_delete, secret_rotate"
    category: credentials
  - name: sb_adl
    description: "Agent Data Layer data plane. Actions: status, records_query, records_get, records_upsert, records_delete, bulk_upsert, bulk_delete, memory_get, memory_set, memory_delete, memory_list_namespaces, memory_list_keys, memory_log, graph_add_edge, graph_list_edges, graph_delete_edge, graph_neighbors, search"
    category: adl
  - name: sb_agent
    description: "Agents: manage, lifecycle, runs, sessions, proposals. Actions: manage_list, manage_get, manage_create, manage_update, manage_move, manage_delete, chat, lifecycle_enable, lifecycle_disable, lifecycle_resume, lifecycle_restore, lifecycle_set_run_mode, run, runs_list_all, runs_list, runs_get, runs_usage, runs_sync_status, whoami, sessions_list, sessions_messages, sessions_end, proposals_list, proposals_approve, proposals_reject"
    category: agents
  - name: sb_marketplace
    description: "Marketplace browse + activation. Actions: list_bots, list_teams, list_tools, activate_bot, activate_team, hot_swap_skills"
    category: agents
  - name: sb_access
    description: "Agent permissions end-to-end. Actions: connection_create, connection_list, connection_get, connection_delete, connection_validate, grant, revoke, list_grants, set_tool_allowlist, policy_get, policy_set, policy_check, list_policy_actions, store_secret, secret_status"
    category: agents
  - name: sb_automation
    description: "Automation: inspect, schedules, workflows, LLM keys. Actions: inspect, schedule_list, schedule_create, schedule_update, schedule_delete, workflow_list, workflow_get, workflow_create, workflow_update, workflow_delete, workflow_trigger, workflow_runs, llm_list, llm_set, llm_verify, llm_delete, llm_models, llm_get_billing, llm_set_billing"
    category: automation
  - name: sb_audit
    description: "Workspace audit log. Actions: search, export"
    category: audit
  - name: sb_billing
    description: "Billing. Actions: inspect, change_plan, add_addon, remove_addon, checkout_url, portal_url"
    category: billing
  - name: sb_ops
    description: "Ops: ADL files, SSO config, and A2A dispatch. Actions: files_list, files_get, files_get_content, files_upload, files_delete, sso_status, sso_connection_create, sso_connection_update, sso_connection_delete, sso_mappings_list, sso_mapping_upsert, sso_mapping_delete, a2a_agent_card, a2a_rpc"
    category: ops
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
