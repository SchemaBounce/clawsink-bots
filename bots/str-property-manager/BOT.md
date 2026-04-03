---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-property-manager
  displayName: "Property Manager"
  version: "1.0.2"
  description: "Lead coordinator for short-term rental operations — consolidates reports, manages portfolio dashboard, coordinates specialists."
  category: operations
  tags: ["str", "property-management", "portfolio", "coordination", "lead", "hospitality"]
agent:
  capabilities: ["management", "operations", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "portfolio-management"
  instructions: |
    ## Operating Rules
    - Always read str_findings and str_alerts from ALL specialist bots before generating a daily briefing — missing a bot's output creates blind spots in portfolio visibility.
    - Never override a specialist bot's recommendation directly — send a request back to the originating bot with approval, rejection, or modification instructions.
    - Treat all alerts (type="alert" from any bot) as requiring acknowledgment within the current run — log the response action taken in str_findings.
    - Escalation hierarchy: operational alerts (turnover, sync) are self-handled; financial alerts (pricing anomalies) require human notification; guest emergencies always trigger immediate human notification.
    - Cross-domain coordination: when review trends indicate a recurring property issue, send a request to str-turnover-coordinator to investigate during the next cleaning cycle.
    - Daily briefings sent to all specialist bots must include: portfolio occupancy, revenue summary, active alerts, and any pending coordination requests.
    - When updating str_properties records, always include the status field (active, blocked, maintenance, seasonal) — downstream bots filter by property status.
    - Use portfolio_health namespace to track week-over-week KPI trends; use learned_patterns namespace for cross-domain correlations discovered over time.
    - Never include raw financial transaction details in briefings distributed to non-finance bots — summarize at portfolio level.
    - When multiple bots report conflicting information about the same property, flag it as a finding and request clarification from both bots before taking action.
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
    light: "@daily"
    standard: "@daily"
    intensive: "@every 4h"
messaging:
  listensTo:
    - { type: "alert", from: ["*"] }
    - { type: "finding", from: ["str-channel-manager", "str-guest-communicator", "str-pricing-optimizer", "str-property-marketer", "str-turnover-coordinator", "str-review-manager"] }
    - { type: "text", from: ["*"] }
  sendsTo:
    - { type: "text", to: ["str-channel-manager", "str-guest-communicator", "str-pricing-optimizer", "str-property-marketer", "str-turnover-coordinator", "str-review-manager"], when: "daily portfolio briefing distribution" }
    - { type: "request", to: ["str-channel-manager", "str-pricing-optimizer", "str-turnover-coordinator"], when: "cross-domain coordination needed" }
data:
  entityTypesRead: ["str_properties", "str_bookings", "str_channel_listings", "str_pricing_calendar", "str_messages", "str_guests", "str_reviews", "str_turnovers", "str_findings", "str_alerts", "crm_contacts", "fin_transactions"]
  entityTypesWrite: ["str_properties", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "portfolio_health", "learned_patterns"]
zones:
  zone1Read: ["property_count", "primary_channel", "target_occupancy_rate", "market_type", "average_nightly_rate", "check_in_method", "cleaning_service", "booking_channels"]
  zone2Domains: ["portfolio-management", "channel-ops", "guest-relations", "revenue", "marketing", "operations"]
egress:
  mode: "none"
skills:
  - ref: "skills/daily-briefing@1.0.0"
  - ref: "skills/cross-domain-synthesis@1.0.0"
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send daily portfolio briefings and critical alerts to property owners"
  - ref: "tools/exa"
    required: false
    reason: "Research local market trends, regulatory changes, and property management best practices"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse booking platform dashboards and local government sites for regulatory updates"
  - ref: "tools/elevenlabs"
    required: false
    reason: "Generate voice briefings for property owners who prefer audio updates"
  - ref: "tools/agentphone"
    required: false
    reason: "Make urgent calls to property owners for critical maintenance or guest emergencies"
  - ref: "tools/composio"
    required: true
    reason: "Connect to property management platforms for portfolio-wide operations and reporting"
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
    - id: connect-pms
      name: "Connect property management platform"
      description: "Links your PMS for portfolio-wide operations, reporting, and coordination"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Central integration for portfolio data, property status, and cross-bot coordination"
      ui:
        icon: property
        actionLabel: "Connect PMS"
        helpUrl: "https://docs.schemabounce.com/integrations/property-management"
    - id: setup-email
      name: "Verify email identity"
      description: "Bot sends daily portfolio briefings and critical alerts to property owners"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Owner communication, daily briefings, and emergency alerts require email capability"
      ui:
        icon: email
        actionLabel: "Verify Email"
    - id: set-property-count
      name: "Set property count"
      description: "Number of properties in the portfolio — drives briefing scope and alert thresholds"
      type: north_star
      key: property_count
      group: configuration
      priority: required
      reason: "Portfolio-level KPIs and alert thresholds scale with property count"
      ui:
        inputType: text
        placeholder: "5"
        helpUrl: "https://docs.schemabounce.com/bots/str-property-manager/setup"
    - id: set-target-occupancy
      name: "Set target occupancy rate"
      description: "Portfolio occupancy goal — used in daily briefings and performance tracking"
      type: north_star
      key: target_occupancy_rate
      group: configuration
      priority: required
      reason: "Daily briefings compare actual occupancy against this target to flag underperformance"
      ui:
        inputType: text
        placeholder: "75"
    - id: set-market-type
      name: "Set market type"
      description: "Market context for seasonal adjustments and cross-domain coordination"
      type: north_star
      key: market_type
      group: configuration
      priority: recommended
      reason: "Seasonal patterns and market benchmarks differ by market type"
      ui:
        inputType: select
        options:
          - { value: urban, label: "Urban / City" }
          - { value: beach, label: "Beach / Coastal" }
          - { value: mountain, label: "Mountain / Ski" }
          - { value: rural, label: "Rural / Countryside" }
          - { value: lake, label: "Lake / Waterfront" }
    - id: import-properties
      name: "Import property records"
      description: "Property data is the foundation for all portfolio management"
      type: data_presence
      entityType: str_properties
      minCount: 1
      group: data
      priority: required
      reason: "Cannot generate briefings, track status, or coordinate bots without property records"
      ui:
        actionLabel: "Import Properties"
        emptyState: "No properties found. Connect your PMS to import your portfolio."
goals:
  - name: daily_briefing_delivery
    description: "Produce and distribute daily portfolio briefings to all specialist bots"
    category: primary
    metric:
      type: count
      entity: str_findings
      filter: { category: "daily_briefing" }
    target:
      operator: ">="
      value: 1
      period: daily
    feedback:
      enabled: true
      entityType: str_findings
      actions:
        - { value: useful, label: "Useful briefing" }
        - { value: missing_data, label: "Missing data" }
        - { value: too_long, label: "Too detailed" }
  - name: alert_acknowledgment
    description: "All specialist bot alerts are acknowledged and actioned within the same run"
    category: primary
    metric:
      type: rate
      numerator: { entity: str_findings, filter: { category: "alert_response" } }
      denominator: { entity: str_alerts, filter: { status: "received" } }
    target:
      operator: ">"
      value: 0.95
      period: weekly
  - name: portfolio_status_coverage
    description: "Every property has an up-to-date status (active, blocked, maintenance, seasonal)"
    category: secondary
    metric:
      type: rate
      numerator: { entity: str_properties, filter: { status: "exists" } }
      denominator: { entity: str_properties }
    target:
      operator: "=="
      value: 1.0
      period: weekly
  - name: cross_domain_coordination
    description: "Detect and act on cross-domain correlations (e.g., review trends triggering cleaning changes)"
    category: secondary
    metric:
      type: count
      entity: str_findings
      filter: { category: "cross_domain" }
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "when correlations exist across specialist domains"
  - name: portfolio_health_tracking
    description: "Maintain week-over-week KPI trend data for portfolio performance"
    category: health
    metric:
      type: count
      source: memory
      namespace: portfolio_health
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Property Manager

The lead coordinator for a short-term rental operations team. This bot consolidates outputs from all six specialists — channel management, guest communication, pricing, marketing, turnovers, and reviews — into a unified portfolio dashboard and daily owner briefing.

## What It Does

- Reads all findings and alerts from every specialist bot in the team
- Produces daily portfolio briefings: occupancy pipeline, revenue trends, operational flags
- Tracks property status across the portfolio (active, blocked, maintenance, seasonal)
- Coordinates cross-domain actions (e.g., pricing adjustments triggered by review trends)
- Manages escalation — receives all critical alerts and determines human-owner notification

## Recommended Setup

Ensure these North Star keys are filled:
- `property_count` — Number of properties in the portfolio
- `primary_channel` — Main booking platform (Airbnb, VRBO, etc.)
- `target_occupancy_rate` — Target occupancy percentage (e.g., 75%)
- `market_type` — Market type (urban, beach, mountain, rural)
- `average_nightly_rate` — Average nightly rate across portfolio
- `booking_channels` — All active booking channels
