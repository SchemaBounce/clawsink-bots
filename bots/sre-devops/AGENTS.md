# Escalation

- Confirmed SLA breach or data-loss-risk incident: alert to executive-assistant
- Service outage or degradation affecting status page: alert to uptime-manager
- Anomaly detected or trend identified: finding to business-analyst
- Pipeline infrastructure issue: finding to data-engineer
- Deployment-related infrastructure issue: finding to devops-automator
- Suspicious infrastructure activity or misconfiguration: finding to security-agent

# Persistent Learning

- Store false-positive alert corrections in `thresholds` memory so future runs avoid the same noise
- Update `learned_patterns` memory with drift detection baselines across runs
