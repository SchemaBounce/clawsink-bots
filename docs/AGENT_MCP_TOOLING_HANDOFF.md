# Agent MCP Tooling Handoff

**Audience:** the next agent picking up bot-tooling work after the no-vaporware sweep landed.
**Status:** sweep complete as of 2026-04-26. The marketplace fleet is honest. This doc tracks remaining polish, future work, and the audit harness that keeps drift from creeping back.
**Single source of truth for the gap:** `scripts/audit-bot-tooling.sh` in this repo. Re-run it whenever you finish a bot.

## 1. Executive Summary

The fleet went from `13 shallow / 10 none / 41 connected / 0 internal-only` to `0 shallow / 0 none / 53 connected / 12 internal-only` across 65 bots. Every bot in the marketplace now falls into one of two honest states:

- **connected**: every declared MCP server resolves to a real runtime registry entry. Activation flows can grant access and the agent can actually call the tool.
- **internal-only**: the bot intentionally has zero MCP servers because its job is to read SchemaBounce-platform internals (pipeline metrics, agent runs, ADL records). These bots are marked with an explicit `# Internal-only by design` marker comment in their `BOT.md` and are detected by the audit script.

There are no longer any `none` (vaporware) or `shallow` (declared-but-unwired) bots. The sweep also shipped two new first-party showcase bots and three new runtime built-in tools that prove the pattern.

The remaining work is polish, not gap-closing. See §5.

## 2. Audit (run `bash scripts/audit-bot-tooling.sh` to refresh)

The script walks every `bots/*/BOT.md`, parses the `mcpServers[]` block, splits each ref into one of three buckets:

- **wired**: referenced server exists in `core-api/.../adl/mcp_connection_service.go` `embeddedEnvSpecs` map. At runtime, activation can grant access and the agent can actually call it.
- **manifest**: there is a `tools/<name>/SERVER.md` here, but no entry in the runtime registry. The bot will activate; the tool will silently no-op. **Should always be 0 after the sweep.**
- **unknown**: referenced server is not in `tools/` and not in the registry. Bot is broken-by-spec. **Should always be 0.**

Depth scoring (4 states):

- **none**: `mcpServers: []` AND `egress.mode: "none"` AND no `# Internal-only by design` marker. No path to anything external. **Should be 0.**
- **shallow**: at least one ref is in the `manifest` or `unknown` bucket, OR `mcpServers: []` but `egress.mode != "none"` (loose policy with no tools). **Should be 0.**
- **connected**: every declared ref is `wired`.
- **internal-only**: `mcpServers: []` AND the BOT.md has the `# Internal-only by design` marker comment. The bot reads platform internals via runtime built-ins. Honest, by design.

### Current state (snapshot, 2026-04-26)

**Totals:** 65 bots: **0 none · 0 shallow · 53 connected · 12 internal-only**

The full table is the live output of the audit script. Re-run any time. Sample lines:

```
| Bot                       | #mcp | egress     | wired/manifest/unknown | Depth          |
|---------------------------|-----:|------------|-----------------------:|----------------|
| accountant                | 5    | none       | 5/0/0                  | connected      |
| customer-support          | 10   | none       | 10/0/0                 | connected      |
| executive-assistant       | 10   | none       | 10/0/0                 | connected      |
| sales-pipeline            | 9    | restricted | 9/0/0                  | connected      |
| sre-devops                | 4    | restricted | 4/0/0                  | connected      |
| pipeline-cost-optimizer   | 0    | none       | 0/0/0                  | internal-only  |
| agent-cost-optimizer      | 0    | none       | 0/0/0                  | internal-only  |
| blog-writer               | 0    | none       | 0/0/0                  | internal-only  |
```

The `manifest` and `unknown` columns are now `0/0` for every bot. That is the bar.

### The 12 internal-only-by-design bots

| Bot | What it reads |
|-----|---------------|
| agent-cost-optimizer | `agent_runs` (token usage, model spend, schedule mismatches) |
| anomaly-detector | ADL records and memory (workspace data anomalies) |
| atlas | ADL graph + records (workspace-internal mapping) |
| blog-writer | ADL records (drafts, schedule, owned content state) |
| data-quality-monitor | ADL records (workspace data conformance) |
| experiment-tracker | ADL records (experiment state managed in-workspace) |
| infrastructure-reporter | runtime built-ins (pipeline + agent platform telemetry) |
| inventory-alert | ADL records (inventory state managed in-workspace) |
| mentor-coach | ADL memory (per-user coaching state) |
| pipeline-cost-optimizer | `pipeline_event_rollups`, `environment_sinks`, `pipeline_routes` |
| platform-optimizer | runtime built-ins (cross-cutting platform telemetry) |
| workflow-designer | ADL records (workflow definitions managed in-workspace) |

