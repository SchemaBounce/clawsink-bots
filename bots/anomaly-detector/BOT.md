---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: anomaly-detector
  displayName: "Anomaly Detector"
  version: "1.0.7"
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
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/anomaly-detection@1.0.0"
plugins: []
mcpServers: []
# Internal-only by design — first-party platform bot. Detects statistical
# anomalies in time-series metrics stored as ADL records. Reads workspace
# data via adl_query_records / adl_query_duckdb runtime built-ins. No
# third-party MCP, no external SaaS.
requirements:
  minTier: "starter"
setup:
  steps:
    - id: configure-metric-baselines
      name: "Set metric baselines"
      description: "Configure initial baseline values for key metrics so the bot can detect deviations from normal ranges"
      type: config
      group: configuration
      priority: required
      target:
        namespace: metric_baselines
        key: initial_baselines
      reason: "Compares incoming metrics against baselines. Without initial values, all readings appear normal"
      ui:
        inputType: text
        placeholder: '{"cpu_usage": 45, "error_rate": 0.02, "latency_p99": 200}'
    - id: seed-metrics-data
      name: "Import metrics records"
      description: "Ensure metrics records exist so the bot has historical data for anomaly comparison"
      type: data_presence
      entityType: metrics
      minCount: 5
      group: data
      priority: required
      reason: "CDC-triggered on metrics entity. Without historical records, no baseline context for comparison"
      ui:
        actionLabel: "Import Metrics"
        emptyState: "No metrics found. Import initial metrics or wait for your monitoring pipeline to create them."
    - id: set-mission
      name: "Set workspace mission"
      description: "Business context helps prioritize which anomalies are critical vs informational"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Mission context determines which metrics matter most and how anomalies are prioritized"
      ui:
        inputType: text
        placeholder: "e.g., Real-time fraud detection platform for FinTech companies"
    - id: configure-alert-rules
      name: "Configure custom alert rules"
      description: "Custom thresholds that override default 2-sigma statistical detection per metric"
      type: data_presence
      entityType: alert_rules
      minCount: 1
      group: data
      priority: recommended
      reason: "User-configured thresholds in alert_rules let operators tune sensitivity per metric"
      ui:
        actionLabel: "Add Alert Rules"
        emptyState: "No custom alert rules. Default 2-sigma detection will be used."
    - id: verify-sre-devops-active
      name: "Ensure SRE/DevOps bot is active"
      description: "Anomaly detector escalates infrastructure anomalies to sre-devops for incident response"
      type: manual
      group: external
      priority: recommended
      reason: "Critical infrastructure anomalies are routed to sre-devops. Without it, alerts go unprocessed"
      ui:
        actionLabel: "I've verified SRE/DevOps is deployed"
        instructions: "Deploy the sre-devops bot from the marketplace, or confirm it is already active in your workspace."
goals:
  - name: detect_anomalies
    description: "Identify statistical anomalies in incoming metrics data"
    category: primary
    metric:
      type: count
      entity: anomaly_findings
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when new metrics data exists"
    feedback:
      enabled: true
      entityType: anomaly_findings
      actions:
        - { value: relevant, label: "Relevant anomaly" }
        - { value: false_positive, label: "False positive" }
        - { value: missed, label: "Missed a real issue" }
  - name: critical_alert_accuracy
    description: "Percentage of critical/high alerts that correspond to real incidents"
    category: primary
    metric:
      type: rate
      numerator: { entity: anomaly_alerts, filter: { feedback: "relevant" } }
      denominator: { entity: anomaly_alerts, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.8
      period: monthly
    feedback:
      enabled: true
      entityType: anomaly_alerts
      actions:
        - { value: relevant, label: "Real incident" }
        - { value: false_positive, label: "False alarm" }
  - name: detection_latency
    description: "Time from metric record creation to anomaly finding generation"
    category: secondary
    metric:
      type: threshold
      measurement: avg_minutes_to_detect
    target:
      operator: "<"
      value: 5
      period: per_run
  - name: baseline_freshness
    description: "Metric baselines updated regularly from operational experience"
    category: health
    metric:
      type: count
      source: memory
      namespace: detection_models
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Anomaly Detector

Detects anomalies in incoming metrics using statistical analysis. Identifies spikes, drops, trend breaks, and seasonal deviations.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
