---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: platform-optimizer
  displayName: "Platform Optimizer"
  version: "1.0.8"
  description: "SchemaBounce-recommended bot, maximizes crystallization, agent efficiency, data health, and platform ROI across the entire workspace."
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
    - ALWAYS produce a platform_health_reports record on every daily run, comprehensive analysis across all optimization dimensions
    - ALWAYS run a lighter quick health check on 4-hour intensive runs, crystallization candidates, agent failures, and storage alerts only
    - ALWAYS read performance_baselines memory before comparing agent metrics, never flag an agent as inefficient without historical context
    - ALWAYS check crystallization_tracker memory to know which patterns have already been proposed, never re-propose the same pattern
    - ALWAYS read agent_runs for ALL agents in the workspace before producing per-agent efficiency scores
    - NEVER propose crystallization for patterns with fewer than 3 occurrences in 7 days. The system threshold exists for a reason
    - NEVER recommend model downgrades without evidence of 5+ consecutive runs where the cheaper model would produce equivalent results (use finding quality and tool call accuracy as proxies)
    - NEVER recommend schedule changes that would violate data freshness requirements expressed in North Star zone1 keys
    - NEVER read or reference workspace secrets, credentials, or API keys, your role is analytical and maintenance, not operational
    - When you identify stale data (zero new records in 14+ days), first run adl_purge_stale_records with dry_run: true to assess impact, write an opt_recommendation, then execute with dry_run: false only for entity types with 1000+ stale records
    - When you identify bloated memory namespaces (entry count exceeding 10,000), run adl_purge_memory_namespace with dry_run: true first, then execute if safe
    - ALWAYS run dry_run: true before any purge operation, never skip the assessment step
    - Delegate crystallization deep-dives to the crystallization-analyst sub-agent (cheaper model, focused scope)
    - Delegate cost analysis to the cost-analyzer sub-agent (structured number crunching)
    - When you detect an agent consistently failing (3+ consecutive failed runs), send an alert to executive-assistant
    - When you propose crystallization, track the proposal ID in crystallization_tracker memory and check its status on subsequent runs
    - Cross-reference dq_findings from data-quality-monitor with entity type growth rates to identify schema drift
    - ALWAYS read bot_setup_status records to identify bots with incomplete setup, recommend specific setup steps that would improve bot effectiveness
    - ALWAYS read bot_goal_health records to identify underperforming bots, correlate poor goal achievement with missing setup steps or configuration issues
    - ALWAYS read run_report records to detect bots reporting "blocked" or "limited" overall status. These need immediate attention
    - When a bot consistently reports setup_issues in run_reports, write an opt_recommendation with the specific step_id and estimated impact of completing that step
    - Cap your own token usage: quick health checks under 15,000 tokens; daily analysis under 45,000 tokens
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
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
  tasks:
    - name: "Crystallization Scan"
      cronExpression: "0 5 * * *"
      timezone: "UTC"
      prompt: "Scan for crystallization opportunities. Call adl_list_query_patterns with min_occurrences=3 and days=7 to find repeating tool call patterns. Then call adl_list_crystallization_candidates with status='proposed' to see what has already been proposed. For new qualifying patterns not yet proposed, call adl_propose_crystallization with name, description, sql_body, and tier (0 for materialized views, 1 for stored functions). Track proposal IDs in crystallization_tracker memory via adl_write_memory."
    - name: "Agent Performance Review"
      cronExpression: "0 6 * * *"
      timezone: "UTC"
      prompt: "Review performance of all agents. Query adl_query_records entity_type='agent_runs' for the last 7 days. For each agent, analyze: success rate, average token usage, model cost efficiency. For agents consistently using expensive models on simple tasks (5+ runs with <2K output tokens on Sonnet/Opus), propose a model downgrade by calling adl_write_record entity_type='agent_proposal' with type='model_change', agentId, title, rationale (citing run evidence), proposedConfig (preferred model ID), estimatedImpact, and status='pending'. For agents with excessive schedule frequency relative to data change rate, create a proposal with type='schedule_change'."
    - name: "Platform Health Report"
      cronExpression: "0 7 * * *"
      timezone: "UTC"
      prompt: "Generate the daily platform health report. Aggregate: crystallization metrics (skills count, usage, token savings), agent efficiency scores (per-agent tokens/run graded A-F), data health (entity growth, staleness), storage utilization. Write to platform_health_reports entity type. Send summary to executive-assistant via adl_send_message."
    - name: "Weekly Cost Analysis"
      cronExpression: "0 9 * * 1"
      timezone: "UTC"
      prompt: "Deep dive into workspace costs. Calculate per-agent token costs for the past 7 days. Quantify crystallization savings (skill executions × estimated token savings per call). Analyze model routing effectiveness (auto vs fixed). Compare total costs to previous week. For any agent where costs could be reduced >20% with a model switch or schedule change, create an agent_proposal record with type, rationale, proposedConfig, and estimatedImpact."
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["data-engineer", "data-quality-monitor", "infrastructure-reporter", "mentor-coach", "agent-cost-optimizer"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "daily platform health report ready or significant optimization opportunity identified" }
    - { type: "alert", to: ["executive-assistant"], when: "critical platform health issue, storage limit approaching, systemic agent failures, crystallization regression" }
    - { type: "finding", to: ["mentor-coach"], when: "agent efficiency recommendation that affects team coaching priorities" }
    - { type: "finding", to: ["data-engineer"], when: "pipeline optimization recommendation or data freshness concern" }
