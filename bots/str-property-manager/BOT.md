---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-property-manager
  displayName: "Property Manager"
  version: "1.0.0"
  description: "Lead coordinator for short-term rental operations — consolidates reports, manages portfolio dashboard, coordinates specialists."
  category: operations
  tags: ["str", "property-management", "portfolio", "coordination", "lead", "hospitality"]
agent:
  capabilities: ["management", "operations", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "portfolio-management"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
cost:
  estimatedTokensPerRun: 40000
  estimatedCostTier: "high"
schedule:
  default: "@daily"
  recommendations:
    light: "@daily"
    standard: "@daily"
    intensive: "@every 4h"
messaging:
  listensTo:
    - { type: "alert", from: ["*"] }
    - { type: "finding", from: ["str-channel-manager", "str-guest-communicator", "str-pricing-optimizer", "str-property-marketer", "str-turnover-coordinator", "str-review-manager"] }
    - { type: "text", from: ["*"] }
  sendsTo:
    - { type: "text", to: ["str-channel-manager", "str-guest-communicator", "str-pricing-optimizer", "str-property-marketer", "str-turnover-coordinator", "str-review-manager"], when: "daily portfolio briefing distribution" }
    - { type: "request", to: ["str-channel-manager", "str-pricing-optimizer", "str-turnover-coordinator"], when: "cross-domain coordination needed" }
data:
  entityTypesRead: ["str_properties", "str_bookings", "str_channel_listings", "str_pricing_calendar", "str_messages", "str_guests", "str_reviews", "str_turnovers", "str_findings", "str_alerts", "crm_contacts", "fin_transactions"]
  entityTypesWrite: ["str_properties", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "portfolio_health", "learned_patterns"]
zones:
  zone1Read: ["property_count", "primary_channel", "target_occupancy_rate", "market_type", "average_nightly_rate", "check_in_method", "cleaning_service", "booking_channels"]
  zone2Domains: ["portfolio-management", "channel-ops", "guest-relations", "revenue", "marketing", "operations"]
skills:
  - ref: "skills/daily-briefing@1.0.0"
  - ref: "skills/cross-domain-synthesis@1.0.0"
requirements:
  minTier: "starter"
---

# Property Manager

The lead coordinator for a short-term rental operations team. This bot consolidates outputs from all six specialists — channel management, guest communication, pricing, marketing, turnovers, and reviews — into a unified portfolio dashboard and daily owner briefing.

## What It Does

- Reads all findings and alerts from every specialist bot in the team
- Produces daily portfolio briefings: occupancy pipeline, revenue trends, operational flags
- Tracks property status across the portfolio (active, blocked, maintenance, seasonal)
- Coordinates cross-domain actions (e.g., pricing adjustments triggered by review trends)
- Manages escalation — receives all critical alerts and determines human-owner notification

## Recommended Setup

Ensure these North Star keys are filled:
- `property_count` — Number of properties in the portfolio
- `primary_channel` — Main booking platform (Airbnb, VRBO, etc.)
- `target_occupancy_rate` — Target occupancy percentage (e.g., 75%)
- `market_type` — Market type (urban, beach, mountain, rural)
- `average_nightly_rate` — Average nightly rate across portfolio
- `booking_channels` — All active booking channels
