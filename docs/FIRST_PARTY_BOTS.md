# First-Party Bots: Why SchemaBounce, Not Composio

**Audience:** prospects evaluating SchemaBounce against the option of "I'll just build agents on Composio directly."
**Bottom line:** Composio is a good integrator of third-party SaaS APIs. SchemaBounce is an agent runtime that owns its own data plane. Bots that read pipeline metrics, agent run history, sink reliability, and cross-environment workspace state are bots Composio cannot ship, because Composio does not host those primitives. This doc walks through the first-party bots that prove the difference.

## 1. The Differentiation

Composio brokers OAuth and API calls to roughly 250 third-party SaaS products. If your job is to stitch Stripe + Slack + HubSpot together, Composio is fine. The Composio-only ceiling is reached the moment your agent needs to answer:

- "Which of my pipeline routes processed zero events in the last 14 days?"
- "Which of my agents is spending $200 a month on Sonnet workloads that would fit on Haiku?"
- "Which of my sinks have no DLQ configured and are running on `at_most_once` delivery?"
- "Which of my routes had a fan-out increase that doubled the projected monthly cost?"

These are not Composio questions. There is no SaaS API that exposes them. They live inside the data plane of the platform that runs the bots: `pipeline_event_rollups`, `agent_runs`, `environment_sinks`, `pipeline_routes`. SchemaBounce owns those tables. SchemaBounce ships built-in runtime tools that read those tables. SchemaBounce ships first-party bots that compose those tools into actionable findings.

That is the value-add. It is not a Composio wrapper. It is platform-aware automation.

## 2. Two Showcase Bots

Both ship today. Both are pure platform-internal: zero third-party MCP servers, zero Composio in the data path, zero raw HTTP. Both are tunable per workspace via ADL memory overrides.

### 2.1 pipeline-cost-optimizer

**Location:** `bots/pipeline-cost-optimizer/`
**Default schedule:** weekly, Monday 06:00 UTC.
**Cost tier:** low (8k tokens per run, ~$0.08 on Sonnet).

**What it audits:**

| Finding type | Trigger |
|--------------|---------|
| `idle_route` | Route's last event is older than `idle_warn_days` (default 14) or `idle_critical_days` (default 30). |
| `oversized_fanout` | Route has more sinks than `fanout_warn_count` (default 3) or `fanout_critical_count` (default 5). |
| `errored_route` | Route has lifetime error count above `error_count_warn_lifetime` (default 100) or `error_count_critical_lifetime` (default 1000). |
| `high_runrate` | Projected monthly run-rate (events × per-sink cost) above `runrate_warn_usd` (default $100) or `runrate_critical_usd` (default $500). |
| `missing_dlq` | Sink has no DLQ configured and is on `at_most_once` delivery. |
| `missing_retry_policy` | Sink has no retry policy and the source is not idempotent. |
| `setup_gap` | Metric is null. The recommendation explains what data is missing and why. |

**Runtime tools it uses:**

- `adl_list_pipeline_routes` (existing): enumerate routes.
- `adl_get_route_status` (existing): current state per route.
- `adl_get_route_metrics(route_id, windows=["24h","7d","30d"])` (new): event counts per window from `pipeline_event_rollups`.
- `adl_list_workspace_sources` (existing): source config.
- `adl_list_workspace_sinks(environment_id?, status?)` (new): sink reliability config from `environment_sinks`, credentials stripped.
- `adl_list_sink_types` (existing): sink type catalog.
- `adl_query_records`, `adl_query_duckdb` (existing): read prior audits, correlate.
- `adl_read_memory`, `adl_write_memory` (existing): load thresholds, persist run state.
- `adl_send_message` (existing): escalate critical findings to `executive-assistant`, `sre-devops`, `release-manager`.

**Sample output (one record from a real run):**

```json
{
  "kind": "pipeline_cost_recommendation",
  "route_id": "rt_pg_to_snowflake_orders",
  "finding_type": "high_runrate",
  "severity": "critical",
  "current_metric": "events_30d=84,000,000 sinks=2 (snowflake, kafka)",
  "projected_monthly_usd": 924.00,
  "suggested_action": "Reduce fanout: kafka sink can be replaced by Snowflake change-stream on the same target table. Estimated savings $168/mo.",
  "suggested_owner": "release-manager"
}
```

**Why Composio cannot replicate this:** the calculation depends on (a) `pipeline_event_rollups` (a SchemaBounce-managed hourly aggregation table written by the pipeline workers), (b) `environment_sinks.config` (a SchemaBounce-managed Helm-templated config blob that includes per-sink batching, retry, DLQ flags), (c) `pipeline_routes.fanout_count` (computed from `route_sink_bindings` joins). None of these are exposed by any third-party SaaS API. They are data the platform produces by running the customer's pipelines.

### 2.2 agent-cost-optimizer

