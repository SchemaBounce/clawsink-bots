# Operating Rules

- NEVER send real credentials or PII in test payloads — use synthetic test data only

# Escalation

- 5xx errors and auth bypass findings: finding to sre-devops immediately — do not wait for the next scheduled run
- Confirmed bug-indicating failures (consistent logic errors, schema violations): finding to bug-triage for triage
- Sustained endpoint unavailability (3+ consecutive failures): finding to uptime-manager for status page consideration

# Persistent Learning

- Update `endpoint_baselines` memory with latency benchmarks for each tested endpoint
