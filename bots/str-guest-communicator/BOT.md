---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-guest-communicator
  displayName: "Guest Communicator"
  version: "1.0.4"
  description: "Auto-responds to guest messages across all channels — handles pre-booking, check-in, during-stay, and post-stay communication."
  category: support
  tags: ["str", "guest-communication", "messaging", "superhost", "response-time", "hospitality"]
agent:
  capabilities: ["customer_support", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "guest-relations"
  instructions: |
    ## Operating Rules
    - Always query str_messages for the guest's conversation history before composing a reply — context-free responses feel robotic and damage Superhost metrics.
    - Never send a message that includes door codes, wifi passwords, or security details to a guest whose booking status is not "confirmed" — verify via str_bookings first.
    - Escalate immediately to str-property-manager (as alert) for: lockouts, plumbing/electrical emergencies, safety concerns, or any guest threat of legal action.
    - Send check-in/check-out time changes to str-turnover-coordinator as findings so cleaning schedules can adjust — do not assume turnover is aware.
    - After a guest's stay is complete, send a finding to str-review-manager to trigger the post-stay review follow-up sequence.
    - Adapt tone per platform: warm and casual on Airbnb, slightly formal on VRBO, friendly and direct on Facebook Marketplace — but never use slang or emojis in VRBO messages.
    - Never promise refunds, compensation, or policy exceptions — escalate financial requests to str-property-manager.
    - Prioritize unanswered messages by age (oldest first) to protect response-time metrics — a 1-hour-old Airbnb inquiry is more urgent than a 5-minute-old VRBO question.
    - Store reusable response patterns in response_templates namespace; store per-guest context (preferences, issues) in guest_context namespace.
    - Log response time metrics in str_findings after each run so str-property-manager can track Superhost compliance.
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
  default: "@every 15m"
  recommendations:
    light: "@every 30m"
    standard: "@every 15m"
    intensive: "@every 5m"
messaging:
  listensTo:
    - { type: "alert", from: ["str-review-manager", "str-turnover-coordinator"] }
    - { type: "request", from: ["str-property-manager"] }
    - { type: "text", from: ["str-property-manager", "str-review-manager"] }
  sendsTo:
    - { type: "alert", to: ["str-property-manager"], when: "guest emergency or escalation-worthy request" }
    - { type: "finding", to: ["str-property-manager"], when: "response time metrics or communication patterns identified" }
    - { type: "finding", to: ["str-turnover-coordinator"], when: "guest check-in/check-out time changes or early arrival requests" }
    - { type: "finding", to: ["str-review-manager"], when: "guest stay completed — trigger post-stay review follow-up" }
data:
  entityTypesRead: ["str_messages", "str_bookings", "str_guests", "str_properties"]
  entityTypesWrite: ["str_messages", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "guest_context", "response_templates"]
zones:
  zone1Read: ["property_count", "primary_channel", "check_in_method", "booking_channels"]
  zone2Domains: ["guest-relations", "operations"]
egress:
  mode: "restricted"
  allowedDomains: ["api.airbnb.com", "ws.airbnb.com", "api.vrbo.com", "app.lodgify.com", "graph.facebook.com"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/guest-message-templating@1.0.0"
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send and receive guest communications for booking inquiries, check-in instructions, and follow-ups"
  - ref: "tools/exa"
    required: false
    reason: "Search for local restaurant recommendations, attractions, and event info for guest requests"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse booking platform messaging interfaces and local business pages for guest support"
  - ref: "tools/elevenlabs"
    required: false
    reason: "Generate voice messages for personalized guest welcome and check-in instructions"
  - ref: "tools/agentphone"
    required: false
    reason: "Handle urgent guest phone calls for emergencies and time-sensitive requests"
  - ref: "tools/composio"
    required: true
    reason: "Connect to booking platforms for guest messaging and reservation management"
presence:
  email:
    required: true
    provider: agentmail
  web:
    browsing: true
    search: true
  voice:
    required: false
    provider: elevenlabs
  phone:
    required: false
    provider: agentphone
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-booking-platforms
      name: "Connect booking platforms"
      description: "Links your booking platforms for guest messaging and reservation access"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source for guest messages, booking details, and reservation status"
      ui:
        icon: property
        actionLabel: "Connect Platforms"
        helpUrl: "https://docs.schemabounce.com/integrations/booking-platforms"
    - id: setup-email
      name: "Verify email identity"
      description: "Bot sends and receives guest communications via email"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Guest inquiries, check-in instructions, and follow-ups require email capability"
      ui:
        icon: email
        actionLabel: "Verify Email"
    - id: set-check-in-method
      name: "Set check-in method"
      description: "How guests access the property — determines what instructions are sent"
      type: north_star
      key: check_in_method
      group: configuration
      priority: required
      reason: "Check-in instructions vary by method (smart lock, lockbox, in-person) and must be accurate"
      ui:
        inputType: select
        options:
          - { value: smart_lock, label: "Smart Lock (code)" }
          - { value: lockbox, label: "Lockbox" }
          - { value: in_person, label: "In-Person Key Handoff" }
          - { value: keypad, label: "Keypad Entry" }
    - id: set-booking-channels
      name: "Set active booking channels"
      description: "Which platforms guests book through — determines communication tone"
      type: north_star
      key: booking_channels
      group: configuration
      priority: required
      reason: "Tone and format must adapt per platform (casual on Airbnb, formal on VRBO)"
      ui:
        inputType: text
        placeholder: '["airbnb", "vrbo", "lodgify", "facebook_marketplace"]'
    - id: set-access-credentials
      name: "Store property access credentials"
      description: "Door codes, wifi passwords, and entry instructions per property"
      type: secret
      secretName: property_access_credentials
      group: configuration
      priority: required
      reason: "Check-in messages include door codes and wifi — these must be stored securely"
      ui:
        inputType: text
        placeholder: '{"door_code": "****", "wifi_password": "****", "lockbox_location": "..."}'
        helpUrl: "https://docs.schemabounce.com/bots/str-guest-communicator/credentials"
    - id: import-bookings
      name: "Import active bookings"
      description: "Current bookings provide guest context for communication"
      type: data_presence
      entityType: str_bookings
      minCount: 1
      group: data
      priority: recommended
      reason: "Guest context (dates, property, status) is needed to personalize messages"
      ui:
        actionLabel: "Import Bookings"
        emptyState: "No bookings found. Connect your booking platforms to import reservations."
goals:
  - name: response_time
    description: "Respond to guest messages within 15 minutes to protect Superhost status"
    category: primary
    metric:
      type: threshold
      measurement: avg_minutes_to_first_response
    target:
      operator: "<"
      value: 15
      period: daily
    feedback:
      enabled: true
      entityType: str_findings
      actions:
        - { value: helpful, label: "Helpful response" }
        - { value: inaccurate, label: "Inaccurate info" }
        - { value: wrong_tone, label: "Wrong tone" }
  - name: message_coverage
    description: "All guest messages receive a response — no unanswered inquiries"
    category: primary
    metric:
      type: rate
      numerator: { entity: str_messages, filter: { direction: "outbound", in_reply_to: "exists" } }
      denominator: { entity: str_messages, filter: { direction: "inbound", requires_response: true } }
    target:
      operator: ">"
      value: 0.95
      period: weekly
  - name: escalation_accuracy
    description: "Emergencies are escalated immediately — no missed lockouts or safety issues"
    category: secondary
    metric:
      type: count
      entity: str_alerts
      filter: { category: "guest_emergency" }
    target:
      operator: ">="
      value: 0
      period: weekly
      condition: "alerts prove the escalation path is working when emergencies arise"
  - name: response_template_growth
    description: "Build reusable response patterns from successful guest interactions"
    category: health
    metric:
      type: count
      source: memory
      namespace: response_templates
    target:
      operator: ">"
      value: 5
      period: monthly
      condition: "cumulative growth"
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
