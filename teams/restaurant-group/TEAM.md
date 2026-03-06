---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: restaurant-group
  displayName: "Restaurant Group"
  version: "1.0.0"
  description: "AI operations team for restaurants and food service — manages food costs, perishable inventory, customer relations, and local marketing"
  category: hospitality
  tags: ["restaurant", "hospitality", "food-service", "inventory", "starter"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
requirements:
  minTier: "starter"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/accountant@1.0.0"
  - ref: "bots/inventory-manager@1.0.0"
  - ref: "bots/inventory-alert@1.0.0"
  - ref: "bots/customer-support@1.0.0"
  - ref: "bots/marketing-growth@1.0.0"
northStar:
  industry: "Restaurant / Food Service"
  context: "Restaurant owners or small chains managing daily operations — food costs, inventory waste, customer complaints, and local marketing"
  requiredKeys:
    - cuisine_type
    - locations
    - supplier_list
    - peak_hours
    - food_cost_target
    - reservation_platform
orgChart:
  lead: executive-assistant
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: front-of-house
    - bot: accountant
      role: specialist
      reportsTo: executive-assistant
      domain: finance
    - bot: inventory-manager
      role: specialist
      reportsTo: executive-assistant
      domain: kitchen-ops
    - bot: inventory-alert
      role: support
      reportsTo: inventory-manager
      domain: kitchen-ops
    - bot: customer-support
      role: specialist
      reportsTo: executive-assistant
      domain: front-of-house
    - bot: marketing-growth
      role: specialist
      reportsTo: executive-assistant
      domain: marketing
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Food waste or stockout"
        trigger: "inventory_critical"
        chain: [inventory-alert, inventory-manager, executive-assistant]
      - name: "Customer complaint"
        trigger: "customer_escalation"
        chain: [customer-support, executive-assistant]
---
# Restaurant Group

An AI operations team built for the realities of running a restaurant. Food margins are razor-thin, perishables spoil, suppliers miss deliveries, and a single bad review on a Friday night can tank your weekend. This team keeps every part of the operation visible so nothing falls through the cracks between the morning prep and the last table clearing.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Assistant | Daily pre-service briefing pulling insights from all bots | @daily |
| Accountant | Tracks food cost ratios, labor spend, daily covers, and revenue trends | @daily |
| Inventory Manager | Monitors ingredient stock levels, supplier lead times, and par levels | @every 4h |
| Inventory Alert | Fires when perishables approach expiry, stock drops below par, or waste thresholds are hit | @cdc |
| Customer Support | Triages reservation issues, review platform complaints, and guest feedback | @every 2h |
| Marketing Growth | Manages local promotions, seasonal menu campaigns, happy hour pushes, and social presence | @daily |

## How They Work Together

In a restaurant, everything connects back to the walk-in cooler and the guest experience. Inventory Manager continuously tracks what you have on hand against what you need for tonight's covers and tomorrow's prep list. When avocados are two days from turning or your fish supplier is delayed, Inventory Alert fires immediately — giving the kitchen time to 86 an item or call the backup supplier before service starts.

Accountant watches the numbers that keep restaurants alive: food cost percentage against your target, labor cost as a ratio of revenue, and daily cover counts versus projections. When food cost creeps above target, it cross-references with Inventory Manager to identify whether the issue is waste, over-portioning, or supplier price increases.

Customer Support monitors your reservation platform and review sites. A complaint about wait times or a cold dish gets triaged and surfaced before it becomes a pattern. Positive reviews get flagged for Marketing Growth to amplify.

Marketing Growth handles the local game — promoting the weekend special, pushing the new seasonal menu, managing your social accounts, and coordinating local event tie-ins. It pulls from Accountant to understand which promotions actually drive profitable covers, not just foot traffic.

Executive Assistant ties it all together into the daily pre-service briefing: tonight's reservation count, 86 list from Inventory Alert, any guest issues from Customer Support, food cost trend from Accountant, and active promotions from Marketing Growth.

**Communication flow:**
- Inventory Alert detects low stock or approaching expiry -> alert to Executive Assistant and Inventory Manager
- Inventory Manager identifies supplier delay or par level breach -> finding to Accountant and Executive Assistant
- Accountant flags food cost ratio above target -> analysis to Executive Assistant with root cause from Inventory Manager
- Customer Support receives negative review or reservation complaint -> triage to Executive Assistant
- Marketing Growth needs promotion performance data -> request to Accountant
- Executive Assistant compiles daily pre-service briefing from all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `cuisine_type`, `locations`, `supplier_list`, `peak_hours`, `food_cost_target`, `reservation_platform`
3. Bots begin running on their default schedules automatically
4. Check Executive Assistant's daily briefings for a consolidated pre-service view
