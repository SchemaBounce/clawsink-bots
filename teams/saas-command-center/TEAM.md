---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: saas-command-center
  displayName: "SaaS Command Center"
  version: "1.0.0"
  description: "Run your entire SaaS company at scale — 19 bots covering engineering, product, growth, revenue, customer success, and platform optimization under unified coordination"
  category: saas
  tags: ["saas", "scale", "full-stack", "engineering", "growth", "revenue", "product", "customer-success", "flagship"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
requirements:
  minTier: "team"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/sre-devops@1.0.0"
  - ref: "bots/api-tester@1.0.0"
  - ref: "bots/bug-triage@1.0.0"
  - ref: "bots/code-reviewer@1.0.0"
  - ref: "bots/documentation-writer@1.0.0"
  - ref: "bots/blog-writer@1.0.0"
  - ref: "bots/marketing-growth@1.0.0"
  - ref: "bots/sales-pipeline@1.0.0"
  - ref: "bots/customer-onboarding@1.0.0"
  - ref: "bots/churn-predictor@1.0.0"
  - ref: "bots/product-owner@1.0.0"
  - ref: "bots/business-analyst@1.0.0"
  - ref: "bots/customer-support@1.0.0"
  - ref: "bots/devrel@1.0.0"
  - ref: "bots/market-intelligence@1.0.0"
  - ref: "bots/revops@1.0.0"
  - ref: "bots/uptime-manager@1.0.0"
  - ref: "bots/platform-optimizer@1.0.0"
plugins:
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    reason: "Executive-assistant, business-analyst, and product-owner read 20+ entity types across all domains; heavy cross-run recall required"
    config:
      embedding_model: "text-embedding-3-small"
      max_results: 25
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Multiple bots need OAuth: sales-pipeline (CRM), marketing-growth (ads), blog-writer (blog API), devrel (GitHub/Discord)"
    config:
      scopes: ["crm", "analytics", "blog", "social", "community"]
  - ref: "microsoft-teams@latest"
    slot: "notifications"
    reason: "Team-wide notifications for incidents, releases, revenue alerts, and daily briefings"
    config:
      channel_mapping:
        alerts: "saas-command-center-alerts"
        briefings: "saas-command-center-daily"
        incidents: "engineering-incidents"
  - ref: "n8n-workflow@latest"
    slot: "workflow"
    reason: "Automated workflows for incident response, onboarding sequences, and release coordination"
    config:
      webhook_triggers: true
      workflow_templates: ["incident-response", "customer-onboarding", "release"]
mcpServers:
  - ref: "tools/github"
    reason: "Shared GitHub access for code-reviewer, documentation-writer, bug-triage, devrel, and blog-writer"
  - ref: "tools/slack"
    reason: "Community channel monitoring for devrel and customer-support"
  - ref: "tools/stripe"
    reason: "Revenue data for revops and sales-pipeline"
dataKits:
  - ref: "data-kits/saas@2.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/it-operations@1.0.0"
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
  - ref: "data-kits/financial-ops@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "B2B SaaS"
  context: "SaaS companies needing comprehensive operational coverage across engineering, product, growth, revenue, and customer success — the full command center for running a software business"
  requiredKeys:
    - mission
    - industry
    - stage
    - priorities
    - tech_stack
    - sla_targets
    - product_roadmap
    - brand_voice
    - product_catalog
    - growth_targets
    - documentation_standards
    - revenue_model
    - community_platforms
    - status_page_url
orgChart:
  lead: executive-assistant
  domains:
    - name: "Technology"
      description: "Platform reliability, code quality, and internal developer experience"
      head: sre-devops
      children:
        - name: "Engineering"
          description: "Build, review, test, and document product code"
          head: code-reviewer
        - name: "Reliability"
          description: "SRE/DevOps, uptime monitoring, incident response"
          head: uptime-manager
        - name: "Platform Ops"
          description: "Cost, performance, and infrastructure optimization"
          head: platform-optimizer
    - name: "Growth & Revenue"
      description: "Top-of-funnel through expansion — marketing, sales, retention"
      head: marketing-growth
      children:
        - name: "Growth"
          description: "Demand generation, content, dev relations, competitive intel"
          head: marketing-growth
        - name: "Revenue"
          description: "Sales pipeline, onboarding, churn, RevOps"
          head: sales-pipeline
    - name: "Product"
      description: "Roadmap, discovery, and business analytics"
      head: product-owner
    - name: "Customer Success"
      description: "Support triage, community engagement, satisfaction"
      head: customer-support
    - name: "Operations"
      description: "Executive oversight and cross-domain coordination"
      head: executive-assistant
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
    - bot: api-tester
      role: support
      reportsTo: sre-devops
      domain: engineering
    - bot: uptime-manager
      role: support
      reportsTo: sre-devops
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
    - bot: business-analyst
      role: support
      reportsTo: product-owner
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
    - bot: devrel
      role: support
      reportsTo: marketing-growth
      domain: growth
    - bot: market-intelligence
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
    - bot: revops
      role: support
      reportsTo: sales-pipeline
      domain: revenue
    # --- Customer Success ---
    - bot: customer-support
      role: specialist
      reportsTo: executive-assistant
      domain: customer-success
    # --- Platform ---
    - bot: platform-optimizer
      role: specialist
      reportsTo: executive-assistant
      domain: platform-ops
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Production Incident"
        trigger: "production_incident"
        chain: [uptime-manager, sre-devops, executive-assistant]
      - name: "Security Vulnerability"
        trigger: "security_vulnerability"
        chain: [code-reviewer, sre-devops, executive-assistant]
      - name: "Churn Risk Escalation"
        trigger: "churn_risk_high"
        chain: [churn-predictor, customer-support, sales-pipeline, executive-assistant]
      - name: "Revenue Anomaly"
        trigger: "revenue_anomaly"
        chain: [revops, sales-pipeline, executive-assistant]
      - name: "Content or Documentation Gap"
        trigger: "content_gap"
        chain: [documentation-writer, blog-writer, marketing-growth, executive-assistant]
      - name: "Critical Bug Detected"
        trigger: "bug_severity_critical"
        chain: [bug-triage, code-reviewer, sre-devops, executive-assistant]
      - name: "Community Crisis"
        trigger: "community_crisis"
        chain: [devrel, marketing-growth, executive-assistant]
      - name: "SLA Breach Risk"
        trigger: "sla_breach_risk"
        chain: [uptime-manager, sre-devops, customer-support, executive-assistant]
      - name: "Market Threat"
        trigger: "market_threat_detected"
        chain: [market-intelligence, product-owner, executive-assistant]
      - name: "Platform Health Degradation"
        trigger: "platform_health_critical"
        chain: [platform-optimizer, executive-assistant]
---
# SaaS Command Center

Eighteen bots providing complete operational coverage for B2B SaaS companies: engineering reliability, code quality, product management, content marketing, developer relations, sales pipeline, revenue operations, customer success, and executive coordination — all under a single unified team with cross-domain escalation.

## Included Bots

| Bot | Role | Domain | Schedule |
|-----|------|--------|----------|
| Executive Assistant | Team lead, daily briefings | Operations | @every 4h |
| SRE & DevOps | Infrastructure monitoring, incidents | Engineering | @every 4h |
| API Tester | API validation, regression detection | Engineering | @daily |
| Uptime Manager | Status page, SLA tracking, postmortems | Engineering | @every 2h |
| Code Reviewer | PR review, security scanning | Engineering | CDC on pull_requests |
| Bug Triage | Bug prioritization, duplicate detection | Engineering | @every 2h |
| Documentation Writer | Automated doc updates | Engineering | Event-triggered |
| Product Owner | Feature prioritization, roadmap | Product | @every 12h |
| Business Analyst | Cross-domain analysis, trends | Product | @every 12h |
| Marketing Growth | Campaigns, SEO, content calendar | Growth | @daily |
| Blog Writer | Weekly technical blog posts | Growth | @weekly |
| Developer Relations | Community health, friction points | Growth | @daily |
| Market Intelligence | Industry landscape, feature parity | Growth | @weekly |
| Sales Pipeline | Funnel analysis, deal tracking | Revenue | @daily |
| Customer Onboarding | New customer setup flows | Revenue | CDC-triggered |
| Churn Predictor | Churn signals, retention actions | Revenue | CDC-triggered |
| Revenue Operations | CAC/LTV, attribution, forecasting | Revenue | @daily |
| Customer Support | Ticket triage, customer health | Customer Success | @every 2h |

## How They Work Together

The Executive Assistant leads the team as COO, coordinating across all six domains and issuing daily briefings. Engineering bots form two sub-chains: SRE & DevOps manages infrastructure with Uptime Manager and API Tester as supporting roles, while Code Reviewer oversees quality with Bug Triage and Documentation Writer. The Product Owner aggregates feedback from Customer Support, DevRel, and Sales Pipeline into prioritized feature recommendations, with Business Analyst providing cross-domain correlations.

On the growth side, Marketing Growth coordinates Blog Writer, Developer Relations, and Market Intelligence for a unified go-to-market effort. Revenue bots work as a pipeline: Sales Pipeline leads with Customer Onboarding (activation), Churn Predictor (retention), and RevOps (measurement) providing the full revenue lifecycle view. Customer Support operates independently, routing findings to Product Owner, Marketing Growth, and SRE & DevOps as needed.

**Communication flow:**
- Executive Assistant coordinates across all domains -> request to all specialists
- SRE & DevOps detects incident -> alert to Uptime Manager, Executive Assistant
- Uptime Manager tracks SLA breach risk -> alert to SRE & DevOps, Customer Support
- Code Reviewer detects security issue -> finding to SRE & DevOps, Executive Assistant
- API Tester finds regression -> finding to SRE & DevOps
- Bug Triage flags release blocker -> alert to Executive Assistant
- Documentation Writer detects doc gap -> alert to Marketing Growth
- Product Owner prioritizes feature -> finding to Executive Assistant
- Business Analyst correlates trends -> finding to Product Owner, Executive Assistant
- Marketing Growth reports campaign metrics -> finding to Business Analyst
- Blog Writer completes draft -> finding to Marketing Growth
- Developer Relations detects friction point -> finding to Product Owner
- Developer Relations sees community crisis -> alert to Executive Assistant
- Market Intelligence finds feature gap -> finding to Product Owner, Marketing Growth
- Sales Pipeline forecasts revenue -> finding to Executive Assistant
- Customer Onboarding reports blocker -> finding to Customer Support
- Churn Predictor flags at-risk account -> alert to Sales Pipeline, Customer Support
- Revenue Operations detects CAC/LTV shift -> finding to Sales Pipeline, Executive Assistant
- Customer Support routes feature requests -> finding to Product Owner
- Customer Support escalates critical issue -> alert to Executive Assistant

## Smaller Tiers

For smaller teams that don't need full 18-bot coverage:
- **[SaaS Starter](../saas-starter/)** (6 bots) — core essentials: engineering, growth, revenue, customer support
- **[SaaS Professional](../saas-professional/)** (12 bots) — adds product management, content, bug triage, onboarding, and churn prediction

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `mission`, `industry`, `stage`, `priorities`, `tech_stack`, `sla_targets`, `product_roadmap`, `brand_voice`, `product_catalog`, `growth_targets`, `documentation_standards`, `revenue_model`, `community_platforms`, `status_page_url`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's daily briefings for a consolidated operational view across all domains
