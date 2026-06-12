---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: workspace-health
  displayName: "Workspace Health (internal ops)"
  version: "1.0.0"
  description: "INTERNAL-ONLY cross-workspace health inspection and remediation for the customer-success agent — never granted to customer agents"
  tags: ["ops", "health", "internal", "admin"]
  category: "platform"
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  packageType: "github"
  repo: "SchemaBounce/Internal-mcp"
  ref: "v2.0.0-alpha.1"
  asset: "sb-workspace-health-mcp-linux-amd64"
env:
  - name: SCHEMABOUNCE_CLIENT_ID
    description: "Platform admin service account client ID (must be an admin_sa_ prefixed account). Read-only tools require the platform-admin-readonly role; mutation tools require the platform-admin role."
    required: true
    sensitive: true
  - name: SCHEMABOUNCE_CLIENT_SECRET
    description: "Platform admin service account client secret — shown only once at creation time. MUST belong to a platform admin service account (admin_sa_). Standard workspace service accounts (sa_) will receive 403 on every tool call."
    required: true
    sensitive: true
  - name: SCHEMABOUNCE_API_URL
    description: "SchemaBounce API base URL (defaults to the platform endpoint)"
    required: false
validation:
  tool:
    name: platform_health
    args: {}
healthProbe:
  tool:
    name: platform_health
    args: {}
  interval_seconds: 300
tools:
  - name: workspace_health_list
    description: "List all workspaces with their current health state, subscription tier, and last reconcile timestamp. Paginated. Read-only."
    category: health
  - name: workspace_health_get
    description: "Get the detailed health report for a single workspace, including component states (ADL, pipeline, Redis, OpenCLAW), last error, and reconcile history. Read-only."
    category: health
  - name: platform_health
    description: "Get platform-wide health aggregates: total workspace count, healthy/degraded/failed breakdown, and the top recurring error classes across all workspaces. Read-only."
    category: health
  - name: workspace_overview
    description: "Get a compact workspace overview: owner, tier, environments, active pipelines, agent count, and ADL provisioning status. Read-only."
    category: health
  - name: dlq_list
    description: "List dead-letter queue entries for a workspace. Returns failed event count, oldest entry timestamp, and error class breakdown. Read-only."
    category: health
  - name: trigger_reconcile
    description: "Trigger an out-of-cycle infrastructure reconcile for a workspace. Elicitation-gated — requires explicit workspace_id and a written reason. Audited."
    category: remediation
  - name: route_pause
    description: "Pause a pipeline route for a workspace. Elicitation-gated. Audited."
    category: remediation
  - name: route_resume
    description: "Resume a paused pipeline route for a workspace. Elicitation-gated. Audited."
    category: remediation
  - name: cdc_enable
    description: "Enable CDC ingestion for a workspace environment. Elicitation-gated. Audited."
    category: remediation
  - name: cdc_disable
    description: "Disable CDC ingestion for a workspace environment. Elicitation-gated. Audited."
    category: remediation
  - name: dlq_redrive
    description: "Redrive dead-letter queue entries for a workspace. Elicitation-gated — requires workspace_id and explicit confirmation of entry count. Audited."
    category: remediation
  - name: repair_roles
    description: "Re-apply RBAC role grants for a workspace where roles have drifted from the desired state. Elicitation-gated. Audited. Idempotent."
    category: remediation
---

# Workspace Health (internal ops) MCP Server

> **INTERNAL ONLY — this server is NEVER granted to customer agents and must NEVER appear in the public connections catalog.**
>
> It provides cross-workspace, platform-admin-level health inspection and remediation tools for use exclusively by the SchemaBounce customer-success agent running under a platform admin service account. All mutation tools are elicitation-gated and fully audited. Granting this server to a customer workspace agent is a critical security violation.

## What this server does

`sb-workspace-health-mcp` gives the customer-success agent two categories of tools:

- **Reads** (5 tools): inspect health state, component status, DLQ backlogs, and platform-wide aggregates across ALL workspaces. Requires `platform-admin-readonly` role.
- **Mutations** (7 tools): trigger reconciliation, pause/resume routes, enable/disable CDC, redrive DLQ entries, repair drifted RBAC roles. Requires `platform-admin` role. Every mutation emits a `severity=high` audit row and is elicitation-gated — the agent must request explicit confirmation before executing.

## Authentication

The credential MUST be a **platform admin service account**. These accounts have the `admin_sa_` prefix (e.g. `admin_sa_cs_agent`) and are created in the internal SchemaBounce admin console, NOT the customer workspace settings UI. Standard workspace service accounts (`sa_` prefix) have no access to cross-workspace endpoints and will receive `403 Forbidden` on every call.

