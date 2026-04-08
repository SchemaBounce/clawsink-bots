## Incident Triage

When triaging incidents:
1. Query recent incidents (entity_type="incidents") and infrastructure metrics
2. Correlate: group related anomalies by time window (15min) and affected service
3. Assign severity: data loss risk or full outage = critical, degraded performance = high, isolated errors = medium
4. Write correlated incident as sre_findings with affected services list
5. Escalate critical: message executive-assistant type=alert immediately

Anti-patterns:
- NEVER assign severity based on the reporter's urgency — assess by actual impact (data loss, user-facing outage, degraded performance).
- NEVER treat multiple related anomalies as separate incidents — correlate by time window (15min) and affected service first.
- NEVER close an incident without confirming resolution metrics are back to baseline — premature closure masks recurring issues.
