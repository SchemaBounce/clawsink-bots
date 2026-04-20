---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: restaurant
  displayName: Restaurant Operations
  version: "1.0.0"
  description: Full-stack restaurant data kit covering menus, reservations, suppliers, covers, and reviews.
  category: industry
  tags:
    - restaurant
    - hospitality
    - food-service
    - menu-management
    - reservations
    - suppliers
  author: SchemaBounce
compatibility:
  teams:
    - restaurant-group
  composableWith:
    - crm-contacts
    - financial-ops
    - customer-feedback
entityPrefix: rest_
entityCount: 5
graphEdgeTypes:
  - SUPPLIED_BY
  - REVIEWED
vectorCollections:
  - rest_menu_items
  - rest_reviews
useCases:
  - "Keep a menu with costing and dietary flags, updated by the chef"
  - "Accept reservations, manage no-shows, and seat parties on the day"
  - "Track covers per shift and revenue per seat"
  - "Log supplier orders, deliveries, and pricing over time"
---

# Restaurant Operations

A comprehensive data kit for restaurant management covering the full operational lifecycle. Designed for independent restaurants, small chains, and restaurant groups that need AI-powered insights into their menu performance, supplier relationships, reservation patterns, and customer feedback.

## What's Included

- **Menu Items** — Complete menu catalog with costing, allergens, and categories
- **Reservations** — Table booking management with party size and status tracking
- **Suppliers** — Vendor directory with delivery schedules and payment terms
- **Daily Covers** — Service-level metrics for revenue and guest tracking
- **Reviews** — Customer feedback from multiple platforms with sentiment

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Food Cost Ratio | 28-35% | Core profitability measure |
| Table Turnover | 2-3x per service | Revenue per seat optimization |
| Average Check | Varies by concept | Menu engineering effectiveness |
| Waste Percentage | <5% | Cost control and sustainability |
| Reservation No-Show Rate | <10% | Capacity planning accuracy |

## Graph Relationships

- **SUPPLIED_BY** links menu items to their suppliers with cost and lead time data
- **REVIEWED** links customer reviews to specific menu items for sentiment analysis

## Composability

Pairs naturally with:
- **crm-contacts** — Link reservations to CRM contact records
- **financial-ops** — Connect daily covers to accounting transactions
- **customer-feedback** — Aggregate reviews into broader feedback workflows
