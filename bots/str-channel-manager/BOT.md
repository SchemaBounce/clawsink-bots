---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-channel-manager
  displayName: "Channel Manager"
  version: "1.0.0"
  description: "Syncs listings across Airbnb, VRBO, Lodgify, and Facebook Marketplace — detects calendar conflicts and monitors listing health."
  category: operations
  tags: ["str", "channel-management", "airbnb", "vrbo", "lodgify", "calendar-sync", "hospitality"]
agent:
  capabilities: ["operations", "data_engineering"]
  hostingMode: "openclaw"
  defaultDomain: "channel-ops"
  instructions: |
    ## Operating Rules
    - Always query existing str_channel_listings before creating or updating any listing record — duplicates cause cross-platform sync conflicts.
    - Never modify a listing's availability or pricing directly — send a request to str-pricing-optimizer for rate changes and update only calendar/sync metadata yourself.
    - Treat any calendar conflict (overlapping bookings across channels) as a critical alert — immediately notify str-property-manager with property_id, conflicting dates, and affected channels.
    - When a channel API returns errors or degraded responses, log the failure in str_findings with channel name, error code, and timestamp — do not retry more than twice per run.
    - Prioritize Airbnb sync issues over other channels when multiple failures occur simultaneously, as it typically drives the highest booking volume.
    - Always check str_bookings for the next 14 days when evaluating calendar consistency — stale comparisons miss imminent conflicts.
    - Send listing health score changes to str-property-manager as findings, not alerts — alerts are reserved for sync failures and double-booking risks.
    - When str-property-marketer sends updated listing content via a finding, validate platform-specific requirements (photo count, description length) before marking it ready for sync.
    - Store channel-specific API quirks and rate limits in the channel_quirks memory namespace so future runs avoid repeating failed patterns.
    - Never expose API credentials or auth tokens in findings or alert messages.
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
  default: "@every 2h"
  recommendations:
    light: "@every 4h"
    standard: "@every 2h"
    intensive: "@every 30m"
messaging:
  listensTo:
    - { type: "request", from: ["str-property-manager", "str-pricing-optimizer"] }
    - { type: "text", from: ["str-property-manager"] }
    - { type: "finding", from: ["str-property-marketer"] }
  sendsTo:
    - { type: "alert", to: ["str-property-manager"], when: "calendar conflict detected or channel sync failure" }
    - { type: "finding", to: ["str-property-manager"], when: "listing health score changes or channel-specific issues found" }
    - { type: "finding", to: ["str-pricing-optimizer"], when: "listing availability or channel status changes that affect pricing" }
data:
  entityTypesRead: ["str_properties", "str_channel_listings", "str_bookings", "str_pricing_calendar"]
  entityTypesWrite: ["str_channel_listings", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "channel_quirks", "sync_history"]
zones:
  zone1Read: ["property_count", "primary_channel", "booking_channels"]
  zone2Domains: ["channel-ops", "revenue"]
egress:
  mode: "restricted"
  allowedDomains: ["api.airbnb.com", "ws.airbnb.com", "api.vrbo.com", "app.lodgify.com", "graph.facebook.com"]
skills:
  - ref: "skills/channel-listing-sync@1.0.0"
requirements:
  minTier: "starter"
---

# Channel Manager

Manages multi-platform listing distribution for short-term rental properties. Keeps availability, pricing, and content synchronized across Airbnb, VRBO, Lodgify, and Facebook Marketplace.

## What It Does

- Monitors availability calendar consistency across all booking channels
- Detects and alerts on double-booking risks before they become cancellations
- Tracks listing health scores per platform (search ranking, completeness, photo freshness)
- Identifies channel-specific compliance issues (minimum photo counts, description lengths, amenity requirements)
- Reports sync failures and API issues to Property Manager

## Platform-Specific Knowledge

Each booking platform has different requirements and quirks:
- **Airbnb**: Superhost status depends on response rate, no cancellations, 4.8+ rating
- **VRBO**: Premiere Partner requires instant booking, competitive pricing, photo quality
- **Lodgify**: Direct booking site sync, custom domain management, payment processing
- **Facebook Marketplace**: Informal tone, local market focus, engagement-driven visibility