These are the canonical pattern for "what value does SchemaBounce add over a Composio-only fleet": see `docs/FIRST_PARTY_BOTS.md` for the customer-facing version of that argument.

## 3. The Sweep, Workstream by Workstream

Three workstreams ran in parallel and all closed.

### Workstream A: strip-or-wire shallow bots (12 → 0)

For each shallow bot, the rule was:

1. If the missing tool was already in `embeddedEnvSpecs` (e.g., `tools/github`, `tools/exa`, `tools/firecrawl`, `tools/agentmail`, `tools/composio`), wire it by adding it to the bot's `mcpServers[]`.
2. If the missing tool was a real third-party service (Salesforce, HubSpot, Gmail, GoogleCalendar, Zendesk, Freshdesk, Intercom, GoogleDocs, Confluence, QuickBooks, Xero, Zoom, Salesforce, ElevenLabs, AgentPhone), add a runtime registry entry first, then wire it.
3. If the missing tool was speculative (multi-cloud admin shells like aws/gcp/azure-cli, docker, kubernetes, datadog, sentry, grafana, pagerduty, codex), strip it from the manifest and route the bot's domain through Composio. Composio already brokers the most common SaaS endpoints we'd want; native MCP servers can land later when there's a customer-driven priority.

After the sweep, every connected bot has `wired/manifest/unknown = N/0/0`.

### Workstream B: first-party showcase bots

Two new bots shipped that demonstrate the value-add SchemaBounce has over a wrapper-on-Composio fleet. Both are pure platform-internal: they call only runtime built-ins, never a third-party MCP, never raw HTTP.

- **`bots/pipeline-cost-optimizer/`**: audits pipeline routes for idle, oversized fan-out, errored, high run-rate, missing DLQ, missing retry policy. Writes `pipeline_route_audit` records and `pipeline_cost_recommendation` records with concrete `projected_monthly_usd` numbers. Tunable thresholds in `data-seeds/zone1-north-star.json`.
- **`bots/agent-cost-optimizer/`**: audits per-agent token usage, model spend, runaway agents (high run-rate × high failure-rate), over-spec models (Sonnet/Opus on workloads that would fit Haiku), schedule mismatches. Writes `agent_cost_audit` records and `agent_cost_recommendation` records with `projected_monthly_savings_usd`.

These are the canonical pattern for any future "what does the platform read" bot. Future internal-only bots should follow this shape: north-star JSON with thresholds and cost tables, an `analyzer` sub-agent that emits per-entity audits, a `recommender` sub-agent that emits findings, explicit `setup_gap` records when the data isn't there to back a number.

### Workstream C: mark internal-only-by-design bots

Twelve bots had `mcpServers: []` for honest reasons (their job is to read workspace data via runtime built-ins, not external systems). The audit script previously flagged these as `none` (vaporware). The sweep:

1. Added a `# Internal-only by design` marker comment near the top of each BOT.md.
2. Updated `scripts/audit-bot-tooling.sh` to recognize the marker and report depth=`internal-only` instead of `none`.
3. Documented each bot's data-source story in §2 of this file.

The marker is load-bearing. **Don't remove it without re-classifying the bot.**

## 4. New Runtime Built-Ins (powering internal-only bots)

The two showcase bots relied on three new tools shipped in `core-api/openclaw-runtime/internal/executor/tools_pipeline_metrics.go`:

| Tool | Source table | Use |
|------|--------------|-----|
| `adl_get_route_metrics(route_id, windows[])` | `schemabounce_core.pipeline_event_rollups` | Per-route + per-window event counts. Powers dollar-figure projections in pipeline-cost-optimizer. |
| `adl_get_agent_metrics(agent_id?, windows[])` | `schemabounce_adl.agent_runs` (per-workspace pool) | Aggregates input/output/cache/thinking tokens, estimated cost, status counts, model-id distribution. Powers model-downgrade and runaway detection in agent-cost-optimizer. |
| `adl_list_workspace_sinks(environment_id?, status?, limit?)` | `schemabounce_core.environment_sinks` | Returns sink operational config (DLQ presence, retry policy, batching). Strips credentials and KMS key IDs. Powers reliability scoring in pipeline-cost-optimizer. |

