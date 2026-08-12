---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: sales-team
  displayName: "Sales"
  version: "1.0.3"
  description: "Sales automation covering ranked demand acquisition, pipeline management, revenue operations, market intelligence, and growth experiments"
  domain: sales
  category: sales
  tags: ["sales", "lead-generation", "pipeline", "revops", "crm", "market-intelligence", "growth"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/sales-pipeline@1.0.0"
  - ref: "bots/revops@1.0.0"
  - ref: "bots/market-intelligence@1.0.0"
  - ref: "bots/growth-hacker@1.0.0"
  - ref: "bots/demand-signal-scout@1.0.7"
dataKits:
  - ref: "data-kits/sales@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Sales"
  context: "Sales team finding qualified demand and managing pipeline, revenue operations, market intelligence, and growth experiments"
  requiredKeys:
    - quota_targets
    - icp_definition
    - sales_process_stages
    - competitive_landscape
    - crm_hygiene_standards
    - conversion_url
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
    - name: "Demand Acquisition"
      description: "Public buying-intent discovery, qualification, approval-gated engagement, and conversion attribution"
      head: demand-signal-scout
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
    - bot: demand-signal-scout
      role: specialist
      reportsTo: sales-pipeline
      domain: demand-acquisition
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
      - name: "Qualified Demand Signal"
        trigger: "qualified_demand_signal"
        chain: [demand-signal-scout, sales-pipeline]
---
# Sales

Five bots covering demand discovery, pipeline and deal management, revenue operations, competitive and market intelligence, and growth experiments.

## Included Bots

| Bot | Role | Focus |
|-----|------|-------|
| Sales Pipeline | Lead, pipeline | Deal progression, forecast, CRM hygiene, rep coordination |
| RevOps | Specialist, revenue operations | Process design, tooling, analytics, sales-marketing alignment |
| Market Intelligence | Specialist, intelligence | Competitive research, market signals, and buyer intent |
| Growth Hacker | Specialist, growth | Outbound experiments, new channel tests, growth playbooks |
| Demand Signal Scout | Specialist, demand acquisition | Public buying-intent discovery, qualification, approval-gated engagement, conversion attribution |

## How They Work Together

Sales Pipeline is the central coordinator, owning the forecast and deal review process. RevOps monitors process adherence, CRM hygiene, and tooling health - surfacing systemic issues rather than deal-level problems. Market Intelligence feeds competitive context into active deals and flags trigger events (funding rounds, job postings, competitor price changes) that indicate buying intent. Growth Hacker runs time-boxed outbound experiments and reports results back to Sales Pipeline for adoption decisions.

Demand Signal Scout combines configured public sources, owned-channel questions, first-party forms, and read-only CRM activity into one ranked daily acquisition queue. It deduplicates and scores signals, parks useful public replies for human approval, recommends content from repeated questions, and measures explicit engagement and pipeline outcomes. It does not create contact records from public profiles.

**Communication flow:**
- Market Intelligence detects a funding round at a target account -> alert to Sales Pipeline
- Market Intelligence finds competitor price increase -> briefing to Sales Pipeline and Growth Hacker
- RevOps detects forecast coverage below threshold -> alert to Sales Pipeline
- RevOps identifies CRM hygiene issues -> finding to Sales Pipeline
- Growth Hacker completes an experiment -> findings report to Sales Pipeline and RevOps
- Demand Signal Scout qualifies a public buying signal -> finding to Sales Pipeline and approval-gated reply action
- Demand Signal Scout ranks public, CRM, form, and content signals -> daily acquisition queue to Sales Pipeline
- Demand Signal Scout detects a repeated question -> content opportunity for Marketing Growth
- Sales Pipeline reviews weekly forecast -> briefing to all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `quota_targets`, `icp_definition`, `sales_process_stages`, `competitive_landscape`, `crm_hygiene_standards`, `conversion_url`
3. Bots begin running on their default schedules automatically
4. Check Sales Pipeline's weekly forecast briefing for pipeline health status
