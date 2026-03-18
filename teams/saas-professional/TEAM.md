---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: saas-professional
  displayName: "SaaS Professional"
  version: "1.0.0"
  description: "Growing SaaS operations — 12 bots covering engineering, product, growth, revenue, and customer success with deeper domain coverage"
  category: saas
  tags: ["saas", "professional", "mid-size", "engineering", "product", "growth", "revenue", "customer-success"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
requirements:
  minTier: "starter"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/sre-devops@1.0.0"
  - ref: "bots/code-reviewer@1.0.0"
  - ref: "bots/bug-triage@1.0.0"
  - ref: "bots/documentation-writer@1.0.0"
  - ref: "bots/product-owner@1.0.0"
  - ref: "bots/marketing-growth@1.0.0"
  - ref: "bots/blog-writer@1.0.0"
  - ref: "bots/sales-pipeline@1.0.0"
  - ref: "bots/customer-onboarding@1.0.0"
  - ref: "bots/churn-predictor@1.0.0"
  - ref: "bots/customer-support@1.0.0"
plugins:
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    reason: "Executive-assistant, product-owner, and sales-pipeline need cross-run recall across multiple domains"
    config:
      embedding_model: "text-embedding-3-small"
      max_results: 20
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Sales-pipeline (CRM), marketing-growth (ads/analytics), blog-writer (blog API) need OAuth"
    config:
      scopes: ["crm", "analytics", "blog"]
  - ref: "microsoft-teams@latest"
    slot: "notifications"
    reason: "Team-wide notifications for incidents, releases, and daily briefings"
    config:
      channel_mapping:
        alerts: "saas-professional-alerts"
        briefings: "saas-professional-daily"
mcpServers:
  - ref: "tools/github"
    reason: "Shared GitHub access for code-reviewer, documentation-writer, bug-triage, and blog-writer"
  - ref: "tools/slack"
    reason: "Customer support channel monitoring and community feedback"
dataKits:
  - ref: "data-kits/saas@2.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/crm-contacts@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/customer-feedback@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/content-marketing@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/project-management@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "B2B SaaS"
  context: "Growing SaaS companies needing solid coverage across engineering, product, growth, revenue, and customer success — the operational backbone for scaling from startup to established business"
  requiredKeys:
    - mission
    - industry
    - stage
    - priorities
    - tech_stack
    - sla_targets
    - product_roadmap
    - brand_voice
    - growth_targets
    - revenue_model
orgChart:
  lead: executive-assistant
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: operations
    # --- Engineering ---
    - bot: sre-devops
      role: specialist
      reportsTo: executive-assistant
      domain: engineering
    - bot: code-reviewer
      role: specialist
      reportsTo: executive-assistant
      domain: engineering
    - bot: bug-triage
      role: support
      reportsTo: code-reviewer
      domain: engineering
    - bot: documentation-writer
      role: support
      reportsTo: code-reviewer
      domain: engineering
    # --- Product ---
    - bot: product-owner
      role: specialist
      reportsTo: executive-assistant
      domain: product
    # --- Growth ---
    - bot: marketing-growth
      role: specialist
      reportsTo: executive-assistant
      domain: growth
    - bot: blog-writer
      role: support
      reportsTo: marketing-growth
      domain: growth
    # --- Revenue ---
    - bot: sales-pipeline
      role: specialist
      reportsTo: executive-assistant
      domain: revenue
    - bot: customer-onboarding
      role: support
      reportsTo: sales-pipeline
      domain: revenue
    - bot: churn-predictor
      role: support
      reportsTo: sales-pipeline
      domain: revenue
    # --- Customer Success ---
    - bot: customer-support
      role: specialist
      reportsTo: executive-assistant
      domain: customer-success
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Production Incident"
        trigger: "production_incident"
        chain: [sre-devops, executive-assistant]
      - name: "Security Vulnerability"
        trigger: "security_vulnerability"
        chain: [code-reviewer, sre-devops, executive-assistant]
      - name: "Churn Risk Escalation"
        trigger: "churn_risk_high"
        chain: [churn-predictor, customer-support, sales-pipeline, executive-assistant]
      - name: "Revenue Anomaly"
        trigger: "revenue_anomaly"
        chain: [sales-pipeline, executive-assistant]
      - name: "Content or Documentation Gap"
        trigger: "content_gap"
        chain: [documentation-writer, blog-writer, marketing-growth, executive-assistant]
      - name: "Critical Bug Detected"
        trigger: "bug_severity_critical"
        chain: [bug-triage, code-reviewer, sre-devops, executive-assistant]
      - name: "Customer Escalation"
        trigger: "customer_escalation"
        chain: [customer-support, executive-assistant]
---
# SaaS Professional

Twelve bots providing solid operational coverage for growing B2B SaaS companies: engineering reliability, code quality, bug management, documentation, product management, content marketing, sales pipeline, customer onboarding, churn prediction, customer support, and executive coordination.

## Included Bots

| Bot | Role | Domain | Schedule |
|-----|------|--------|----------|
| Executive Assistant | Team lead, daily briefings | Operations | @every 4h |
| SRE & DevOps | Infrastructure monitoring, incidents | Engineering | @every 4h |
| Code Reviewer | PR review, security scanning | Engineering | CDC on pull_requests |
| Bug Triage | Bug prioritization, duplicate detection | Engineering | @every 2h |
| Documentation Writer | Automated doc updates | Engineering | Event-triggered |
| Product Owner | Feature prioritization, roadmap | Product | @every 12h |
| Marketing Growth | Campaigns, SEO, content calendar | Growth | @daily |
| Blog Writer | Weekly technical blog posts | Growth | @weekly |
| Sales Pipeline | Funnel analysis, deal tracking | Revenue | @daily |
| Customer Onboarding | New customer setup flows | Revenue | CDC-triggered |
| Churn Predictor | Churn signals, retention actions | Revenue | CDC-triggered |
| Customer Support | Ticket triage, customer health | Customer Success | @every 2h |

## How They Work Together

The Executive Assistant leads the team as COO, coordinating across five domains. Engineering has two sub-chains: SRE & DevOps handles infrastructure while Code Reviewer oversees quality with Bug Triage and Documentation Writer as support. Product Owner aggregates feedback from Customer Support and Sales Pipeline into prioritized feature recommendations.

Marketing Growth coordinates Blog Writer for a unified content strategy. Revenue bots work as a pipeline: Sales Pipeline leads with Customer Onboarding (activation) and Churn Predictor (retention). Customer Support operates independently, routing findings to Product Owner and SRE & DevOps as needed.

**Communication flow:**
- Executive Assistant coordinates across all domains -> request to all specialists
- SRE & DevOps detects incident -> alert to Executive Assistant
- Code Reviewer detects security issue -> finding to SRE & DevOps, Executive Assistant
- Bug Triage flags release blocker -> alert to Executive Assistant
- Documentation Writer detects doc gap -> alert to Marketing Growth
- Product Owner prioritizes feature -> finding to Executive Assistant
- Marketing Growth reports campaign metrics -> finding to Executive Assistant
- Blog Writer completes draft -> finding to Marketing Growth
- Sales Pipeline forecasts revenue -> finding to Executive Assistant
- Customer Onboarding reports blocker -> finding to Customer Support
- Churn Predictor flags at-risk account -> alert to Sales Pipeline, Customer Support
- Customer Support routes feature requests -> finding to Product Owner
- Customer Support escalates critical issue -> alert to Executive Assistant

## Upgrading

For full operational coverage including DevRel, market intelligence, revenue operations, API testing, uptime management, and business analytics, consider the **[SaaS Command Center](../saas-command-center/)** (18 bots).

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `mission`, `industry`, `stage`, `priorities`, `tech_stack`, `sla_targets`, `product_roadmap`, `brand_voice`, `growth_targets`, `revenue_model`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's daily briefings for a consolidated operational view across all domains
