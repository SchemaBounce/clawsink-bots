---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: agent-cost-optimizer
  displayName: "Agent Cost Optimizer"
  version: "0.1.1"
  description: "First-party platform bot. Audits per-agent token usage, model spend, and run patterns to surface concrete cost-saving recommendations — model downgrades, schedule reductions, runaway-agent detection. Uses only SchemaBounce-platform built-in tools — no third-party MCP, no Composio in the data path."
  category: ops
  tags: ["agents", "cost", "ops", "optimization", "platform", "tokens"]
agent:
  capabilities: ["audit", "analysis", "recommendation"]
  hostingMode: "openclaw"
  defaultDomain: "ops"
  instructions: |
    ## Operating Rules
    - You are a FIRST-PARTY platform bot. You read the workspace's own agent_runs and agent state via the runtime built-ins (adl_list_agents, adl_get_agent_metrics, adl_get_agent_status, adl_query_records, adl_query_duckdb). You do NOT call any third-party MCP. You do NOT use Composio. You do NOT make raw HTTP.
    - Every run produces at least one actionable agent_cost_recommendation OR an explicit "no actionable findings" record with the metrics that justify the conclusion. "Looks fine" is not a finding — back it with the numbers.
    - Recommendations are ALWAYS dry-run: you write structured records that ops or release-manager review and act on. You never disable an agent, change a model, or modify schedule yourself.
    - When a finding has severity="critical" (e.g., agent costing > $200/mo with usage that fits a Haiku-tier workload), message executive-assistant immediately so ops sees it without waiting for the next dashboard refresh.
    - Use real numbers. If estimated_cost_usd is null on agent_runs (older runs predating cost reconciliation), back-of-envelope from token counts × model_cost_table — and note the estimation method in current_metric.
    - Honest scope: this bot improves cost visibility and surfaces optimisation candidates. Actually applying the optimisations stays a human decision (or release-manager bot's job).
  toolInstructions: |
    ## Tool Usage
    - Step 1: `adl_read_memory` namespace `bot:agent-cost-optimizer:northstar` keys `cost_thresholds`, `model_cost_table`, `model_downgrade_rules`
    - Step 2: `adl_read_memory` namespace `cost:agents:run_state` key `last_run` to know which agents were already flagged in the prior run (avoid duplicate noise)
    - Step 3: Spawn `analyzer` sub-agent. The analyzer enumerates every active agent via `adl_list_agents`, then for each calls `adl_get_agent_metrics(agent_id, windows=["24h","7d","30d"])` + `adl_get_agent_status` for current state. Emits one `agent_cost_audit` record per agent plus a workspace rollup.
    - Step 4: Spawn `recommender` sub-agent. The recommender reads the freshly-written audits via `adl_query_records`, applies model_downgrade_rules + cost_thresholds, and emits `agent_cost_recommendation` records with `projected_monthly_savings_usd`.
    - Step 5: For every recommendation with severity="critical", `adl_send_message` to `executive-assistant` type=`finding` payload=`{recommendation_id, agent_id, projected_monthly_savings_usd, suggested_action}`.
    - Step 6: For recommendations whose `suggested_owner == "release-manager"` (model downgrade, schedule change, agent disable), `adl_send_message` to `release-manager` type=`request`.
    - Step 7: `adl_write_memory` namespace `cost:agents:run_state` key `last_run` with `{run_at, audits_written, recommendations_written, by_severity, by_finding_type, total_projected_monthly_savings_usd, current_monthly_run_rate_usd}`
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
  maxTokenBudget: 12000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@weekly"
  recommendations:
    light: "@monthly"
    standard: "@weekly"
    intensive: "0 6 * * 1,3,5"
  cronExpression: "0 7 * * 1"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "release-manager", "platform-optimizer"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "critical agent cost finding requires action" }
    - { type: "request", to: ["release-manager"], when: "recommendation requires a model, schedule, or enabled-state change" }
    - { type: "finding", to: ["platform-optimizer"], when: "workspace-level cost summary is ready for the platform health roll-up" }
data:
  entityTypesRead: ["agent_cost_audit", "agent_cost_recommendation", "agent_proposal"]
  entityTypesWrite: ["agent_cost_audit", "agent_cost_recommendation"]
  memoryNamespaces: ["cost:agents:cache", "cost:agents:run_state"]
zones:
  zone1Read: ["cost_thresholds", "model_cost_table", "model_downgrade_rules", "company_glossary"]
  zone2Domains: ["ops"]
presence:
  email:
    required: false
  web:
    search: false
    browsing: false
    crawling: false
egress:
  mode: "none"
plugins: []
mcpServers: []
# This bot is intentionally first-party only. It uses adl_* runtime built-ins
# that already live in the OpenCLAW dispatcher — adl_get_agent_metrics
# specifically queries schemabounce_adl.agent_runs in the workspace's ADL
# pool. No Composio, no external SaaS. The differentiator: only SchemaBounce
# can ship this bot because only SchemaBounce hosts the agent runtime that
# generates the data this bot reads.
requirements:
  minTier: "starter"
