---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-review-manager
  displayName: "Review Manager"
  version: "1.0.0"
  description: "Monitors reviews across all platforms, drafts host responses, identifies feedback patterns, tracks rating trends."
  category: support
  tags: ["str", "review-management", "reputation", "guest-feedback", "ratings", "hospitality"]
agent:
  capabilities: ["customer_support", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "guest-relations"
  instructions: |
    ## Operating Rules
    - Always query existing str_reviews for a property before analyzing trends — single-review conclusions are misleading, patterns require at least 5 reviews.
    - Never post a review response directly to any platform — send drafts to str-guest-communicator as findings for approval, ensuring consistent guest-facing voice.
    - Escalate any review rated 3 stars or below as an alert to both str-guest-communicator and str-property-manager — negative reviews require immediate attention.
    - When identifying recurring negative themes (3+ mentions of the same issue), send a finding to str-property-manager with the specific theme, affected property, and review count.
    - Send recurring positive themes to str-property-marketer as findings so they can be highlighted in listing descriptions — include exact guest phrases that resonate.
    - Tailor response tone per platform: warm/personal on Airbnb, professional/solution-oriented on VRBO, brand-consistent on Lodgify — never defensive on any platform.
    - For negative reviews, always acknowledge the issue, express regret, and describe a concrete improvement — generic apologies damage credibility more than no response.
    - Track per-property rating trends over rolling 30-day and 90-day windows — flag any property dropping below 4.5 average to str-property-manager.
    - Store response templates and effective response patterns in response_templates namespace; store cross-property feedback themes in review_patterns namespace.
    - Never include guest PII (full names, contact info) in findings or alerts — use guest_id or booking_id references only.
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
    light: "@every 2d"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo:
    - { type: "request", from: ["str-guest-communicator", "str-property-manager"] }
    - { type: "text", from: ["str-guest-communicator", "str-property-manager"] }
    - { type: "finding", from: ["str-guest-communicator"] }
  sendsTo:
    - { type: "alert", to: ["str-guest-communicator", "str-property-manager"], when: "negative review detected (3 stars or below)" }
    - { type: "finding", to: ["str-guest-communicator"], when: "response drafts ready for review or feedback pattern identified" }
    - { type: "finding", to: ["str-property-manager"], when: "rating trend analysis or cross-property feedback patterns" }
    - { type: "finding", to: ["str-property-marketer"], when: "recurring positive themes that should be highlighted in listings" }
data:
  entityTypesRead: ["str_reviews", "str_bookings", "str_guests", "str_properties"]
  entityTypesWrite: ["str_reviews", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "review_patterns", "response_templates"]
zones:
  zone1Read: ["property_count", "primary_channel", "booking_channels"]
  zone2Domains: ["guest-relations"]
egress:
  mode: "restricted"
  allowedDomains: ["api.airbnb.com", "api.vrbo.com", "app.lodgify.com"]
skills:
  - ref: "skills/review-response-generation@1.0.0"
requirements:
  minTier: "starter"
---

# Review Manager

Monitors the reputation layer of short-term rental operations. Reviews are the lifeblood of vacation rental visibility — a 4.8 rating on Airbnb vs. a 4.6 can mean a 30% difference in booking inquiries. This bot watches every review across every platform and keeps the host's response game sharp.

## What It Does

- Monitors new reviews across Airbnb, VRBO, Lodgify, and other active platforms
- Drafts professional host responses tailored to each platform's tone
- Identifies recurring themes in negative feedback (e.g., "Three guests mentioned noise from the street")
- Tracks per-property rating trends over time — flags properties trending downward
- Escalates negative reviews (3 stars or below) through Guest Communicator to Property Manager
- Sends response drafts to Guest Communicator for approval before posting

## Response Tone Strategy

- **Airbnb**: Warm, personal, conversational — reference specific details from the stay
- **VRBO**: Professional, appreciative, solution-oriented — emphasize family-friendly improvements
- **Lodgify**: Direct, brand-consistent — link back to direct booking benefits
- **Negative reviews**: Acknowledge, apologize, explain improvements made — never defensive

## Support Role

This bot reports to Guest Communicator (not directly to Property Manager). Response drafts go to Guest Communicator for approval, ensuring consistent guest-facing voice. Cross-property patterns and rating trend analysis are shared with Property Manager for strategic decisions.
