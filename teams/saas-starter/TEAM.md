---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: saas-starter
  displayName: "SaaS Starter"
  version: "1.0.0"
  description: "Essential SaaS operations for small teams — 7 bots covering engineering, growth, revenue, customer success, and platform optimization"
  category: saas
  tags: ["saas", "starter", "small-team", "engineering", "growth", "revenue", "customer-success"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
requirements:
  minTier: "starter"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/sre-devops@1.0.0"
  - ref: "bots/code-reviewer@1.0.0"
  - ref: "bots/marketing-growth@1.0.0"
  - ref: "bots/sales-pipeline@1.0.0"
  - ref: "bots/customer-support@1.0.0"
  - ref: "bots/platform-optimizer@1.0.0"
plugins:
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    reason: "Executive-assistant needs cross-run recall for daily briefings and coordination"
    config:
      embedding_model: "text-embedding-3-small"
      max_results: 15
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Sales-pipeline needs CRM OAuth, marketing-growth needs analytics OAuth"
    config:
      scopes: ["crm", "analytics"]
mcpServers:
  - ref: "tools/github"
    reason: "Shared GitHub access for code-reviewer and SRE-devops"
dataKits:
  - ref: "data-kits/saas@2.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/crm-contacts@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "B2B SaaS"
  context: "Small SaaS teams needing core operational coverage — engineering reliability, code quality, growth, revenue tracking, and customer support with a single coordinator"
  requiredKeys:
    - mission
    - industry
    - stage
    - priorities
    - tech_stack
    - growth_targets
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
    # --- Growth ---
    - bot: marketing-growth
      role: specialist
      reportsTo: executive-assistant
      domain: growth
    # --- Revenue ---
    - bot: sales-pipeline
      role: specialist
      reportsTo: executive-assistant
      domain: revenue
    # --- Customer Success ---
    - bot: customer-support
      role: specialist
      reportsTo: executive-assistant
      domain: customer-success
    # --- Platform ---
    - bot: platform-optimizer
      role: support
      reportsTo: executive-assistant
      domain: platform-ops
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
      - name: "Revenue Anomaly"
        trigger: "revenue_anomaly"
        chain: [sales-pipeline, executive-assistant]
      - name: "Customer Escalation"
        trigger: "customer_escalation"
        chain: [customer-support, executive-assistant]
      - name: "Platform Health Degradation"
        trigger: "platform_health_critical"
        chain: [platform-optimizer, executive-assistant]
teamGoals:
  - name: engineering_reliability
    description: "Infrastructure incidents detected and resolved proactively"
    category: primary
    composedFrom:
      - bot: sre-devops
        goal: sla_compliance
        weight: 0.6
      - bot: sre-devops
        goal: detect_incidents
        weight: 0.4
    target:
      operator: ">"
      value: 0.95
      period: weekly
  - name: customer_health
    description: "Customer issues resolved with high SLA compliance"
    category: primary
    composedFrom:
      - bot: customer-support
        goal: resolve_tickets
        weight: 0.5
      - bot: customer-support
        goal: sla_compliance
        weight: 0.5
    target:
      operator: ">"
      value: 0.8
      period: weekly
  - name: team_responsiveness
    description: "Average time from issue detection to first bot action across all domains"
    category: secondary
    composedFrom:
      - bot: sre-devops
        goal: detect_incidents
      - bot: customer-support
        goal: first_response_time
    aggregation: worst
    target:
      operator: "<"
      value: 30
      period: daily
  - name: workforce_learning
    description: "All bots continuously improving from operational experience"
    category: health
    composedFrom:
      - bot: sre-devops
        goal: threshold_calibration
      - bot: customer-support
        goal: pattern_learning
    aggregation: worst
    target:
      operator: ">"
      value: 0
      period: monthly
---
# SaaS Starter

Six bots providing essential operational coverage for small B2B SaaS teams: engineering reliability, code quality, growth marketing, sales pipeline, customer support, and executive coordination.

## Included Bots

| Bot | Role | Domain | Schedule |
|-----|------|--------|----------|
| Executive Assistant | Team lead, daily briefings | Operations | @every 4h |
| SRE & DevOps | Infrastructure monitoring, incidents | Engineering | @every 4h |
| Code Reviewer | PR review, security scanning | Engineering | CDC on pull_requests |
| Marketing Growth | Campaigns, SEO, content calendar | Growth | @daily |
| Sales Pipeline | Funnel analysis, deal tracking | Revenue | @daily |
| Customer Support | Ticket triage, customer health | Customer Success | @every 2h |

## How They Work Together

The Executive Assistant leads the team, coordinating across four domains and issuing daily briefings. SRE & DevOps and Code Reviewer cover engineering — infrastructure health and code quality respectively. Marketing Growth handles go-to-market activities. Sales Pipeline tracks revenue and deal flow. Customer Support triages tickets and routes feature requests to the team lead.

**Communication flow:**
- Executive Assistant coordinates across all domains -> request to all specialists
- SRE & DevOps detects incident -> alert to Executive Assistant
- Code Reviewer detects security issue -> finding to SRE & DevOps, Executive Assistant
- Marketing Growth reports campaign metrics -> finding to Executive Assistant
- Sales Pipeline forecasts revenue -> finding to Executive Assistant
- Customer Support routes feature requests -> finding to Executive Assistant
- Customer Support escalates critical issue -> alert to Executive Assistant

## Upgrading

For more comprehensive coverage, consider:
- **[SaaS Professional](../saas-professional/)** (12 bots) — adds product management, content, bug triage, onboarding, and churn prediction
- **[SaaS Command Center](../saas-command-center/)** (18 bots) — full operational coverage with DevRel, market intelligence, RevOps, and more

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `mission`, `industry`, `stage`, `priorities`, `tech_stack`, `growth_targets`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's daily briefings for a consolidated operational view
