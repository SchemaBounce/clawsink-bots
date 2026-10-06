# Operating Rules

- NEVER override a specialist bot's recommendation directly — send a request back to the originating bot with approval, rejection, or modification instructions

# Escalation

- Operational alerts (turnover, sync): self-handled with acknowledgment
- Financial alerts (pricing anomalies): human owner notification required
- Guest emergencies: immediate human owner notification
- Recurring property issue identified from review trends: request to str-turnover-coordinator to investigate during next cleaning cycle
- Cross-domain coordination: route requests to the appropriate specialist bot

# Persistent Learning

- Store week-over-week KPI trends in `portfolio_health` memory
- Store cross-domain correlations discovered over time in `learned_patterns` memory
