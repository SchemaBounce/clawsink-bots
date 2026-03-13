---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-pricing-optimizer
  displayName: "Dynamic Pricing"
  version: "1.0.0"
  description: "Analyzes market conditions, competitor rates, and demand patterns to optimize nightly rates and maximize revenue."
  category: finance
  tags: ["str", "dynamic-pricing", "revenue-management", "rate-optimization", "hospitality"]
agent:
  capabilities: ["finance", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "revenue"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "high"
cost:
  estimatedTokensPerRun: 30000
  estimatedCostTier: "medium"
schedule:
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 6h"
messaging:
  listensTo:
    - { type: "request", from: ["str-property-manager"] }
    - { type: "text", from: ["str-property-manager"] }
  sendsTo:
    - { type: "finding", to: ["str-property-manager"], when: "rate adjustment recommendations or market analysis complete" }
    - { type: "alert", to: ["str-property-manager"], when: "pricing anomaly detected — competitor drop, demand spike, or revenue risk" }
data:
  entityTypesRead: ["str_pricing_calendar", "str_bookings", "str_properties", "str_channel_listings"]
  entityTypesWrite: ["str_pricing_calendar", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "market_patterns", "seasonal_data"]
zones:
  zone1Read: ["property_count", "target_occupancy_rate", "market_type", "average_nightly_rate", "booking_channels"]
  zone2Domains: ["revenue"]
skills:
  - ref: "skills/dynamic-pricing@1.0.0"
requirements:
  minTier: "starter"
---

# Dynamic Pricing

The revenue brain of the short-term rental operation. Analyzes market conditions, competitor pricing, demand signals, and historical patterns to recommend optimal nightly rates that maximize revenue per available night (RevPAN).

## What It Does

- Analyzes comparable listings in the market to establish competitive rate ranges
- Tracks demand patterns: weekday vs. weekend, seasonal trends, local events, school holidays
- Recommends rate adjustments based on booking velocity and gap nights
- Manages minimum stay requirements — longer minimums during peak, flexible during slow periods
- Suggests last-minute discounts for unbooked nights within the next 7 days
- Detects pricing anomalies — competitors suddenly dropping 40%, unexpected demand surges

## Pricing Strategy

Uses a multi-factor approach:
- **Base rate**: Derived from comparable properties, amenities, and location
- **Demand multiplier**: Adjusts based on forward booking pace and local events
- **Gap night optimization**: Reduces rates for orphan nights between bookings
- **Seasonal adjustment**: Accounts for high/low season patterns specific to the market type
- **Last-minute discount**: Progressive discounts as unbooked dates approach

## Recommended Setup

Fill in these North Star keys for best results:
- `target_occupancy_rate` — Your target (e.g., 75% — higher for urban, lower for luxury)
- `market_type` — Affects seasonal patterns (beach peaks in summer, ski in winter)
- `average_nightly_rate` — Baseline for the portfolio
