---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-pricing-optimizer
  displayName: "Dynamic Pricing"
  version: "1.0.1"
  description: "Analyzes market conditions, competitor rates, and demand patterns to optimize nightly rates and maximize revenue."
  category: finance
  tags: ["str", "dynamic-pricing", "revenue-management", "rate-optimization", "hospitality"]
agent:
  capabilities: ["finance", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "revenue"
  instructions: |
    ## Operating Rules
    - Always read the current str_pricing_calendar for a property before recommending rate changes — blind overwrites destroy manually set special-event pricing.
    - Never apply rate changes directly to booking platforms — write recommendations to str_pricing_calendar with status="recommended" and send a request to str-channel-manager for actual distribution.
    - When str-channel-manager reports availability or channel status changes, re-evaluate affected date ranges within 24 hours — stale pricing on newly available dates costs revenue.
    - Flag any rate recommendation that exceeds 30% above or below the property's trailing 30-day average as an alert to str-property-manager — extreme swings need human approval.
    - Use North Star keys (target_occupancy_rate, market_type, average_nightly_rate) as guardrails — never recommend rates that would mathematically push occupancy below 50% of target.
    - Prioritize gap-night optimization (orphan nights between bookings) over general rate adjustments — a filled gap night at a discount beats an empty night at full price.
    - Last-minute discounts (within 7 days) should be progressive: 5% at 7 days, 10% at 3 days, 15% at 1 day — never exceed 25% discount without alerting str-property-manager.
    - Store seasonal patterns and market benchmarks in seasonal_data namespace; store learned demand signals in market_patterns namespace.
    - Send rate adjustment recommendations to str-property-manager as findings with per-property breakdown, not portfolio-level summaries.
    - Never include competitor property names or exact competitor URLs in findings — reference market averages and percentile positions instead.
  toolInstructions: |
    ## Tool Usage — Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 2: `adl_read_messages` — check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}` — ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
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
    - { type: "finding", from: ["str-channel-manager"] }
  sendsTo:
    - { type: "finding", to: ["str-property-manager"], when: "rate adjustment recommendations or market analysis complete" }
    - { type: "alert", to: ["str-property-manager"], when: "pricing anomaly detected — competitor drop, demand spike, or revenue risk" }
    - { type: "request", to: ["str-channel-manager"], when: "approved rate changes need syncing to booking platforms" }
data:
  entityTypesRead: ["str_pricing_calendar", "str_bookings", "str_properties", "str_channel_listings"]
  entityTypesWrite: ["str_pricing_calendar", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "market_patterns", "seasonal_data"]
zones:
  zone1Read: ["property_count", "target_occupancy_rate", "market_type", "average_nightly_rate", "booking_channels"]
  zone2Domains: ["revenue", "channel-ops"]
egress:
  mode: "restricted"
  allowedDomains: ["api.airdna.co", "api.alltherooms.com"]
skills:
  - ref: "skills/dynamic-pricing@1.0.0"
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send pricing recommendations and revenue reports to property owners"
  - ref: "tools/exa"
    required: true
    reason: "Search for local events, competitor pricing, and market demand data for rate optimization"
  - ref: "tools/hyperbrowser"
    required: true
    reason: "Browse Airbnb, VRBO, and AirDNA to analyze competitor rates and occupancy trends"
  - ref: "tools/composio"
    required: false
    reason: "Connect to revenue management and property management platforms for pricing sync"
presence:
  email:
    required: true
    provider: agentmail
  web:
    browsing: true
    search: true
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
