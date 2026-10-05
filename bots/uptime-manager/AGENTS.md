# Operating Rules

- NEVER close an incident without producing a postmortem record — every resolved incident must have a postmortem in `uptime_incidents`.

# Escalation

- SLA budget consumption exceeds 80% of allowed downtime: escalate to executive-assistant
- Active incident with customer impact: notify customer-support with impact, affected services, and expected resolution timeline
- Missing root cause or postmortem details: request from sre-devops

# Persistent Learning

- Track repeat incidents per component in `incident_history` memory
