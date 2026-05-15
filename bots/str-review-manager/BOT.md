---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-review-manager
  displayName: "Review Manager"
  version: "1.0.6"
  description: "Monitors reviews across all platforms, drafts host responses, identifies feedback patterns, tracks rating trends."
  category: support
  tags: ["str", "review-management", "reputation", "guest-feedback", "ratings", "hospitality"]
agent:
  capabilities: ["customer_support", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "guest-relations"
  instructions: |
    ## Operating Rules
    - Always query existing str_reviews for a property before analyzing trends, single-review conclusions are misleading, patterns require at least 5 reviews.
    - Never post a review response directly to any platform. Send drafts to str-guest-communicator as findings for approval, ensuring consistent guest-facing voice.
    - Escalate any review rated 3 stars or below as an alert to both str-guest-communicator and str-property-manager, negative reviews require immediate attention.
    - When identifying recurring negative themes (3+ mentions of the same issue), send a finding to str-property-manager with the specific theme, affected property, and review count.
    - Send recurring positive themes to str-property-marketer as findings so they can be highlighted in listing descriptions, include exact guest phrases that resonate.
    - Tailor response tone per platform: warm/personal on Airbnb, professional/solution-oriented on VRBO, brand-consistent on Lodgify, never defensive on any platform.
    - For negative reviews, always acknowledge the issue, express regret, and describe a concrete improvement, generic apologies damage credibility more than no response.
    - Track per-property rating trends over rolling 30-day and 90-day windows. Flag any property dropping below 4.5 average to str-property-manager.
    - Store response templates and effective response patterns in response_templates namespace; store cross-property feedback themes in review_patterns namespace.
    - Never include guest PII (full names, contact info) in findings or alerts. Use guest_id or booking_id references only.
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
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
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/review-response-generation@1.0.0"
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send review summaries, rating trend alerts, and response drafts to property owners"
  - ref: "tools/exa"
    required: false
    reason: "Search for review management best practices and competitor review patterns"
  - ref: "tools/hyperbrowser"
    required: true
    reason: "Browse Airbnb, VRBO, and Lodgify review pages to monitor new reviews and ratings"
  - ref: "tools/composio"
    required: false
    reason: "Connect to review management and reputation monitoring platforms"
presence:
  email:
    required: true
    provider: agentmail
  web:
    browsing: true
    search: true
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-agentmail
      name: "Connect AgentMail"
      description: "Send review summaries, rating trend alerts, and response drafts to property owners"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Review alerts and response drafts must be delivered to property owners for approval"
      ui:
        icon: agentmail
        actionLabel: "Connect AgentMail"
    - id: connect-hyperbrowser
      name: "Connect Hyperbrowser"
      description: "Browse Airbnb, VRBO, and Lodgify review pages to monitor new reviews and ratings"
      type: mcp_connection
      ref: tools/hyperbrowser
      group: connections
      priority: required
      reason: "Direct platform browsing is the primary method for discovering new reviews across channels"
      ui:
        icon: hyperbrowser
        actionLabel: "Connect Hyperbrowser"
    - id: set-booking-channels
      name: "Define review platforms"
      description: "Select which booking platforms to monitor for reviews"
      type: north_star
      key: booking_channels
      group: configuration
      priority: required
      reason: "Review monitoring scope must match where properties are listed, different platforms require different response tones"
      ui:
        inputType: multi-select
        options:
          - { value: airbnb, label: "Airbnb" }
          - { value: vrbo, label: "VRBO" }
          - { value: lodgify, label: "Lodgify" }
          - { value: booking_com, label: "Booking.com" }
          - { value: google, label: "Google Reviews" }
        default: [airbnb]
    - id: import-properties
      name: "Import property listings"
      description: "Property data is needed to track per-property rating trends"
      type: data_presence
      entityType: str_properties
      minCount: 1
      group: data
      priority: required
      reason: "Per-property rating trend analysis requires knowing which properties to monitor"
      ui:
        actionLabel: "Import Properties"
        emptyState: "No properties found. Import property listings so reviews can be tracked per property."
    - id: import-reviews
      name: "Seed initial reviews"
      description: "Import existing reviews to establish rating baselines and detect trend direction"
      type: data_presence
      entityType: str_reviews
      minCount: 5
      group: data
      priority: recommended
      reason: "Pattern analysis requires at least 5 reviews, single-review conclusions are misleading"
      ui:
        actionLabel: "Import Reviews"
        emptyState: "No reviews found. Import existing reviews from your platforms to establish baseline ratings."
    - id: connect-exa
      name: "Connect Exa for best practices"
      description: "Search for review management strategies and competitor review response patterns"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: recommended
      reason: "Industry best practices improve response quality and reputation management strategy"
      ui:
        icon: exa
        actionLabel: "Connect Exa"
goals:
  - name: review_response_coverage
    description: "Draft responses for all new reviews to maintain high host response rate"
    category: primary
    metric:
      type: rate
      numerator: { entity: str_reviews, filter: { response_drafted: true } }
      denominator: { entity: str_reviews, filter: { status: "new" } }
    target:
      operator: ">="
      value: 0.95
      period: weekly
  - name: negative_review_escalation
    description: "Escalate all reviews rated 3 stars or below within the same run cycle"
    category: primary
    metric:
      type: rate
      numerator: { entity: str_alerts, filter: { alert_type: "negative_review" } }
      denominator: { entity: str_reviews, filter: { rating_lte: 3 } }
    target:
      operator: "=="
      value: 1.0
      period: per_run
      condition: "when negative reviews exist"
  - name: rating_trend_monitoring
    description: "Track per-property rating trends and flag properties dropping below 4.5 average"
    category: health
    metric:
      type: boolean
      check: review_patterns_namespace_updated
    target:
      operator: "=="
      value: true
      period: per_run
  - name: positive_theme_sharing
    description: "Share recurring positive guest themes with str-property-marketer for listing optimization"
    category: secondary
    metric:
      type: count
      entity: str_findings
      filter: { finding_type: "positive_theme", recipient: "str-property-marketer" }
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "when recurring positive themes are detected"
---

# Review Manager

Monitors the reputation layer of short-term rental operations. Reviews are the lifeblood of vacation rental visibility, a 4.8 rating on Airbnb vs. a 4.6 can mean a 30% difference in booking inquiries. This bot watches every review across every platform and keeps the host's response game sharp.

## What It Does

- Monitors new reviews across Airbnb, VRBO, Lodgify, and other active platforms
- Drafts professional host responses tailored to each platform's tone
- Identifies recurring themes in negative feedback (e.g., "Three guests mentioned noise from the street")
- Tracks per-property rating trends over time, flags properties trending downward
- Escalates negative reviews (3 stars or below) through Guest Communicator to Property Manager
- Sends response drafts to Guest Communicator for approval before posting

## Response Tone Strategy

- **Airbnb**: Warm, personal, conversational, reference specific details from the stay
- **VRBO**: Professional, appreciative, solution-oriented, emphasize family-friendly improvements
- **Lodgify**: Direct, brand-consistent, link back to direct booking benefits
- **Negative reviews**: Acknowledge, apologize, explain improvements made, never defensive

## Support Role

This bot reports to Guest Communicator (not directly to Property Manager). Response drafts go to Guest Communicator for approval, ensuring consistent guest-facing voice. Cross-property patterns and rating trend analysis are shared with Property Manager for strategic decisions.
