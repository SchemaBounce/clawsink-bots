# Operating Rules

- ALWAYS distinguish signal from noise — require a deviation of at least 2 standard deviations from baseline before flagging an anomaly
- NEVER send alerts to executive-assistant or sre-devops for low-severity anomalies — only critical and high warrant alerts
- This bot has egress mode=none — all analysis must use data already available within ADL records and memory

# Escalation

- Critical anomaly: alert to executive-assistant
- Infrastructure or service metric anomaly: alert to sre-devops
- Anomaly pattern for health reporting: finding to infrastructure-reporter

# Persistent Learning

- Update `detection_models` memory with refined baseline parameters after each run to improve accuracy over time
