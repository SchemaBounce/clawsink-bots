---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: startup-all-in-one
  displayName: "Full-Stack Startup Team"
  version: "1.0.0"
  description: "Complete operational coverage for lean startups: finance, support, marketing, product, infrastructure, and executive reporting"
  category: startup
  tags: ["startup", "all-in-one", "full-stack", "growth", "ops"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "$28.00"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/accountant@1.0.0"
  - ref: "bots/customer-support@1.0.0"
  - ref: "bots/marketing-growth@1.0.0"
  - ref: "bots/product-owner@1.0.0"
  - ref: "bots/sre-devops@1.0.0"
  - ref: "bots/executive-reporter@1.0.0"
northStar:
  industry: "Startup / Early-Stage Company"
  context: "Lean startup team needing full operational coverage with minimal headcount"
  requiredKeys:
    - mission
    - runway_months
    - key_metrics
    - growth_targets
    - tech_stack
    - compliance_requirements
---
# Full-Stack Startup Team

Seven bots providing complete operational coverage for early-stage startups: central coordination, financial monitoring, customer support triage, growth marketing, product management, infrastructure reliability, and executive reporting.

## Included Bots

| Bot | Role | Schedule | ~$/month |
|-----|------|----------|----------|
| Executive Assistant | COO, central coordination | @every 4h | $3.24 |
| Accountant | Financial monitoring, invoice categorization | @daily | $0.09 |
| Customer Support | Ticket triage, churn detection | @every 2h | $3.12 |
| Marketing Growth | Campaign tracking, content calendar | @daily | $0.09 |
| Product Owner | Backlog management, roadmap | @daily | $0.09 |
| SRE & DevOps | Infrastructure monitoring, incident response | @every 4h | $3.24 |
| Executive Reporter | Weekly C-suite reports, KPI dashboards | @weekly | $0.15 |

## How They Work Together

The Executive Assistant serves as the COO, coordinating across all functions and issuing weekly directives. Customer Support triages tickets and routes feature requests to the Product Owner and customer feedback to Marketing Growth. The Accountant monitors cash flow and flags budget anomalies. SRE & DevOps handles infrastructure incidents and reports tech debt to the Product Owner. The Executive Reporter aggregates data from the Accountant, Marketing Growth, and SRE & DevOps into consolidated C-suite briefings.

**Communication flow:**
- Accountant detects budget anomaly -> alert to Executive Assistant
- Customer Support sees churn risk -> alert to Executive Assistant
- Customer Support collects feature requests -> finding to Product Owner
- Customer Support gathers customer feedback -> finding to Marketing Growth
- Marketing Growth reports campaign performance -> finding to Executive Assistant
- Product Owner needs roadmap decision -> request to Executive Assistant
- Product Owner needs deployment or feasibility check -> request to SRE & DevOps
- SRE & DevOps detects infrastructure incident -> alert to Executive Assistant
- SRE & DevOps finds tech debt -> finding to Product Owner
- Executive Reporter delivers KPI summary -> finding to Executive Assistant
- Accountant sends financial data -> finding to Executive Reporter
- Marketing Growth sends growth metrics -> finding to Executive Reporter
- SRE & DevOps sends infrastructure metrics -> finding to Executive Reporter
- Executive Assistant coordinates across all bots -> request to all

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `mission`, `runway_months`, `key_metrics`, `growth_targets`, `tech_stack`, `compliance_requirements`
3. Bots begin running on their default schedules automatically
4. Check the Executive Reporter's weekly briefings for a consolidated startup health view