**Location:** `bots/agent-cost-optimizer/`
**Default schedule:** weekly, Monday 07:00 UTC.
**Cost tier:** low (8k tokens per run).

**What it audits:**

| Finding type | Trigger |
|--------------|---------|
| `overspec_model` | Agent uses Sonnet/Opus/GPT-5, has avg output tokens below `haiku_threshold_output_tokens` (default 2000), has at least 5 completed runs in 30d, and its bot manifest does not declare `thinkLevel: high`. Recommends downgrade to Haiku or GPT-5 mini. |
| `runaway_agent` | Agent has more than `runaway_runs_per_24h` runs (default 50) AND failure rate above `runaway_failure_rate` (default 30%). Likely retry-looping. |
| `high_runrate` | Per-agent monthly cost above `runrate_warn_usd` ($20) or `runrate_critical_usd` ($100). |
| `stale_agent` | Agent enabled, zero runs in `stale_days` (default 30). Either disable or investigate. |
| `schedule_mismatch` | Agent fires more often than the data change rate of its `entityTypesRead`. Wasted runs. |

**Runtime tools it uses:**

- `adl_list_agents` (existing): enumerate active agents.
- `adl_get_agent_metrics(agent_id, windows=["24h","7d","30d"])` (new): input/output/cache/thinking tokens, estimated cost, status counts, model distribution from `agent_runs`.
- `adl_get_agent_status` (existing): current state per agent.
- `adl_query_records`, `adl_query_duckdb` (existing): read prior audits, correlate.
- `adl_read_memory`, `adl_write_memory` (existing): load `model_cost_table`, `model_downgrade_rules`, persist run state.
- `adl_send_message` (existing): escalate critical findings to `executive-assistant` and `release-manager`.

**Sample output (one record):**

```json
{
  "kind": "agent_cost_recommendation",
  "agent_id": "ag_blog_writer_001",
  "finding_type": "overspec_model",
  "severity": "warn",
  "current_metric": "model=claude-sonnet-4-6 runs_30d=46 avg_output_tokens=812 monthly_cost_usd=63.40",
  "projected_monthly_savings_usd": 50.72,
  "suggested_action": "Downgrade model to claude-haiku-4-5-20251001. Output tokens are well below the 2000-token Haiku threshold and the bot manifest declares thinkLevel: medium (not high).",
  "suggested_owner": "release-manager"
}
```

**Why Composio cannot replicate this:** `agent_runs` is the SchemaBounce per-workspace ADL pool's record of every LLM call the runtime made on the customer's behalf. It includes input tokens, output tokens, cache-read tokens, cache-write tokens, thinking tokens, model id, status, latency, and an `estimated_cost_usd` reconciled against the `model_cost_table`. No third-party API exposes this. It is data SchemaBounce produces by running the customer's agents.

## 3. The Runtime Tools That Power Them

These are the SchemaBounce-platform built-ins available to every first-party bot. They read platform-internal tables that no third-party broker has access to.

| Tool | Source | What it returns |
|------|--------|-----------------|
| `adl_list_pipeline_routes` | `schemabounce_core.pipeline_routes` | All configured routes for the workspace. |
| `adl_get_route_status(route_id)` | `pipeline_routes` + `pipeline_event_rollups` last-row | Current state, last event timestamp, error count. |
| `adl_get_route_metrics(route_id, windows[])` | `pipeline_event_rollups` (hourly aggregates) | Per-window event counts. Indexed on `(workspace_id, hour_bucket DESC)`. |
| `adl_list_workspace_sources` | `schemabounce_core.workspace_sources` | All ingest sources (CDC, SaaS, webhook, direct push). |
| `adl_list_workspace_sinks(env?, status?)` | `schemabounce_core.environment_sinks` | All sinks with operational config (DLQ presence, retry policy, batching). Credentials and KMS key IDs are stripped. |
| `adl_list_sink_types` | embedded sink-type catalog | Catalog of supported sink types and their capability flags. |
| `adl_list_agents` | `schemabounce_adl.agents` | All agents in the workspace ADL. |
| `adl_get_agent_status(agent_id)` | `agents` + `agent_runs` last-row | Current state, last run timestamp, recent error. |
| `adl_get_agent_metrics(agent_id?, windows[])` | `agent_runs` (per-workspace ADL pool) | Aggregated tokens (input/output/cache/thinking), estimated cost, status counts, model-id distribution. |
| `adl_query_records` | per-workspace ADL pool | SQL-shaped reads against the workspace's record store. |
| `adl_query_duckdb` | per-workspace ADL DuckDB attachment | Analytical queries against ADL records, useful for windowed aggregations and joins. |
| `adl_read_memory`, `adl_write_memory` | `agent_memory` | Per-bot, per-namespace key-value state. Used for thresholds, run history, override tables. |
| `adl_send_message` | `agent_messages` | Inter-bot messaging with typed payloads. |

