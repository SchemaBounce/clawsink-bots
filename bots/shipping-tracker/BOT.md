---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: shipping-tracker
  displayName: "Shipping Tracker"
  version: "1.0.4"
  description: "Monitors shipment status changes and detects delivery issues."
  category: ecommerce
  tags: ["shipping", "logistics", "tracking", "cdc"]
agent:
  capabilities: ["logistics", "tracking"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
  instructions: |
    ## Operating Rules
    - ALWAYS read `carrier_performance` memory before evaluating a shipment event — compare current transit time against carrier historical averages to detect true delays vs. normal variance.
    - ALWAYS read `route_patterns` memory to check if the shipping route has known delay patterns (e.g., customs bottlenecks, regional weather) before classifying an event as exceptional.
    - NEVER classify a shipment as "delayed" based on a single status update — require either an explicit carrier exception code or transit time exceeding the SLA by >20%.
    - NEVER send an alert to executive-assistant for individual shipment delays — only systemic carrier failures affecting multiple shipments qualify as critical.
    - Send delivery status updates to order-fulfillment (finding) for every meaningful state change — delivered, delayed, exception, or returned. Order-fulfillment depends on this for SLA tracking.
    - When order-fulfillment sends a tracking request for a newly shipped order, create the initial tracking record and begin monitoring the shipment lifecycle.
    - Update `carrier_performance` memory with actual delivery times after every completed shipment — this builds the statistical baseline for delay detection.
    - Update `route_patterns` memory when new route-specific patterns emerge (e.g., consistent 2-day delays on a specific corridor).
    - When a delivery exception occurs (damaged, refused, returned), include the exception code and recommended next action in the shipping_alerts record.
    - Process shipment CDC events promptly — stale tracking data leads to late customer notifications and SLA breaches going undetected.
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
trigger:
  entityType: "shipments"
  eventType: "updated"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "order-fulfillment"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
    - { type: "finding", to: ["order-fulfillment"], when: "delivery status update — delivered, delayed, or exception" }
data:
  entityTypesRead: ["shipments", "delivery_slas"]
  entityTypesWrite: ["shipping_alerts", "delivery_predictions"]
  memoryNamespaces: ["carrier_performance", "route_patterns"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["operations"]
egress:
  mode: "restricted"
  allowedDomains: ["onlinetools.ups.com", "apis.fedex.com", "api.usps.com", "api-eu.dhl.com"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/cdc-event-analysis@1.0.0"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-carrier-api
      name: "Connect carrier API"
      description: "Links your shipping carrier so the bot can pull tracking updates"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source for shipment status updates and delivery confirmations"
      ui:
        icon: truck
        actionLabel: "Connect Carrier"
        helpUrl: "https://docs.schemabounce.com/integrations/shipping"
    - id: set-delivery-slas
      name: "Define delivery SLAs"
      description: "Set expected delivery timeframes by service level so delays are detected accurately"
      type: north_star
      key: delivery_slas
      group: configuration
      priority: required
      reason: "Cannot classify shipments as delayed without SLA baselines"
      ui:
        inputType: json
        placeholder: '{"standard": "5 days", "express": "2 days", "overnight": "1 day"}'
    - id: import-shipments
      name: "Import active shipments"
      description: "Seed existing in-transit shipments so monitoring starts immediately"
      type: data_presence
      entityType: shipments
      minCount: 1
      group: data
      priority: required
      reason: "Bot needs shipment records to monitor — without them there is nothing to track"
      ui:
        actionLabel: "Import Shipments"
        emptyState: "No shipments found. Import via CSV or connect your e-commerce platform."
    - id: set-carrier-list
      name: "Set active carriers"
      description: "Specify which carriers you use so performance is tracked per carrier"
      type: config
      group: configuration
      target: { namespace: carrier_performance, key: active_carriers }
      priority: recommended
      reason: "Enables per-carrier delay detection and performance comparison"
      ui:
        inputType: text
        placeholder: "ups, fedex, usps, dhl"
    - id: connect-slack
      name: "Connect Slack for alerts"
      description: "Posts critical shipping exceptions and systemic carrier failures to your ops channel"
      type: mcp_connection
      ref: tools/slack
      group: connections
      priority: recommended
      reason: "Real-time team alerting for delivery exceptions and carrier outages"
      ui:
        icon: slack
        actionLabel: "Connect Slack"
goals:
  - name: track_shipment_updates
    description: "Process shipment status changes and create shipping_alerts records"
    category: primary
    metric:
      type: count
      entity: shipping_alerts
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when new shipment events exist"
  - name: delay_detection_accuracy
    description: "Correctly identify true delays vs normal carrier variance"
    category: primary
    metric:
      type: rate
      numerator: { entity: shipping_alerts, filter: { feedback: "confirmed_delay" } }
      denominator: { entity: shipping_alerts, filter: { alert_type: "delayed", feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.80
      period: weekly
    feedback:
      enabled: true
      entityType: shipping_alerts
      actions:
        - { value: confirmed_delay, label: "Was actually delayed" }
        - { value: false_alarm, label: "Arrived on time" }
        - { value: expected_variance, label: "Normal for this route" }
  - name: carrier_baseline_growth
    description: "Build carrier performance baselines from completed deliveries"
    category: health
    metric:
      type: count
      source: memory
      namespace: carrier_performance
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: prediction_timeliness
    description: "Flag delays before the customer-promised delivery date passes"
    category: secondary
    metric:
      type: threshold
      measurement: pct_flagged_before_sla
    target:
      operator: ">"
      value: 0.90
      period: weekly
---

# Shipping Tracker

Tracks shipment status changes in real-time. Predicts delays, detects exceptions, and proactively notifies customers.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
