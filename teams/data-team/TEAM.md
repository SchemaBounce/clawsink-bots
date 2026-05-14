---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: data-team
  displayName: "Data"
  version: "1.0.0"
  description: "Data engineering team monitoring pipeline health, data quality, anomaly detection, and infrastructure reporting"
  domain: data
  category: data
  tags: ["data", "pipelines", "quality", "anomaly-detection", "infrastructure", "monitoring"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/data-engineer@1.0.0"
  - ref: "bots/data-quality-monitor@1.0.0"
  - ref: "bots/anomaly-detector@1.0.0"
  - ref: "bots/infrastructure-reporter@1.0.0"
  - ref: "bots/business-analyst@1.0.0"
dataKits:
  - ref: "data-kits/data@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Data Engineering"
  context: "Data team managing pipeline reliability, data quality enforcement, anomaly detection, and infrastructure health reporting"
  requiredKeys:
    - data_sources
    - quality_rules
    - anomaly_thresholds
    - pipeline_slas
    - alert_channels
orgChart:
  lead: data-engineer
  domains:
    - name: "Data Infrastructure"
      description: "Pipeline health, connector uptime, schema drift, and platform reliability"
      head: data-engineer
      children:
        - name: "Infrastructure Reporting"
          description: "Daily platform health briefings and drift reports"
          head: infrastructure-reporter
    - name: "Data Quality"
      description: "Validation rules, freshness checks, completeness monitoring"
      head: data-quality-monitor
      children:
        - name: "Anomaly Detection"
          description: "Statistical and rule-based outlier detection on tables and streams"
          head: anomaly-detector
    - name: "Analytics"
      description: "Business analysis, trend identification, and insight delivery"
      head: business-analyst
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
      reportsTo: data-engineer
      domain: data-infrastructure
    - bot: business-analyst
      role: specialist
      reportsTo: data-engineer
      domain: analytics
  escalation:
    critical: data-engineer
    unhandled: data-engineer
    paths:
      - name: "Pipeline Failure"
        trigger: "pipeline_failure"
        chain: [data-quality-monitor, data-engineer]
      - name: "Data Quality Breach"
        trigger: "quality_breach"
        chain: [data-quality-monitor, anomaly-detector, data-engineer]
      - name: "Infrastructure Degradation"
        trigger: "infra_degraded"
        chain: [infrastructure-reporter, data-engineer]
      - name: "Anomaly Spike"
        trigger: "anomaly_spike"
        chain: [anomaly-detector, data-engineer]
---
# Data

Five bots covering the full data operations lifecycle: pipeline health management, data quality monitoring, anomaly detection, infrastructure reporting, and business analytics. The Data Engineer leads the team and owns overall platform reliability.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Data Engineer | Lead, pipeline health, schema drift monitoring | @every 6h |
| Data Quality Monitor | Validation rules, freshness and completeness checks | @every 1h |
| Anomaly Detector | Statistical and rule-based outlier detection | @every 1h |
| Infrastructure Reporter | Platform health briefings and drift summaries | @every 6h |
| Business Analyst | Trend analysis, insight delivery, business reporting | @daily |

## How They Work Together

The Data Engineer is the central coordinator, owning pipeline reliability and platform health. Data Quality Monitor runs continuous validation against declared rules and feeds findings to Anomaly Detector for deeper statistical analysis. Infrastructure Reporter collects health signals from the platform and produces consolidated briefings for the Data Engineer. Business Analyst transforms validated data into business insights and flags trends that may indicate upstream data issues.

**Communication flow:**
- Data Quality Monitor detects rule violation -> alert to Data Engineer
- Data Quality Monitor flags data freshness issue -> finding to Anomaly Detector
- Anomaly Detector detects spike or outlier -> alert to Data Engineer
- Infrastructure Reporter detects platform degradation -> alert to Data Engineer
- Business Analyst identifies data-driven trend -> finding to Data Engineer
- Data Engineer coordinates pipeline remediation -> request to Data Quality Monitor

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `data_sources`, `quality_rules`, `anomaly_thresholds`, `pipeline_slas`, `alert_channels`
3. Bots begin running on their default schedules automatically
4. Check the Data Engineer's briefings for consolidated platform health status
