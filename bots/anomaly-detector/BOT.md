---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: anomaly-detector
  displayName: "Anomaly Detector"
  version: "1.0.0"
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
    ## Tool Usage
    - Query `metrics` records to ingest incoming time-series data points; filter by metric_name and use time-range filters for recent windows
    - Query `alert_rules` records to load user-configured thresholds (metric_name, operator, threshold_value, severity) that override statistical defaults
    - Write `anomaly_findings` with fields: metric_name, timestamp, observed_value, baseline_mean, baseline_stddev, deviation_sigma, severity, anomaly_type (spike/drop/trend_break/seasonal)
    - Write `anomaly_alerts` only for critical/high severity -- include metric_name, deviation_magnitude, recommended_action, and affected_service if known
    - Use `metric_baselines` memory namespace to store per-metric rolling statistics: mean, stddev, min, max, sample_count, last_updated -- update after every run
    - Use `detection_models` memory namespace to store model parameters: seasonal_period, trend_direction, noise_floor, sensitivity_multiplier per metric
    - Batch processing preferred: analyze all metrics from a single CDC trigger together to detect correlated multi-metric anomalies
    - Use `adl_semantic_search` against `anomaly_findings` to check for recurring anomaly patterns before creating duplicate findings
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 5000
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
---

# Anomaly Detector

Detects anomalies in incoming metrics using statistical analysis. Identifies spikes, drops, trend breaks, and seasonal deviations.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
