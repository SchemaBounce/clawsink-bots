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
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 20000
  estimatedCostTier: "medium"
schedule:
  default: "@every 2h"
  recommendations:
    light: "@every 4h"
    standard: "@every 2h"
    intensive: "@every 30m"
messaging:
  listensTo:
    - { type: "request", from: ["str-property-manager"] }
    - { type: "text", from: ["str-property-manager"] }
  sendsTo:
    - { type: "alert", to: ["str-property-manager"], when: "calendar conflict detected or channel sync failure" }
    - { type: "finding", to: ["str-property-manager"], when: "listing health score changes or channel-specific issues found" }
data:
  entityTypesRead: ["str_properties", "str_channel_listings", "str_bookings", "str_pricing_calendar"]
  entityTypesWrite: ["str_channel_listings", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "channel_quirks", "sync_history"]
zones:
  zone1Read: ["property_count", "primary_channel", "booking_channels"]
  zone2Domains: ["channel-ops"]
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