goals:
  - name: recommendations_per_run
    description: "Each run produces at least one actionable agent cost recommendation, or an explicit 'no findings' record with metrics."
    category: primary
    metric:
      type: count
      entity: agent_cost_recommendation
    target:
      operator: ">="
      value: 1
      period: per_run
  - name: critical_recommendation_routing
    description: "Every critical recommendation is messaged to executive-assistant in the same run."
    category: routing
    metric:
      type: ratio
      numerator: critical_messages_sent
      denominator: critical_recommendations
    target:
      operator: "=="
      value: 1
      period: per_run
  - name: dry_run_only
    description: "Never modifies agent configuration directly; recommendations only."
    category: health
    metric:
      type: boolean
      check: "no_agent_mutations"
    target:
      operator: "=="
      value: 1
      period: per_run
---

# Agent Cost Optimizer

Audits this workspace's agents for token-usage and cost-efficiency anti-patterns. Reads exclusively from SchemaBounce platform tools — no third-party MCP servers, no Composio in the data path.

## What It Does

- **Per-agent audit:** for every enabled agent, captures token usage by window (24h / 7d / 30d), model used, run count, completed/failed/running counts, failure rate, average output tokens, and estimated cost USD into an `agent_cost_audit` record.
- **Real monthly run-rate per agent:** uses `adl_get_agent_metrics` 30-day estimated_cost_usd × (30 / window_days) to project monthly cost. Surfaces agents whose projected monthly cost exceeds tier thresholds.
- **Model-downgrade detection:** agents using a high-tier model (e.g., Sonnet, Opus) with consistently low output tokens (avg < 2k for 5+ runs) get a downgrade recommendation. Cites the model_cost_table delta.
- **Runaway-agent detection:** agents with high run_count + high failure_rate are likely retry-looping. Critical finding routed to release-manager.
- **Stale-agent detection:** agents enabled but with zero runs in 30d → suggest disabling.
- **Schedule mismatch:** agents firing more frequently than their data change rate (cross-referenced with `entityTypesRead` mutation rate from `adl_get_data_stats`) → suggest reducing cadence.
- **Workspace cost summary:** aggregates total monthly_run_rate_usd, top-3 most-expensive agents, top-3 fastest-growing agents (week-over-week cost delta), and total potential savings if all recommendations applied.
- **Recommendations:** `agent_cost_recommendation` records with `{agent_id, finding_type, severity, current_metric, projected_monthly_savings_usd, suggested_action, suggested_owner}`.
- **Critical routing:** any `severity="critical"` recommendation is messaged to `executive-assistant` in the same run.

## What It Does NOT Do

- Does not disable, modify, or delete any agent. Recommendations are dry-run only.
- Does not call any external API. The data is the workspace's own agent_runs.
- Does not invent numbers — every recommendation cites the actual metric that justifies it. If `model_cost_table` lacks an entry for a model used by an agent, the bot writes a `cost_data_missing` recommendation instead of guessing.
- Does not make individual-agent coaching recommendations (model = right size for task quality, schedule = right cadence for business need). That's mentor-coach's job. This bot focuses on cost-efficiency anti-patterns where the answer is unambiguous.

## Sub-Agents

| Agent | Model | Responsibility |
|-------|-------|----------------|
| **analyzer** | Haiku 4.5 | Walks every active agent. Captures `agent_cost_audit` records with token + cost signals from agent_runs. |
| **recommender** | Sonnet 4.6 | Reads the fresh audits, applies model_cost_table + downgrade_rules, emits `agent_cost_recommendation` records with concrete actions and projected savings. |

## Why This Bot Matters

Every workspace's first cost question is "where am I spending tokens?". This bot answers it with concrete dollar figures and actionable downgrade paths. Pairs with pipeline-cost-optimizer to give ops a complete cost surface (pipeline events + agent runs).

Composio cannot ship this — Composio doesn't run the agent runtime; we do. The data this bot reads (schemabounce_adl.agent_runs) is unique to SchemaBounce-hosted agents.

## Required North Star Keys

- `cost_thresholds` — monthly_run_rate warning + critical levels per agent, runaway-agent failure-rate threshold
- `model_cost_table` — cost-per-million-tokens by model. Used to project monthly savings on downgrade recommendations.
- `model_downgrade_rules` — when to suggest moving an agent to a cheaper model (avg output tokens, think_level requirements, etc.)
- `company_glossary` — canonical terms

## Run Cadence

- **Default**: weekly (Mondays 07:00 UTC)
- **Light**: monthly (small workspaces with few agents)
- **Intensive**: Mon/Wed/Fri 06:00 UTC (production workspaces with high agent throughput)

Triggered manually via the agent chat for ad-hoc investigations.
