---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: data-ops
  displayName: "Data Ops"
  version: "1.0.0"
  description: "Data quality monitoring, anomaly detection, infrastructure health, and pipeline management."
  tags: ["data", "quality", "infrastructure", "monitoring"]
  targetMarket: "data-teams"
bots:
  - data-quality-monitor
  - anomaly-detector
  - infrastructure-reporter
  - data-engineer
skills:
  - anomaly-detection
  - data-validation
  - report-generation
requirements:
  minTier: "starter"
orgChart:
  lead: data-engineer
  domains:
    - name: "Data Infrastructure"
      description: "Pipeline health, connector uptime, schema drift"
      head: data-engineer
      children:
        - name: "Infrastructure Reporting"
          description: "Daily platform-health briefings and drift reports"
          head: infrastructure-reporter
    - name: "Data Quality"
      description: "Validation rules, freshness, completeness"
      head: data-quality-monitor
      children:
        - name: "Anomaly Detection"
          description: "Statistical + rule-based outlier detection on tables and streams"
          head: anomaly-detector
  roles:
    - bot: data-engineer
      role: lead
      reportsTo: null
      domain: data-infrastructure
    - bot: data-quality-monitor
      role: specialist
      reportsTo: data-engineer
      domain: data-quality
    - bot: anomaly-detector
      role: specialist
      reportsTo: data-engineer
      domain: data-quality
    - bot: infrastructure-reporter
      role: support
      reportsTo: data-quality-monitor
      domain: data-infrastructure
  escalation:
    critical: data-engineer
    unhandled: data-engineer
    paths:
      - name: "Pipeline failure"
        trigger: "pipeline_failure"
        chain: [data-quality-monitor, data-engineer]
      - name: "Data quality breach"
        trigger: "quality_breach"
        chain: [data-quality-monitor, anomaly-detector, data-engineer]
---

# Data Ops

A comprehensive data operations team. Monitors data quality, detects anomalies, reports infrastructure health, and manages pipeline reliability.

## Included Bots

- **Data Quality Monitor**: CDC-triggered, validates every incoming record
- **Anomaly Detector**: CDC-triggered, statistical anomaly detection on metrics
- **Infrastructure Reporter**: Scheduled every 6 hours, health summaries
- **Data Engineer**: Scheduled every 6 hours, pipeline health monitoring

## Target Market

Data teams, analytics teams, and platform engineering teams.
