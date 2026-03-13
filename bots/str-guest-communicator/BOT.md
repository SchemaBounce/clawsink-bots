---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-guest-communicator
  displayName: "Guest Communicator"
  version: "1.0.0"
  description: "Auto-responds to guest messages across all channels — handles pre-booking, check-in, during-stay, and post-stay communication."
  category: support
  tags: ["str", "guest-communication", "messaging", "superhost", "response-time", "hospitality"]
agent:
  capabilities: ["customer_support", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "guest-relations"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 15000
  estimatedCostTier: "high"
schedule:
  default: "@every 15m"
  recommendations:
    light: "@every 30m"
    standard: "@every 15m"
    intensive: "@every 5m"
messaging:
  listensTo:
    - { type: "alert", from: ["str-review-manager"] }
    - { type: "request", from: ["str-property-manager"] }
    - { type: "text", from: ["str-property-manager", "str-review-manager"] }
  sendsTo:
    - { type: "alert", to: ["str-property-manager"], when: "guest emergency or escalation-worthy request" }
    - { type: "finding", to: ["str-property-manager"], when: "response time metrics or communication patterns identified" }
data:
  entityTypesRead: ["str_messages", "str_bookings", "str_guests", "str_properties"]
  entityTypesWrite: ["str_messages", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "guest_context", "response_templates"]
zones:
  zone1Read: ["property_count", "primary_channel", "check_in_method", "booking_channels"]
  zone2Domains: ["guest-relations"]
skills:
  - ref: "skills/guest-message-templating@1.0.0"
requirements:
  minTier: "starter"
---

# Guest Communicator

The front line of guest interaction. Runs every 15 minutes to maintain Superhost-level response times across all booking platforms. Handles the full guest communication lifecycle from initial inquiry through post-stay follow-up.

## What It Does

- Responds to pre-booking inquiries with property-specific details (amenities, location, house rules)
- Sends check-in instructions at the right moment (24 hours before arrival, with door codes and directions)
- Fields during-stay requests — wifi passwords, thermostat location, local restaurant recommendations
- Queues post-stay thank-you messages and review requests
- Escalates emergencies (lockouts, plumbing issues, safety concerns) to Property Manager immediately

## Why 15-Minute Intervals Matter

Booking platforms reward fast responses:
- **Airbnb**: Response rate directly affects Superhost status and search ranking
- **VRBO**: Premiere Partner status requires consistent responsiveness
- Guests who don't hear back within an hour typically book elsewhere

## Communication Tone

Adapts tone per platform — casual and warm on Airbnb, slightly more formal on VRBO, friendly and direct on Facebook Marketplace. Always professional, never robotic. Uses the guest's name and references their specific booking details.
