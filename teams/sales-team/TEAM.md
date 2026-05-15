---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: sales-team
  displayName: "Sales"
  version: "1.0.0"
  description: "End-to-end sales automation covering pipeline management, revenue operations, market intelligence, and growth hacking"
  domain: sales
  category: sales
  tags: ["sales", "pipeline", "revops", "crm", "market-intelligence", "growth"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/sales-pipeline@1.0.0"
  - ref: "bots/revops@1.0.0"
  - ref: "bots/market-intelligence@1.0.0"
  - ref: "bots/growth-hacker@1.0.0"
dataKits:
  - ref: "data-kits/sales@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Sales"
  context: "Sales team managing pipeline, revenue operations, market and competitive intelligence, and growth experiments"
  requiredKeys:
    - quota_targets
    - icp_definition
    - sales_process_stages
    - competitive_landscape
    - crm_hygiene_standards
orgChart:
  lead: sales-pipeline
  domains:
    - name: "Pipeline"
      description: "Deal progression, forecast management, rep coaching, and CRM hygiene"
      head: sales-pipeline
    - name: "Revenue Operations"
      description: "Process optimization, tooling, analytics, and sales-marketing alignment"
      head: revops
    - name: "Intelligence"
      description: "Competitive analysis, market signals, and buyer intent monitoring"
      head: market-intelligence
    - name: "Growth"
      description: "Outbound experiments, growth playbooks, and new channel development"
      head: growth-hacker
  roles:
    - bot: sales-pipeline
      role: lead
      reportsTo: null
      domain: pipeline
    - bot: revops
      role: specialist
      reportsTo: sales-pipeline
      domain: revenue-operations
    - bot: market-intelligence
      role: specialist
      reportsTo: sales-pipeline
      domain: intelligence
    - bot: growth-hacker
      role: specialist
      reportsTo: sales-pipeline
      domain: growth
  escalation:
    critical: sales-pipeline
    unhandled: sales-pipeline
    paths:
      - name: "Forecast Risk"
        trigger: "forecast_coverage_below_threshold"
        chain: [sales-pipeline, revops]
      - name: "Competitor Win"
        trigger: "deal_lost_to_competitor"
        chain: [market-intelligence, sales-pipeline]
      - name: "Stale Pipeline Alert"
        trigger: "pipeline_stale_deals_high"
        chain: [sales-pipeline, revops]
      - name: "Growth Experiment Failure"
        trigger: "growth_experiment_negative_result"
        chain: [growth-hacker, sales-pipeline]
---
# Sales

Four bots covering the full sales function: pipeline and deal management, revenue operations, competitive and market intelligence, and growth experiments.

## Included Bots

| Bot | Role | Focus |
|-----|------|-------|
| Sales Pipeline | Lead, pipeline | Deal progression, forecast, CRM hygiene, rep coordination |
| RevOps | Specialist, revenue operations | Process design, tooling, analytics, sales-marketing alignment |
| Market Intelligence | Specialist, intelligence | Competitive research, market signals, and buyer intent |
| Growth Hacker | Specialist, growth | Outbound experiments, new channel tests, growth playbooks |

## How They Work Together

Sales Pipeline is the central coordinator, owning the forecast and deal review process. RevOps monitors process adherence, CRM hygiene, and tooling health - surfacing systemic issues rather than deal-level problems. Market Intelligence feeds competitive context into active deals and flags trigger events (funding rounds, job postings, competitor price changes) that indicate buying intent. Growth Hacker runs time-boxed outbound experiments and reports results back to Sales Pipeline for adoption decisions.

**Communication flow:**
- Market Intelligence detects a funding round at a target account -> alert to Sales Pipeline
- Market Intelligence finds competitor price increase -> briefing to Sales Pipeline and Growth Hacker
- RevOps detects forecast coverage below threshold -> alert to Sales Pipeline
- RevOps identifies CRM hygiene issues -> finding to Sales Pipeline
- Growth Hacker completes an experiment -> findings report to Sales Pipeline and RevOps
- Sales Pipeline reviews weekly forecast -> briefing to all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `quota_targets`, `icp_definition`, `sales_process_stages`, `competitive_landscape`, `crm_hygiene_standards`
3. Bots begin running on their default schedules automatically
4. Check Sales Pipeline's weekly forecast briefing for pipeline health status
