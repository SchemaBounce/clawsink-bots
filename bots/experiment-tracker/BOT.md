---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: experiment-tracker
  displayName: "Experiment Tracker"
  version: "1.0.6"
  description: "A/B experiment monitoring, statistical analysis, and ship/kill recommendations."
  category: analytics
  tags: ["experiments", "ab-testing", "statistics", "conversion", "growth"]
agent:
  capabilities: ["analytics", "statistics"]
  hostingMode: "openclaw"
  defaultDomain: "analytics"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star keys `significance_level` (default: 0.05) and `minimum_sample_size` before evaluating any experiment
    - ALWAYS require BOTH p < significance_level AND minimum sample size met before declaring a winner -- never call significance early
    - ALWAYS report confidence intervals alongside point estimates -- bare p-values are insufficient
    - NEVER recommend shipping a variant without checking for novelty effects (lift decay over 7+ days in `winning_patterns` memory)
    - NEVER let experiments run past 4 weeks without reaching significance -- flag for kill consideration to product-owner
    - Escalate significant negative results (user harm) to product-owner (type=finding) immediately -- do not wait for the next scheduled run
    - Send ship/kill/continue recommendations and weekly summaries to product-owner and executive-assistant (type=finding)
    - Consume requests from product-owner, growth-hacker, and executive-assistant and process them before routine analysis
    - Apply Bonferroni correction when evaluating experiments that have been peeked at before reaching planned sample size
    - This bot has egress mode=none -- all statistical analysis uses data within ADL records and memory only
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
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 6h"
messaging:
  listensTo:
    - { type: "request", from: ["product-owner", "growth-hacker", "executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["product-owner", "executive-assistant"], when: "experiment reaches statistical significance or recommendation changes" }
data:
  entityTypesRead: ["experiments", "experiment_metrics", "conversion_funnels"]
  entityTypesWrite: ["experiment_results", "experiment_recommendations"]
  memoryNamespaces: ["experiment_log", "significance_thresholds", "winning_patterns"]
zones:
  zone1Read: ["mission", "significance_level", "minimum_sample_size"]
  zone2Domains: ["analytics", "product"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/ab-testing@1.0.0"
plugins: []
mcpServers: []
# Internal-only by design, first-party platform bot. Reads experiment
# records via adl_query_records and runs statistical analysis with
# adl_query_duckdb. No third-party MCP, no external SaaS.
automations:
  triggers:
    - name: "Re-evaluate experiment significance"
      entityType: "experiments"
      eventType: "updated"
      targetAgent: "self"
      promptTemplate: "Re-evaluate statistical significance for this experiment. Check sample size, calculate p-value, and update recommendation if threshold met."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-significance-level
      name: "Set significance level"
      description: "Configure the p-value threshold for declaring experiment winners (default: 0.05)."
      type: north_star
      group: configuration
      priority: required
      reason: "The bot reads North Star key significance_level before every evaluation. Without it, defaults to 0.05 but explicit setting ensures team alignment."
      ui:
        key: "significance_level"
    - id: set-minimum-sample-size
      name: "Set minimum sample size"
      description: "Configure the minimum number of observations per variant before significance can be declared."
      type: north_star
      group: configuration
      priority: required
      reason: "The bot requires BOTH p < threshold AND minimum sample size met. This prevents premature winner declarations."
      ui:
        key: "minimum_sample_size"
    - id: seed-experiments
      name: "Create experiment records"
      description: "Seed at least one experiments record with variant definitions, metric targets, and start date."
      type: data_presence
      group: data
      priority: required
      reason: "The bot queries experiments records to know which A/B tests to evaluate. Without them, it has nothing to analyze."
      ui:
        entityType: "experiments"
        minCount: 1
    - id: seed-experiment-metrics
      name: "Feed experiment metrics"
      description: "Ensure experiment_metrics records are flowing in from your analytics pipeline with per-variant conversion data."
      type: data_presence
      group: data
      priority: required
      reason: "Statistical calculations require ongoing metric data per variant. The bot cannot compute significance without observations."
      ui:
        entityType: "experiment_metrics"
        minCount: 10
    - id: set-north-star-mission
      name: "Define North Star mission"
      description: "Set the workspace mission so the bot understands business context for experiment prioritization."
      type: north_star
      group: configuration
      priority: recommended
      reason: "Mission context helps the bot prioritize which experiments get flagged first and weight business impact in recommendations."
      ui:
        key: "mission"
    - id: verify-product-owner-active
      name: "Ensure Product Owner bot is active"
      description: "Ship/kill recommendations are sent to product-owner. Confirm that bot is deployed to receive them."
      type: manual
      group: external
      priority: recommended
      reason: "Experiment recommendations route to product-owner for decision-making. Without it, recommendations go unprocessed."
      ui:
        instructions: "Deploy the product-owner bot from the marketplace, or confirm it is already active in your workspace."
goals:
  - id: experiments-evaluated
    name: "Experiments evaluated"
    description: "Number of active experiments with up-to-date significance calculations."
    metricType: count
    target: "> 0 per run"
    category: primary
    feedback:
      question: "Are the ship/kill recommendations aligned with your business judgment?"
      options: ["yes", "mostly", "too conservative", "too aggressive"]
  - id: significance-accuracy
    name: "Significance accuracy"
    description: "Percentage of shipped experiments that maintained their lift after 30 days (no novelty effect regression)."
    metricType: rate
    target: "> 75%"
    category: primary
    feedback:
      question: "Did shipped experiments maintain their predicted lift in production?"
      options: ["yes", "partially", "no - novelty effect", "not enough data yet"]
  - id: stale-experiment-detection
    name: "Stale experiment detection"
    description: "Experiments running past 4 weeks without significance are flagged for kill consideration."
    metricType: boolean
    target: "true"
    category: health
  - id: recommendation-timeliness
    name: "Recommendation timeliness"
    description: "Ship/kill recommendations are generated within one run cycle of reaching significance."
    metricType: threshold
    target: "< 24 hours"
    category: primary
---

# Experiment Tracker

Monitors running A/B experiments, calculates statistical significance, and recommends ship or kill decisions. Runs daily to catch experiments that reach significance as early as possible.

## What It Does

- Monitors all active A/B experiments and their metric streams
- Calculates statistical significance using frequentist methods (chi-squared, t-test)
- Recommends ship, kill, or continue based on p-value and sample size thresholds
- Tracks conversion funnels and detects novelty effects
- Warns when experiments run too long without reaching significance

## Escalation Behavior

- **Critical**: Experiment causing negative user impact (significant drop) -> finding to product-owner
- **High**: Experiment reached significance, ready for ship/kill decision -> finding to product-owner
- **Medium**: Experiment approaching minimum sample size -> logged as experiment_results
- **Low**: Routine daily metric collection -> memory update only

## Recommended Setup

Set these North Star keys:
- `significance_level` -- p-value threshold (default: 0.05)
- `minimum_sample_size` -- Minimum observations per variant before calling significance