These are what give first-party bots their range. New platform features add new tables, which add new built-ins, which the bots can compose into new findings without an SDK update.

## 4. What This Means for Customers

**Bots grow with the platform.** Every new SchemaBounce feature is a candidate for a runtime built-in. Built-ins are immediately usable by every existing first-party bot. The fleet is not a static set of integrations: it is a programming surface that expands as the platform expands.

**Bots produce real metrics.** The `projected_monthly_usd` and `projected_monthly_savings_usd` fields in recommendation records are computed from real event counts, real token counts, and operator-overridable cost tables. They are approximate (the seed values are order-of-magnitude defaults), but they are not LLM-guessed. The recommender does arithmetic on data the platform recorded.

**Bots are honest about their limits.** When the data isn't there to back a number, the bot writes a `setup_gap` record explaining what's missing instead of inventing a guess. The seed thresholds in `bots/pipeline-cost-optimizer/data-seeds/zone1-north-star.json` and `bots/agent-cost-optimizer/data-seeds/zone1-north-star.json` are explicit about which findings activate once which runtime data is available.

**Bots stay dry-run.** No first-party bot disables a route, changes a sink config, modifies a model selection, or modifies infrastructure. They write structured records that ops or `release-manager` review and act on. The decision stays human (or, on a future iteration, stays in a bot whose explicit job is to apply approved recommendations). The auditing bots never touch the things they audit.

## 5. The 12 Internal-Only-By-Design Bots

These all share the same shape as the two showcase bots: zero third-party MCP servers, all reads through runtime built-ins, all writes as structured ADL records. The `# Internal-only by design` marker in each `BOT.md` is what flips them from `none` (vaporware) to `internal-only` in the audit script.

| Bot | Reads | Writes |
|-----|-------|--------|
| **agent-cost-optimizer** | `agent_runs`, `agents` | `agent_cost_audit`, `agent_cost_recommendation` |
| **anomaly-detector** | ADL records, ADL memory | anomaly findings against workspace data |
| **atlas** | ADL graph + records | workspace-scoped mapping records |
| **blog-writer** | ADL records (drafts, schedule, owned content state) | blog drafts, publishing schedule |
| **data-quality-monitor** | ADL records | data-quality findings |
| **experiment-tracker** | ADL records (experiment state) | experiment lifecycle records |
| **infrastructure-reporter** | runtime built-ins (cross-cutting) | infra summary reports |
| **inventory-alert** | ADL records (inventory state) | inventory threshold alerts |
| **mentor-coach** | ADL memory (per-user coaching state) | coaching prompts, follow-ups |
| **pipeline-cost-optimizer** | `pipeline_event_rollups`, `environment_sinks`, `pipeline_routes` | `pipeline_route_audit`, `pipeline_cost_recommendation` |
| **platform-optimizer** | runtime built-ins (cross-cutting) | platform optimization suggestions |
| **workflow-designer** | ADL records (workflow definitions) | workflow drafts, deploy hints |

These are the canonical pattern for what SchemaBounce ships that Composio cannot. None of them have an external integration, and none of them need one. Their job is to read state the platform owns, do arithmetic against thresholds, and write actionable records back into the workspace.

## 6. How to Verify

If you want to see this end-to-end on your own workspace:

1. Activate `pipeline-cost-optimizer` from the marketplace (no OAuth, no setup: it's first-party).
2. Wait for the next weekly run, or trigger one manually from the agent management page.
3. Query the recommendations: `SELECT * FROM adl_records WHERE entity_type = 'pipeline_cost_recommendation' ORDER BY created_at DESC`.
4. Each record will have a `projected_monthly_usd` field computed from your actual `pipeline_event_rollups` data and the seed `sink_cost_table`. If your contracted rates differ, override the cost table via `adl_write_memory` namespace `bot:pipeline-cost-optimizer:northstar` key `sink_cost_table`.
5. The same flow works for `agent-cost-optimizer`: the recommendations there reference your actual `agent_runs` token counts.

No third-party API is involved. No Composio hop is involved. The data the bot reasons over is data SchemaBounce already had.

## 7. Reference

- Bot manifests: `bots/pipeline-cost-optimizer/BOT.md`, `bots/agent-cost-optimizer/BOT.md`
- Threshold seeds: `bots/pipeline-cost-optimizer/data-seeds/zone1-north-star.json`, `bots/agent-cost-optimizer/data-seeds/zone1-north-star.json`
- Runtime built-ins: `core-api/openclaw-runtime/internal/executor/tools.go`, `core-api/openclaw-runtime/internal/executor/tools_pipeline_metrics.go`
- Audit harness: `scripts/audit-bot-tooling.sh`
- Engineering handoff: `docs/AGENT_MCP_TOOLING_HANDOFF.md`
