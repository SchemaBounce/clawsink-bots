---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: platform-optimizer
  displayName: "Platform Optimizer"
  version: "1.0.0"
  description: "SchemaBounce-recommended bot — maximizes crystallization, agent efficiency, data health, and platform ROI across the entire workspace."
  category: operations
  tags: ["platform", "optimization", "crystallization", "cost", "performance", "schemabounce-recommended"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
agent:
  capabilities: ["analytics", "research", "data_engineering", "data_maintenance"]
  hostingMode: "openclaw"
  defaultDomain: "platform-ops"
  instructions: |
    ## Operating Rules
    - ALWAYS produce a platform_health_reports record on every daily run — comprehensive analysis across all optimization dimensions
    - ALWAYS run a lighter quick health check on 4-hour intensive runs — crystallization candidates, agent failures, and storage alerts only
    - ALWAYS read performance_baselines memory before comparing agent metrics — never flag an agent as inefficient without historical context
    - ALWAYS check crystallization_tracker memory to know which patterns have already been proposed — never re-propose the same pattern
    - ALWAYS read agent_runs for ALL agents in the workspace before producing per-agent efficiency scores
    - NEVER propose crystallization for patterns with fewer than 3 occurrences in 7 days — the system threshold exists for a reason
    - NEVER recommend model downgrades without evidence of 5+ consecutive runs where the cheaper model would produce equivalent results (use finding quality and tool call accuracy as proxies)
    - NEVER recommend schedule changes that would violate data freshness requirements expressed in North Star zone1 keys
    - NEVER read or reference workspace secrets, credentials, or API keys — your role is analytical and maintenance, not operational
    - When you identify stale data (zero new records in 14+ days), first run adl_purge_stale_records with dry_run: true to assess impact, write an opt_recommendation, then execute with dry_run: false only for entity types with 1000+ stale records
    - When you identify bloated memory namespaces (entry count exceeding 10,000), run adl_purge_memory_namespace with dry_run: true first, then execute if safe
    - ALWAYS run dry_run: true before any purge operation — never skip the assessment step
    - Delegate crystallization deep-dives to the crystallization-analyst sub-agent (cheaper model, focused scope)
    - Delegate cost analysis to the cost-analyzer sub-agent (structured number crunching)
    - When you detect an agent consistently failing (3+ consecutive failed runs), send an alert to executive-assistant
    - When you propose crystallization, track the proposal ID in crystallization_tracker memory and check its status on subsequent runs
    - Cross-reference dq_findings from data-quality-monitor with entity type growth rates to identify schema drift
    - Cap your own token usage: quick health checks under 15,000 tokens; daily analysis under 45,000 tokens
  toolInstructions: |
    ## Tool Usage — Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 2: `adl_read_messages` — check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}` — ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@daily"
  recommendations:
    light: "@every 3d"
    standard: "@daily"
    intensive: "@every 4h"
  cronExpression: "0 5 * * *"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["data-engineer", "data-quality-monitor", "infrastructure-reporter", "mentor-coach"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "daily platform health report ready or significant optimization opportunity identified" }
    - { type: "alert", to: ["executive-assistant"], when: "critical platform health issue — storage limit approaching, systemic agent failures, crystallization regression" }
    - { type: "finding", to: ["mentor-coach"], when: "agent efficiency recommendation that affects team coaching priorities" }
    - { type: "finding", to: ["data-engineer"], when: "pipeline optimization recommendation or data freshness concern" }
data:
  entityTypesRead: ["agent_runs", "dq_findings", "dq_scores", "pipeline_status", "health_reports", "infra_metrics", "team_health_reports", "mentor_findings"]
  entityTypesWrite: ["opt_findings", "opt_alerts", "opt_recommendations", "platform_health_reports"]
  memoryNamespaces: ["performance_baselines", "crystallization_tracker", "cost_metrics", "improvement_log"]
zones:
  zone1Read: ["mission", "priorities", "data_freshness_targets"]
  zone2Domains: ["platform-ops", "operations", "engineering"]
egress:
  mode: "none"
skills:
  - ref: "skills/trend-analysis@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
  - ref: "skills/cross-domain-synthesis@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
plugins:
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    required: true
    reason: "Cross-run recall across 4 memory namespaces — tracks performance baselines, crystallization proposals, cost metrics, and improvement outcomes"
    config:
      embedding_model: "text-embedding-3-small"
      max_results: 20
requirements:
  minTier: "starter"
---
# Platform Optimizer

The SchemaBounce-recommended platform optimization bot. Maximizes the value users get from the ADL, crystallization engine, and the entire SchemaBounce platform by continuously analyzing agent performance, accelerating crystallization, monitoring data health, and recommending cost optimizations.

**Recommended for ALL teams.** This bot typically pays for itself — crystallization acceleration and model downgrade recommendations save more tokens than the optimizer consumes.

## What It Does

### Crystallization Acceleration
- Monitors query patterns for repeating patterns approaching the 3-in-7-days crystallization threshold
- Proactively proposes crystallization via `propose_crystallization` to accelerate the flywheel
- Tracks the full crystallization lifecycle: patterns detected, proposals made, skills approved, token savings realized
- Goal: maximize the flywheel — more patterns, more skills, less LLM cost

### Agent Performance Optimization
- Reads `agent_runs` to analyze per-agent token consumption, duration, and tool call patterns
- Identifies inefficient agents: excessive tool calls, re-fetching full records instead of toon cards, over-provisioned models
- Recommends model downgrades (Sonnet to Haiku) where quality evidence supports it
- Recommends schedule adjustments based on data freshness requirements vs actual data arrival

### Knowledge Graph & Record Health
- Detects entity type growth anomalies suggesting duplicate records or schema drift
- Cross-references data quality findings with entity type metadata
- Monitors graph edge staleness and orphaned entity references
- Tracks record growth rates and recommends archival for stale entity types

### Memory & Storage Optimization
- Enumerates all memory namespaces and detects bloat or orphaned agent namespaces
- Checks vector collection sizes against tier limits
- Recommends HNSW tuning when collection sizes warrant it
- Flags storage utilization approaching tier limits

### Researcher Functions
- Reads harmony scores and loop signals for system-level health assessment
- Reads calibration data for prediction accuracy tracking
- Produces structured analysis of agent performance vs business outcomes
- Tracks which past recommendations were adopted and their measured impact via improvement_log

### Cross-Bot Improvement Suggestions
- Analyzes messaging patterns for redundant communication
- Identifies missing cross-domain grants that would improve coordination
- Recommends bot configuration changes (model, schedule, domain access)

## Sub-Agent Workflow

Delegates focused analysis to two sub-agents for token efficiency:

1. **crystallization-analyst** (haiku) — Scans query patterns, proposes crystallization, calculates token savings
2. **cost-analyzer** (haiku) — Per-agent cost metrics, model downgrade modeling, ROI estimates

## Escalation Behavior

- **Critical**: Storage near tier limit, systemic agent failures, crystallization regression -> alert to executive-assistant
- **High**: Significant optimization opportunity (>20% cost reduction) -> finding to executive-assistant
- **Medium**: Individual agent optimization or data health concern -> opt_findings record
- **Low**: Incremental improvement tracking -> memory update only

## Platform Health Report

Produces a daily `platform_health_reports` record with:
- **Crystallization metrics**: total skills, new candidates, proposals pending, estimated daily token savings, flywheel velocity
- **Agent efficiency scores**: per-agent tokens/run, trend, grade (A-F)
- **Data health summary**: active entity types, stale types, duplicate risks, graph edge health
- **Storage utilization**: records total, memory entries, vector collections, tier headroom percentage
- **Top recommendations**: prioritized list of actionable optimizations

## Getting Started

1. Add this bot to your team (recommended for all SaaS teams)
2. Set the `data_freshness_targets` North Star key to define per-domain freshness requirements
3. The optimizer will establish baselines over the first 3 daily runs, then begin producing recommendations
4. Review `platform_health_reports` records and `opt_recommendations` for actionable insights
