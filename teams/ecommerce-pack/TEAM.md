---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: ecommerce-pack
  displayName: "E-Commerce Pack"
  version: "1.0.0"
  description: "AI team for online retail — inventory management, customer support, financial tracking, compliance, and business intelligence"
  category: ecommerce
  tags: ["ecommerce", "retail", "online-store", "customer-service"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-assistant@1.0.0"
    overrides:
      name: "Operations Director"
      schedule: "@every 1h"
  - ref: "bots/accountant@1.0.0"
    overrides:
      name: "Finance & Revenue"
  - ref: "bots/inventory-manager@1.0.0"
    overrides:
      name: "Inventory & Fulfillment"
  - ref: "bots/customer-support@1.0.0"
    overrides:
      name: "Customer Experience"
  - ref: "bots/business-analyst@1.0.0"
    overrides:
      name: "Analytics & Growth"
northStar:
  industry: "E-Commerce / Online Retail"
  context: "Online retail business managing inventory, orders, customer service, and growth analytics"
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
    - bot: inventory-manager
      role: specialist
      reportsTo: executive-assistant
      domain: fulfillment
    - bot: customer-support
      role: specialist
      reportsTo: executive-assistant
      domain: storefront
    - bot: business-analyst
      role: support
      reportsTo: customer-support
      domain: storefront
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Revenue anomaly"
        trigger: "revenue_anomaly"
        chain: [accountant, executive-assistant]
      - name: "Stock critical"
        trigger: "stock_critical"
        chain: [inventory-manager, executive-assistant]
      - name: "Customer escalation"
        trigger: "customer_escalation"
        chain: [customer-support, executive-assistant]
---
# E-Commerce Pack

AI workforce for online retail operations. Five bots coordinate to optimize your store.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|----------|
| Operations Director | Oversees all operations, daily summaries, strategic decisions | @every 1h |
| Finance & Revenue | Tracks revenue, margins, refunds, tax compliance | @daily |
| Inventory & Fulfillment | Stock levels, reorder points, supplier management | @daily |
| Customer Experience | Support tickets, reviews, satisfaction tracking | @every 2h |
| Analytics & Growth | Sales trends, customer segments, marketing insights | @daily |

## How They Work Together

The Operations Director coordinates all activity and produces daily operational summaries. Finance tracks revenue and flags anomalies. Inventory monitors stock levels and coordinates with Finance on reorder costs. Customer Experience handles support and escalates review spikes. Analytics identifies growth opportunities and provides data-driven insights.

**Communication flow:**
- Finance detects revenue anomaly -> finding to Operations Director
- Inventory identifies critical stock level -> alert to Operations Director
- Inventory estimates reorder costs -> finding to Finance
- Customer Experience sees negative review spike -> alert to Operations Director
- Analytics identifies growth opportunity -> finding to Operations Director
- Operations Director requests analysis from Analytics

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `industry`, `context`, plus any store-specific details
3. Bots begin running on their default schedules automatically
4. Check the Operations Director's summaries for a consolidated view of store performance
