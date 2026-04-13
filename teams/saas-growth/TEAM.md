---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: saas-growth
  displayName: "SaaS Growth"
  version: "1.0.0"
  description: "Customer retention, sales optimization, onboarding automation, and content planning for SaaS."
  tags: ["saas", "growth", "retention", "onboarding"]
  targetMarket: "saas"
bots:
  - churn-predictor
  - sales-pipeline
  - customer-onboarding
  - content-scheduler
skills:
  - trend-analysis
  - sentiment-analysis
  - notification-dispatch
requirements:
  minTier: "starter"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Multiple bots (sales-pipeline, content-scheduler) need OAuth for external SaaS platforms"
    config:
      scopes: ["crm", "calendar", "analytics"]
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    reason: "Executive-assistant and mentor-coach bots need persistent recall across sessions"
    config:
      embedding_model: "text-embedding-3-small"
      max_results: 20
dataKits:
  - ref: "data-kits/saas@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/customer-feedback@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/content-marketing@1.0.0"
    required: false
    installSampleData: false
orgChart:
  lead: sales-pipeline
  domains:
    - name: "Sales"
      description: "Pipeline, forecast, opportunity coverage"
      head: sales-pipeline
    - name: "Customer Success"
      description: "Onboarding momentum and retention"
      head: churn-predictor
      children:
        - name: "Onboarding"
          description: "Time-to-first-value, activation milestones"
          head: customer-onboarding
    - name: "Content"
      description: "Growth-oriented content and email cadence"
      head: content-scheduler
  roles:
    - bot: sales-pipeline
      role: lead
      reportsTo: null
      domain: sales
    - bot: churn-predictor
      role: specialist
      reportsTo: sales-pipeline
      domain: customer-success
    - bot: customer-onboarding
      role: specialist
      reportsTo: sales-pipeline
      domain: customer-success
    - bot: content-scheduler
      role: specialist
      reportsTo: sales-pipeline
      domain: content
  escalation:
    critical: sales-pipeline
    unhandled: sales-pipeline
    paths:
      - name: "Churn Risk"
        trigger: "high_churn_risk"
        chain: [churn-predictor, sales-pipeline]
      - name: "Onboarding Blocker"
        trigger: "onboarding_blocked"
        chain: [customer-onboarding, sales-pipeline]
      - name: "Content Gap"
        trigger: "content_gap_detected"
        chain: [content-scheduler, sales-pipeline]
---

# SaaS Growth

A growth-focused team for SaaS companies. Predicts churn, optimizes sales pipelines, automates onboarding, and manages content scheduling.

## Included Bots

- **Churn Predictor** — CDC-triggered on user activity changes, flags at-risk accounts
- **Sales Pipeline** — Daily analysis of sales funnel and conversion rates
- **Customer Onboarding** — CDC-triggered on new customer creation
- **Content Scheduler** — Weekday content planning and scheduling

## Target Market

SaaS companies focused on retention, growth, and customer success.

For broader operational coverage, see the tiered SaaS teams:
- **[SaaS Starter](../saas-starter/)** (6 bots) — core essentials across all domains
- **[SaaS Professional](../saas-professional/)** (12 bots) — engineering, product, growth, revenue, and customer success
- **[SaaS Command Center](../saas-command-center/)** (18 bots) — full-scale operational coverage
