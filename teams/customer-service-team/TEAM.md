---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: customer-service-team
  displayName: "Customer Service"
  version: "1.0.0"
  description: "End-to-end customer service automation covering support ticketing, onboarding, churn prediction, and social media monitoring"
  domain: customer-service
  category: customer-service
  tags: ["customer-service", "support", "churn", "nps", "onboarding", "social"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/customer-support@1.0.0"
  - ref: "bots/customer-onboarding@1.0.0"
  - ref: "bots/churn-predictor@1.0.0"
  - ref: "bots/social-media-monitor@1.0.0"
dataKits:
  - ref: "data-kits/customer-service@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Customer Service"
  context: "Customer service team managing support tickets, new customer onboarding, churn risk, and social media brand monitoring"
  requiredKeys:
    - support_sla_targets
    - escalation_contacts
    - customer_segments
    - churn_risk_thresholds
    - brand_social_handles
orgChart:
  lead: customer-support
  domains:
    - name: "Support Operations"
      description: "Ticket triage, resolution, SLA management, and customer satisfaction"
      head: customer-support
      children:
        - name: "Customer Onboarding"
          description: "New customer activation, setup guidance, and early lifecycle success"
          head: customer-onboarding
    - name: "Customer Health"
      description: "Churn risk monitoring, NPS tracking, and proactive retention"
      head: churn-predictor
    - name: "Social Monitoring"
      description: "Brand mentions, social sentiment, and public-facing response coordination"
      head: social-media-monitor
  roles:
    - bot: customer-support
      role: lead
      reportsTo: null
      domain: support-operations
    - bot: customer-onboarding
      role: specialist
      reportsTo: customer-support
      domain: support-operations
    - bot: churn-predictor
      role: specialist
      reportsTo: customer-support
      domain: customer-health
    - bot: social-media-monitor
      role: specialist
      reportsTo: customer-support
      domain: social-monitoring
  escalation:
    critical: customer-support
    unhandled: customer-support
    paths:
      - name: "Critical Ticket Escalation"
        trigger: "ticket_severity_critical"
        chain: [customer-support]
      - name: "Churn Risk Alert"
        trigger: "churn_risk_high"
        chain: [churn-predictor, customer-support]
      - name: "Onboarding Blocker"
        trigger: "onboarding_blocked"
        chain: [customer-onboarding, customer-support]
      - name: "Social Crisis"
        trigger: "social_sentiment_negative_spike"
        chain: [social-media-monitor, customer-support]
---
# Customer Service

Four bots covering the full customer service lifecycle: support ticket management, new customer onboarding, churn risk prediction, and social media brand monitoring.

## Included Bots

| Bot | Role | Focus |
|-----|------|-------|
| Customer Support | Lead, support operations | Ticket triage, SLA management, CSAT |
| Customer Onboarding | Specialist, support | New customer activation and setup guidance |
| Churn Predictor | Specialist, customer health | Churn risk scoring and proactive retention |
| Social Media Monitor | Specialist, social | Brand mentions, sentiment tracking, and response coordination |

## How They Work Together

Customer Support coordinates all service activity and receives consolidated status from across the team. Customer Onboarding manages the new customer activation pipeline and escalates blockers. Churn Predictor continuously scores customer health against behavioral signals and flags at-risk accounts for intervention. Social Media Monitor tracks brand mentions and social sentiment, surfacing PR risks or customer complaints that need a human response.

**Communication flow:**
- Customer Onboarding hits a blocker -> alert to Customer Support
- Churn Predictor scores an account as high risk -> alert to Customer Support
- Churn Predictor detects NPS detractor -> finding to Customer Support
- Social Media Monitor detects negative sentiment spike -> alert to Customer Support
- Customer Support closes a critical ticket -> notify Churn Predictor to re-score the account

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `support_sla_targets`, `escalation_contacts`, `customer_segments`, `churn_risk_thresholds`, `brand_social_handles`
3. Bots begin running on their default schedules automatically
4. Check Customer Support's daily briefing for consolidated service health
