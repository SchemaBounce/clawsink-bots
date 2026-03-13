---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: small-business-starter
  displayName: "Small Business Starter"
  version: "1.0.0"
  description: "Essential AI team for any small business"
  category: general
  tags: ["small-business", "starter", "essential"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/accountant@1.0.0"
  - ref: "bots/customer-support@1.0.0"
  - ref: "bots/marketing-growth@1.0.0"
  - ref: "bots/legal-compliance@1.0.0"
dataKits:
  - ref: "data-kits/crm-contacts@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/financial-ops@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "General Small Business"
  context: "Solo founder or small team looking to automate operations"
  requiredKeys:
    - mission
    - industry
    - priorities
    - budget_constraints
    - compliance_requirements
orgChart:
  lead: executive-assistant
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: operations
    - bot: accountant
      role: specialist
      reportsTo: executive-assistant
      domain: finance
    - bot: customer-support
      role: specialist
      reportsTo: executive-assistant
      domain: customer-relations
    - bot: marketing-growth
      role: specialist
      reportsTo: executive-assistant
      domain: growth
    - bot: legal-compliance
      role: specialist
      reportsTo: executive-assistant
      domain: compliance
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Budget anomaly"
        trigger: "budget_anomaly"
        chain: [accountant, executive-assistant]
      - name: "Churn risk"
        trigger: "churn_risk"
        chain: [customer-support, executive-assistant]
      - name: "Compliance deadline"
        trigger: "compliance_deadline"
        chain: [legal-compliance, executive-assistant]
---
# Small Business Starter

The essential AI team for any small business. Five bots covering the core operational areas that every business needs: coordination, finance, customer relations, growth, and compliance.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|----------|
| Executive Assistant | Central coordinator, daily briefings | @every 4h |
| Accountant | Invoice categorization, budget monitoring | @daily |
| Customer Support | Ticket triage, churn detection | @every 2h |
| Marketing & Growth | Content calendar, campaign tracking | @daily |
| Legal & Compliance | Contract review, regulatory monitoring | @weekly |

## How They Work Together

The Executive Assistant sits at the center, reading findings from all four specialist bots and producing prioritized daily briefings. The Accountant tracks finances, Customer Support monitors customer health, Marketing drives growth, and Legal ensures compliance.

**Communication flow:**
- Accountant detects budget anomaly -> finding to Executive Assistant
- Customer Support sees churn risk -> alert to Executive Assistant
- Marketing identifies growth trend -> finding to Executive Assistant
- Legal flags compliance deadline -> alert to Executive Assistant
- Executive Assistant synthesizes all into prioritized briefing

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `mission`, `industry`, `priorities`, `budget_constraints`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's daily briefings for a consolidated view
