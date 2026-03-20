---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: experiment-tracker
  displayName: "Experiment Tracker"
  version: "1.0.0"
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
    ## Tool Usage
    - Query `experiments` records to list all active experiments with their variant definitions, start dates, and target metrics
    - Query `experiment_metrics` to pull per-variant sample sizes, conversion counts, and continuous metric values for statistical tests
    - Query `conversion_funnels` to detect funnel-stage drop-offs and novelty effects across experiment variants
    - Write `experiment_results` with fields: experiment_id, variant_a_n, variant_b_n, p_value, effect_size, confidence_interval_lower, confidence_interval_upper, test_type (chi_squared/t_test/fisher), recommendation (ship/kill/continue)
    - Write `experiment_recommendations` with fields: experiment_id, recommendation, reasoning, risk_factors, novelty_check_passed (bool), days_running
    - Use `experiment_log` memory namespace to persist per-experiment state: last_checked_date, previous_p_value, sample_size_at_last_check, peek_count
    - Use `significance_thresholds` memory namespace to store per-experiment custom thresholds if they differ from the global North Star default
    - Use `winning_patterns` memory namespace to store historical winning variant characteristics for novelty-effect detection across experiments
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
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
  - ref: "skills/ab-testing@1.0.0"
automations:
  triggers:
    - name: "Re-evaluate experiment significance"
      entityType: "experiments"
      eventType: "updated"
      targetAgent: "self"
      promptTemplate: "Re-evaluate statistical significance for this experiment. Check sample size, calculate p-value, and update recommendation if threshold met."
requirements:
  minTier: "starter"
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