data:
  entityTypesRead: ["agent_runs", "dq_findings", "dq_scores", "pipeline_status", "health_reports", "infra_metrics", "team_health_reports", "mentor_findings", "bot_setup_status", "bot_goal_health", "run_report"]
  entityTypesWrite: ["opt_findings", "opt_alerts", "opt_recommendations", "platform_health_reports"]
  memoryNamespaces: ["performance_baselines", "crystallization_tracker", "cost_metrics", "improvement_log"]
zones:
  zone1Read: ["mission", "priorities", "data_freshness_targets"]
  zone2Domains: ["platform-ops", "operations", "engineering"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/workflow-ops@1.0.0"
  - ref: "skills/trend-analysis@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
  - ref: "skills/cross-domain-synthesis@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
plugins:
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    required: true
    reason: "Cross-run recall across 4 memory namespaces, tracks performance baselines, crystallization proposals, cost metrics, and improvement outcomes"
    config:
      embedding_model: "text-embedding-3-small"
      max_results: 20
mcpServers: []
# Internal-only by design, first-party platform bot. Optimises this
# workspace's crystallization candidates, agent efficiency, data health,
# and platform ROI via adl_list_crystallization_candidates,
# adl_query_records, adl_get_data_stats, and adl_query_duckdb. No
# third-party MCP, no external SaaS, this bot is the canonical example
# of platform value Composio cannot replicate.
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-mission
      name: "Set workspace mission"
      description: "Business context helps prioritize which optimizations matter most"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Cannot prioritize optimizations without understanding business goals"
      ui:
        inputType: text
        placeholder: "e.g., Real-time fraud detection platform for FinTech companies"
    - id: set-priorities
      name: "Set workspace priorities"
      description: "Current priorities guide which agents and costs to focus on"
      type: north_star
      key: priorities
      group: configuration
      priority: required
      reason: "Optimization recommendations must align with business priorities"
      ui:
        inputType: text
        placeholder: "e.g., Reduce LLM costs, improve agent reliability, accelerate crystallization"
    - id: deploy-agents
      name: "Deploy at least 3 agents"
      description: "Platform optimizer needs agents to analyze, no agents means nothing to optimize"
      type: data_presence
      entityType: agent_runs
      minCount: 1
      group: data
      priority: required
      reason: "Cannot generate performance insights without agent run data"
      ui:
        actionLabel: "View Deployed Agents"
        emptyState: "No agent runs found. Deploy and run agents first."
    - id: set-freshness-targets
      name: "Set data freshness targets"
      description: "Defines acceptable data staleness thresholds per entity type"
      type: north_star
      key: data_freshness_targets
      group: configuration
      priority: recommended
      reason: "Freshness targets guide stale data purge recommendations"
      ui:
        inputType: text
        placeholder: '{"default": "7d", "agent_runs": "90d", "findings": "30d"}'
    - id: install-memory-plugin
      name: "Verify memory plugin"
      description: "LanceDB memory plugin enables cross-run recall for baseline tracking"
      type: manual
      group: external
      priority: recommended
      reason: "Performance baselines and crystallization tracking require persistent vector memory"
      ui:
        actionLabel: "I've verified the memory plugin is installed"
        instructions: "The memory-lancedb plugin should be installed automatically with the bot. Verify it appears in the agent's plugin list."
goals:
  - name: crystallization_acceleration
    description: "Identify and propose crystallization candidates from repeating patterns"
    category: primary
    metric:
      type: count
      entity: opt_recommendations
      filter: { type: "crystallization" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when qualifying patterns exist (3+ occurrences in 7 days)"
  - name: cost_optimization
    description: "Reduce workspace LLM costs through model and schedule recommendations"
    category: primary
    metric:
      type: count
      entity: opt_recommendations
      filter: { type: ["model_change", "schedule_change"] }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when optimization opportunities exist"
    feedback:
      enabled: true
      entityType: opt_recommendations
      actions:
        - { value: accepted, label: "Accepted recommendation" }
        - { value: rejected, label: "Rejected, not applicable" }
        - { value: deferred, label: "Deferred, will review later" }
  - name: health_report_delivery
    description: "Produce daily platform health reports consistently"
    category: secondary
    metric:
      type: count
      entity: platform_health_reports
    target:
      operator: ">="
      value: 1
      period: daily
  - name: recommendation_quality
    description: "Recommendations accepted by operators over time"
    category: health
    metric:
      type: rate
      numerator: { entity: opt_recommendations, filter: { feedback: "accepted" } }
      denominator: { entity: opt_recommendations, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.7
      period: monthly
  - name: improvement_tracking
    description: "Track whether recommendations lead to measurable improvements"
    category: health
    metric:
      type: count
      source: memory
      namespace: improvement_log
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---
# Platform Optimizer

The SchemaBounce-recommended platform optimization bot. Maximizes the value users get from the ADL, crystallization engine, and the entire SchemaBounce platform by continuously analyzing agent performance, accelerating crystallization, monitoring data health, and recommending cost optimizations.

**Recommended for ALL teams.** This bot typically pays for itself, crystallization acceleration and model downgrade recommendations save more tokens than the optimizer consumes.

## What It Does

### Crystallization Acceleration
- Monitors query patterns for repeating patterns approaching the 3-in-7-days crystallization threshold
- Proactively proposes crystallization via `propose_crystallization` to accelerate the flywheel
- Tracks the full crystallization lifecycle: patterns detected, proposals made, skills approved, token savings realized
- Goal: maximize the flywheel, more patterns, more skills, less LLM cost

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

1. **crystallization-analyst** (haiku), Scans query patterns, proposes crystallization, calculates token savings
2. **cost-analyzer** (haiku), Per-agent cost metrics, model downgrade modeling, ROI estimates

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
