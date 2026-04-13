---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: tradesman-pack
  displayName: "Tradesman Pack"
  version: "1.0.0"
  description: "Complete AI team for construction and trades businesses — project management, estimating, scheduling, safety compliance, and client communications"
  category: trades
  tags: ["construction", "trades", "small-business", "project-management"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-assistant@1.0.0"
    overrides:
      name: "Project Manager"
      schedule: "@every 2h"
  - ref: "bots/accountant@1.0.0"
    overrides:
      name: "Estimator & Billing"
  - ref: "bots/inventory-manager@1.0.0"
    overrides:
      name: "Materials & Scheduling"
  - ref: "bots/legal-compliance@1.0.0"
    overrides:
      name: "Site Safety & Permits"
  - ref: "bots/customer-support@1.0.0"
    overrides:
      name: "Customer Liaison"
dataKits:
  - ref: "data-kits/construction@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/crm-contacts@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/financial-ops@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "Construction / Trades"
  context: "Small to mid-size contracting business managing projects, estimates, materials, safety compliance, and client relationships"
orgChart:
  lead: executive-assistant
  domains:
    - name: "Job Management"
      description: "Dispatch, scheduling, site-visit coordination"
      head: executive-assistant
      children:
        - name: "Materials"
          description: "Parts stock, truck inventory, reorder triggers"
          head: inventory-manager
    - name: "Finance"
      description: "Invoicing, estimates, cash-flow"
      head: accountant
    - name: "Customer Relations"
      description: "Booking, reminders, post-job feedback"
      head: customer-support
    - name: "Compliance"
      description: "Licenses, permits, liability paperwork"
      head: legal-compliance
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: job-management
    - bot: accountant
      role: specialist
      reportsTo: executive-assistant
      domain: finance
    - bot: inventory-manager
      role: specialist
      reportsTo: executive-assistant
      domain: job-management
    - bot: legal-compliance
      role: specialist
      reportsTo: executive-assistant
      domain: compliance
    - bot: customer-support
      role: specialist
      reportsTo: executive-assistant
      domain: customer-relations
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Budget Overrun"
        trigger: "estimate_exceeds_budget"
        chain: [accountant, executive-assistant]
      - name: "Material Shortage"
        trigger: "material_shortage"
        chain: [inventory-manager, executive-assistant]
      - name: "Safety Violation"
        trigger: "safety_violation"
        chain: [legal-compliance, executive-assistant]
      - name: "Client Escalation"
        trigger: "client_escalation"
        chain: [customer-support, executive-assistant]
---
# Tradesman Pack

Complete AI workforce for construction and trades businesses. Five specialized bots coordinate to manage your projects end-to-end.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|----------|
| Project Manager | Coordinates all activities, tracks project milestones | @every 2h |
| Estimator & Billing | Creates quotes, tracks expenses, manages invoicing | @daily |
| Materials & Scheduling | Manages inventory, schedules deliveries and crews | @daily |
| Site Safety & Permits | Monitors compliance, tracks permits and certifications | @weekly |
| Customer Liaison | Handles client communications, manages expectations | @every 2h |

## How They Work Together

The Project Manager sits at the center, coordinating across all four specialist bots. The Estimator tracks finances and produces quotes, Materials handles inventory and crew scheduling, Site Safety monitors compliance, and the Customer Liaison keeps clients informed.

**Communication flow:**
- Estimator detects estimate exceeds budget -> finding to Project Manager
- Materials identifies material shortage -> alert to Project Manager
- Site Safety flags safety violation -> alert to Project Manager
- Customer Liaison receives client escalation -> alert to Project Manager
- Project Manager requests quotes from Estimator
- Project Manager requests material checks from Materials

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `industry`, `context`, plus any project-specific details
3. Bots begin running on their default schedules automatically
4. Check the Project Manager's briefings for a consolidated view of all projects