| Role | Grants |
|------|--------|
| `platform-admin-readonly` | All 5 read tools |
| `platform-admin` | All 12 tools (reads + mutations) |

The server performs an OAuth `client_credentials` token exchange against `<SCHEMABOUNCE_API_URL>/api/v1/oauth/token` on startup, then caches and auto-refreshes the Bearer token for all subsequent tool calls.

## Which agents use this

- **customer-success** (`bots/customer-success/`) — internal SchemaBounce bot that monitors workspace health, responds to support escalations, and performs safe remediations without engineering intervention.

## Security model

This server has cross-workspace access. It can read health state and trigger remediations for ANY workspace on the platform. The following controls apply:

1. **Platform admin SA only** — validated at the API level; customer SAs receive 403.
2. **Mutation elicitation gate** — all 7 mutation tools call back to the agent with a structured elicitation request before executing. The agent must confirm the target workspace, the action, and the reason.
3. **Audit trail** — every tool call emits an audit row to `schemabounce_audit.audit_events` with `category=ops`, `actor_type=agent`, `workspace_id` (target), and the full request payload. Mutation rows are `severity=high`.
4. **No customer data access** — tools expose operational state only (health flags, error classes, queue depths). They do not read ADL records, pipeline event payloads, or customer secrets.
5. **Never listed in the marketplace** — `mcpServerMeta.ts` explicitly excludes this server from the customer connections catalog.

## Tool reference

### Read tools

#### `workspace_health_list`

Lists all workspaces with health summary. Paginated (`page`, `page_size`). Filterable by `health_state` (`healthy`, `degraded`, `failed`).

Returns `{ workspaces: [{ workspace_id, name, tier, health_state, last_reconcile_at, component_summary }], total, page }`.

#### `workspace_health_get`

Returns the full component health breakdown for one workspace.

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | Yes | Target workspace ID |

Returns `{ workspace_id, name, tier, health_state, components: { adl, pipeline, redis, openclaw }, last_error, reconcile_history }`.

#### `platform_health`

Platform-wide aggregate health snapshot. No parameters.

Returns `{ total, healthy, degraded, failed, top_error_classes: [{ class, count }], as_of }`.

#### `workspace_overview`

Compact workspace summary for triage and context.

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | Yes | Target workspace ID |

Returns `{ workspace_id, name, owner_email, tier, environments, active_pipeline_routes, agent_count, adl_provisioning_status }`.

#### `dlq_list`

DLQ backlog for a workspace.

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | Yes | Target workspace ID |
| `environment_id` | string | No | Filter to one environment |

Returns `{ workspace_id, total_failed, oldest_entry_at, error_class_breakdown: [{ class, count }] }`.

### Mutation tools (elicitation-gated, audited)

All mutation tools require an explicit agent confirmation step before execution. The tool returns an elicitation request; the agent must call the tool a second time with `confirmed: true` to proceed.

#### `trigger_reconcile`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | Yes | Target workspace |
| `reason` | string | Yes | Written justification for the out-of-cycle reconcile |
| `confirmed` | boolean | No | Set `true` on the confirmed call |

#### `route_pause` / `route_resume`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | Yes | Target workspace |
| `route_id` | string | Yes | Pipeline route to pause or resume |
| `confirmed` | boolean | No | Set `true` on the confirmed call |

#### `cdc_enable` / `cdc_disable`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | Yes | Target workspace |
| `environment_id` | string | Yes | Environment to enable/disable CDC on |
| `confirmed` | boolean | No | Set `true` on the confirmed call |

#### `dlq_redrive`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | Yes | Target workspace |
| `environment_id` | string | No | Scope to one environment |
| `entry_count` | integer | Yes | Number of DLQ entries to redrive (must match the count the agent confirmed) |
| `confirmed` | boolean | No | Set `true` on the confirmed call |

#### `repair_roles`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | Yes | Target workspace |
| `confirmed` | boolean | No | Set `true` on the confirmed call |

Idempotent — re-applying already-correct roles is a no-op. Safe to run on healthy workspaces.

## How the server launches

The runtime starts `sb-workspace-health-mcp` as a child process (stdio transport). It reads JSON-RPC from stdin and writes responses to stdout; stderr carries structured logs. The three env vars are injected from the internal connection store at startup. The server performs an OAuth `client_credentials` exchange on boot, then caches the Bearer token.

The `sb-workspace-health-mcp` binary is built from `core-api/cmd/sb-workspace-health-mcp/` and ships in the internal toolchain image — it is NOT published to any public package registry.
