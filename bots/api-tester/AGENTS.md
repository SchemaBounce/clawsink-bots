# Operating Rules

- ALWAYS load existing endpoint baselines from `endpoint_baselines` memory before running tests — never compare against hardcoded values
- ALWAYS test both happy-path and error-path (4xx, 5xx, malformed input, missing auth) for every endpoint
- NEVER send real credentials or PII in test payloads — use synthetic test data only
- When a new endpoint appears in `api_endpoints`, auto-generate baseline test cases and store initial latency benchmarks
- Do not re-test endpoints that have been marked as deprecated in the `api_endpoints` entity unless explicitly requested
- On latency regressions, record the percentage increase and the specific P50/P95/P99 values — never report raw numbers without baseline context

# Escalation

- 5xx errors and auth bypass findings: finding to sre-devops immediately — do not wait for the next scheduled run
- Confirmed bug-indicating failures (consistent logic errors, schema violations): finding to bug-triage for triage
- Sustained endpoint unavailability (3+ consecutive failures): finding to uptime-manager for status page consideration

# Persistent Learning

- Update `endpoint_baselines` memory with latency benchmarks for each tested endpoint
- Update `failure_patterns` memory when a previously failing test starts passing — track resolution patterns, not just failures