These join the existing built-ins (`adl_list_pipeline_routes`, `adl_get_route_status`, `adl_list_workspace_sources`, `adl_list_sink_types`, `adl_list_agents`, `adl_get_agent_status`, `adl_query_records`, `adl_query_duckdb`, `adl_read_memory`, `adl_write_memory`, `adl_send_message`) to round out a usable platform-internal toolkit.

## 5. Future Work

These items did not block the sweep, but a future agent should pick them up.

### 5.1 Polish connected bots' system prompts

A handful of connected bots still list tool capabilities generically (e.g., "use Composio to send Slack messages") instead of driving Composio's discover-then-execute pattern explicitly. The discover step is the difference between Composio actually firing the right action and the LLM hallucinating tool names. Audit these for prompt clarity:

- `customer-support` (10 servers: many through Composio)
- `executive-assistant` (10 servers: Composio + Gmail + GoogleCalendar split)
- `sales-pipeline` (9 servers: Salesforce/HubSpot via direct, Slack/Gmail via Composio)
- `sre-devops` (4 servers: observability via Composio after the strip)

For each, the prompt should explicitly tell the agent:

1. Which capabilities are owned by which server.
2. To call the Composio `discover` tool first when the right action isn't obvious.
3. To never invent a tool name.

### 5.2 Direct-MCP servers for stripped tools

The sweep stripped a number of speculative manifest references in favour of routing through Composio. If any of these become customer-driven priorities, they could be wired natively for lower latency and finer-grained auth scopes:

- aws / gcp / azure (cloud admin shells)
- kubernetes / docker
- datadog / sentry / grafana / pagerduty (observability)
- codex (preview, deferred: see §5.3)

Native servers would follow the existing `tools/<name>/SERVER.md` + `embeddedEnvSpecs` pattern. None are urgent today.

### 5.3 Codex MCP server

Codex was stripped from `documentation-writer` and `software-architect` during the sweep (it's still preview-tier and not yet stable as a long-running MCP server). When it ships GA, add a runtime registry entry and wire it back in.

### 5.4 Per-route batching/rate-limit overrides

`adl_get_route_metrics` exposes per-window event counts but not the per-route rate-limit and batching settings that would let `pipeline-cost-optimizer` recommend "raise batch size from 100 to 1000 to cut per-event sink overhead." The recommendation surface today is constrained to "this route is high-volume" without saying "and you could batch it harder." Adding batch + rate fields to the tool's response (or a sibling tool, `adl_get_route_config`) would let the recommender surface that class of finding.

### 5.5 Per-workspace threshold overrides

Both showcase bots default-load thresholds from `data-seeds/zone1-north-star.json`. Operators can override by editing `bot:<bot-name>:northstar` ADL memory directly, but there is no UI for this today. A workspace settings page that exposes these knobs (cost thresholds, idle definitions, model cost table overrides) would let the bots run honestly against teams whose actual contracted rates differ from the seed defaults.

## 6. Audit Harness Maintenance

`scripts/audit-bot-tooling.sh` is the truth. Re-run it on every PR that touches `bots/*/BOT.md` or `tools/*/SERVER.md` or the runtime registry. Two flags:

- `bash scripts/audit-bot-tooling.sh`: full table.
- `bash scripts/audit-bot-tooling.sh --counts-only`: just the totals line, suitable for CI.

If the script ever shows `none > 0` or `shallow > 0`, the sweep has regressed. If it shows `internal-only` for a bot you expect to have external integrations, check whether someone added the marker comment by accident.

## 7. Reference

- Audit script: `scripts/audit-bot-tooling.sh`
- Runtime registry: `core-api/schemabounce-api/internal/adl/mcp_connection_service.go`
- Runtime built-ins for platform internals: `core-api/openclaw-runtime/internal/executor/tools.go` and `core-api/openclaw-runtime/internal/executor/tools_pipeline_metrics.go`
- Activation auto-grant logic: `core-api/schemabounce-api/internal/handlers/adl_bot_activation_handler.go`
- Existing OAuth popup: `frontend/src/hooks/useOAuthPopup.ts`, `frontend/src/components/.../OAuthPopup.tsx`
- Customer-facing strategic doc: `docs/FIRST_PARTY_BOTS.md`
- First-party bot canonical examples: `bots/pipeline-cost-optimizer/`, `bots/agent-cost-optimizer/`

If anything in here is wrong by the time you pick it up, the script is the truth. Re-run it first.
