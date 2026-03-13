---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-turnover-coordinator
  displayName: "Turnover Coordinator"
  version: "1.0.0"
  description: "Manages cleaning schedules between guests, tracks turnover status, ensures properties are guest-ready, flags maintenance issues."
  category: operations
  tags: ["str", "turnover", "cleaning", "maintenance", "scheduling", "hospitality"]
agent:
  capabilities: ["operations"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@every 4h"
  recommendations:
    light: "@every 8h"
    standard: "@every 4h"
    intensive: "@every 1h"
messaging:
  listensTo:
    - { type: "request", from: ["str-property-manager"] }
    - { type: "text", from: ["str-property-manager"] }
  sendsTo:
    - { type: "alert", to: ["str-property-manager"], when: "late cleaning, missed turnover, or maintenance issue discovered" }
    - { type: "finding", to: ["str-property-manager"], when: "turnover schedule updated or completion status changed" }
data:
  entityTypesRead: ["str_turnovers", "str_bookings", "str_properties"]
  entityTypesWrite: ["str_turnovers", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "cleaner_roster", "maintenance_log"]
zones:
  zone1Read: ["property_count", "cleaning_service", "check_in_method"]
  zone2Domains: ["operations"]
skills:
  - ref: "skills/turnover-scheduling@1.0.0"
requirements:
  minTier: "starter"
---

# Turnover Coordinator

Manages the operational logistics between guests. In short-term rental, the turnover window — the hours between checkout and check-in — is where operational failures happen. This bot ensures every property is cleaned, inspected, and guest-ready on time.

## What It Does

- Generates cleaning assignments based on checkout/check-in schedules
- Tracks turnover completion status in real time
- Alerts immediately when a cleaning is running late or at risk of missing the check-in window
- Flags maintenance issues discovered during turnovers (broken appliances, stains, damage)
- Manages back-to-back booking logistics — tight windows get flagged for priority scheduling
- Tracks cleaner performance metrics (on-time rate, quality scores, availability)

## Why Haiku

Turnover coordination is high-frequency, low-complexity work — schedule matching, status tracking, time math. Haiku handles it efficiently at a fraction of Sonnet's cost, keeping the per-run cost low even at intensive (hourly) schedules.

## Critical Timing

- Standard turnover window: 4-6 hours between checkout (11am) and check-in (3-4pm)
- Back-to-back same-day turnovers are flagged as high priority
- Late turnover alerts fire when cleaning hasn't started 2 hours before check-in
