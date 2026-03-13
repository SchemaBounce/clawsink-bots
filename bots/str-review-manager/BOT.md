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
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
cost:
  estimatedTokensPerRun: 18000
  estimatedCostTier: "medium"
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
  sendsTo:
    - { type: "alert", to: ["str-guest-communicator", "str-property-manager"], when: "negative review detected (3 stars or below)" }
    - { type: "finding", to: ["str-guest-communicator"], when: "response drafts ready for review or feedback pattern identified" }
    - { type: "finding", to: ["str-property-manager"], when: "rating trend analysis or cross-property feedback patterns" }
data:
  entityTypesRead: ["str_reviews", "str_bookings", "str_guests", "str_properties"]
  entityTypesWrite: ["str_reviews", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "review_patterns", "response_templates"]
zones:
  zone1Read: ["property_count", "primary_channel", "booking_channels"]
  zone2Domains: ["guest-relations"]
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
