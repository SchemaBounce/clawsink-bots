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
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
  maxTokenBudget: 50000
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
  zone2Domains: ["analytics"]
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
