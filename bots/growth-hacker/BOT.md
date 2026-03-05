---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: growth-hacker
  displayName: "Growth Hacker"
  version: "1.0.0"
  description: "Rapid experimentation, viral loop design, and acquisition channel optimization."
  category: marketing
  tags: ["growth", "experiments", "acquisition", "viral", "funnels", "optimization"]
agent:
  capabilities: ["analytics", "strategy"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
cost:
  estimatedTokensPerRun: 30000
  estimatedCostTier: "high"
schedule:
  default: "@daily"
  recommendations:
    light: "@every 3d"
    standard: "@daily"
    intensive: "@every 6h"
messaging:
  listensTo:
    - { type: "finding", from: ["marketing-growth"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "breakthrough experiment result or critical channel underperformance" }
data:
  entityTypesRead: ["acquisition_metrics", "campaign_results", "conversion_funnels"]
  entityTypesWrite: ["growth_experiments", "growth_findings"]
  memoryNamespaces: ["experiment_log", "channel_performance", "viral_coefficients"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["marketing"]
skills:
  - ref: "skills/ab-testing@1.0.0"
  - ref: "skills/trend-analysis@1.0.0"
automations:
  triggers:
    - entityType: "campaign_results"
      event: "created"
      prompt: "Analyze campaign ROI and recommend next action."
requirements:
  minTier: "starter"
---

# Growth Hacker

Designs rapid experiments, analyzes conversion funnels, and optimizes acquisition channels. Focuses on viral loops, referral mechanics, and data-driven growth strategies that scale.

## What It Does

- Analyzes acquisition metrics across all channels (organic, paid, referral, viral)
- Reviews campaign results to calculate ROI and identify winning patterns
- Maps conversion funnels to find drop-off points and optimization opportunities
- Designs A/B test experiments with clear hypotheses and success metrics
- Tracks viral coefficients and referral loop effectiveness
- Kills underperforming experiments fast and doubles down on winners

## Growth Experiment Format

Experiments are written as `growth_experiments` entity type records:
```json
{
  "name": "referral_incentive_test_v2",
  "hypothesis": "Offering $10 credit to both referrer and referee will increase referral rate by 25%",
  "channel": "referral",
  "status": "running",
  "metric": "referral_conversion_rate",
  "baseline": 0.032,
  "target": 0.040,
  "start_date": "2026-03-01",
  "sample_size_needed": 5000,
  "current_result": null,
  "kill_criteria": "If referral rate drops below 0.025 after 1000 samples, kill immediately"
}
```

## Escalation Behavior

- **Critical**: Channel cost exceeds 3x target CAC or viral coefficient drops below 0.5 -> finding to executive-assistant
- **High**: Experiment with 2x+ improvement confirmed statistically -> growth_findings + escalate
- **Medium**: Campaign ROI analysis complete -> growth_findings record
- **Low**: Incremental channel performance update -> channel_performance memory
