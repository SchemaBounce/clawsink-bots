---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: anomaly-detector
  displayName: "Anomaly Detector"
  version: "1.0.1"
  description: "Detects statistical anomalies in time-series metrics data."
  category: engineering
  tags: ["anomaly", "metrics", "monitoring", "cdc"]
agent:
  capabilities: ["anomaly_detection", "monitoring"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS read `metric_baselines` memory namespace before evaluating any incoming metrics event to compare against established normal ranges
    - ALWAYS distinguish signal from noise -- require a deviation of at least 2 standard deviations from baseline before flagging an anomaly
    - ALWAYS include severity classification (critical/high/medium/low) based on deviation magnitude and metric criticality
    - NEVER alert on a single-point spike without confirming it persists for at least 2 consecutive data points in `metric_baselines` memory
    - NEVER send alerts to executive-assistant or sre-devops for low-severity anomalies -- only critical and high warrant alerts
    - Escalate critical anomalies to executive-assistant (type=alert) and infrastructure/service metric anomalies to sre-devops (type=alert)
    - Send anomaly patterns to infrastructure-reporter (type=finding) so they are included in periodic health reports
    - Read `alert_rules` records to check for user-configured thresholds that override default statistical detection
    - Update `detection_models` memory namespace with refined baseline parameters after each run to improve accuracy over time
    - This bot has egress mode=none -- all analysis must use data already available within ADL records and memory
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
  entityType: "metrics"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical anomaly detected" }
    - { type: "alert", to: ["sre-devops"], when: "infrastructure or service metric anomaly" }
    - { type: "finding", to: ["infrastructure-reporter"], when: "anomaly pattern for infrastructure health reporting" }
data:
  entityTypesRead: ["metrics", "alert_rules"]
  entityTypesWrite: ["anomaly_findings", "anomaly_alerts"]
  memoryNamespaces: ["metric_baselines", "detection_models"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering", "operations"]
egress:
  mode: "none"
skills:
  - ref: "skills/anomaly-detection@1.0.0"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: configure-metric-baselines
      name: "Set metric baselines"
      description: "Configure initial baseline values for key metrics so the bot can detect deviations from normal ranges."
      type: config
      group: configuration
      priority: required
      reason: "The bot compares incoming metrics against baselines stored in the metric_baselines memory namespace. Without initial baselines, all values appear normal."
      ui:
        target:
          namespace: "metric_baselines"
          key: "initial_baselines"
    - id: seed-metrics-entity
      name: "Seed metrics records"
      description: "Ensure at least a few metrics records exist so the bot has data to analyze on first run."
      type: data_presence
      group: data
      priority: required
      reason: "The bot is CDC-triggered on entityType=metrics. Without existing records, it has no historical context for comparison."
      ui:
        entityType: "metrics"
        minCount: 5
    - id: configure-alert-rules
      name: "Configure alert rules"
      description: "Optionally seed alert_rules records with custom thresholds that override default statistical detection."
      type: data_presence
      group: data
      priority: recommended
      reason: "User-configured thresholds in alert_rules override default 2-sigma detection, letting operators tune sensitivity per metric."
      ui:
        entityType: "alert_rules"
        minCount: 1
    - id: set-north-star-mission
      name: "Define North Star mission"
      description: "Set the workspace North Star mission so the bot understands which metrics matter most to the business."
      type: north_star
      group: configuration
      priority: required
      reason: "The bot reads zone1 mission to prioritize which anomalies are critical vs informational."
      ui:
        key: "mission"
    - id: verify-sre-devops-active
      name: "Ensure SRE/DevOps bot is active"
      description: "The anomaly detector escalates infrastructure anomalies to sre-devops. Confirm that bot is deployed."
      type: manual
      group: external
      priority: recommended
      reason: "Critical and high-severity infrastructure anomalies are sent to sre-devops. Without it, those alerts go unprocessed."
      ui:
        instructions: "Deploy the sre-devops bot from the marketplace, or confirm it is already active in your workspace."
goals:
  - id: anomalies-detected
    name: "Anomalies detected"
    description: "Total anomaly findings written across all severity levels."
    metricType: count
    target: "> 0 per week"
    category: primary
    feedback:
      question: "Are the detected anomalies relevant and actionable?"
      options: ["yes", "mostly", "too noisy", "missing real issues"]
  - id: critical-alert-rate
    name: "Critical alert accuracy"
    description: "Percentage of critical/high alerts that corresponded to real incidents."
    metricType: rate
    target: "> 80%"
    category: primary
    feedback:
      question: "Were critical alerts genuine issues that needed attention?"
      options: ["yes", "some false positives", "mostly false positives"]
  - id: baseline-freshness
    name: "Baseline freshness"
    description: "The metric_baselines memory namespace is updated after each run."
    metricType: boolean
    target: "updated within last 24h"
    category: health
  - id: detection-latency
    name: "Detection latency"
    description: "Time between metric record creation and anomaly finding generation."
    metricType: threshold
    target: "< 5 minutes"
    category: primary
---

# Anomaly Detector

Detects anomalies in incoming metrics using statistical analysis. Identifies spikes, drops, trend breaks, and seasonal deviations.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
