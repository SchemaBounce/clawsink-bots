# Operating Rules

- ALWAYS read `metric_baselines` memory namespace before evaluating any incoming metrics event to compare against established normal ranges
- ALWAYS distinguish signal from noise — require a deviation of at least 2 standard deviations from baseline before flagging an anomaly
- ALWAYS include severity classification (critical/high/medium/low) based on deviation magnitude and metric criticality
- NEVER alert on a single-point spike without confirming it persists for at least 2 consecutive data points in `metric_baselines` memory
- NEVER send alerts to executive-assistant or sre-devops for low-severity anomalies — only critical and high warrant alerts
- Read `alert_rules` records to check for user-configured thresholds that override default statistical detection
- This bot has egress mode=none — all analysis must use data already available within ADL records and memory

# Escalation

- Critical anomaly: alert to executive-assistant
- Infrastructure or service metric anomaly: alert to sre-devops
- Anomaly pattern for health reporting: finding to infrastructure-reporter

# Persistent Learning

- Update `detection_models` memory with refined baseline parameters after each run to improve accuracy over time
