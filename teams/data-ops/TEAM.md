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
---

# Data Ops

A comprehensive data operations team. Monitors data quality, detects anomalies, reports infrastructure health, and manages pipeline reliability.

## Included Bots

- **Data Quality Monitor** — CDC-triggered, validates every incoming record
- **Anomaly Detector** — CDC-triggered, statistical anomaly detection on metrics
- **Infrastructure Reporter** — Scheduled every 6 hours, health summaries
- **Data Engineer** — Scheduled every 6 hours, pipeline health monitoring

## Target Market

Data teams, analytics teams, and platform engineering teams.
