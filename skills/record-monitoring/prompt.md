## Record Monitoring

1. Load monitoring rules, policies, and thresholds from memory.
2. Use `adl_tool_search` with keywords "validate" or "detect pii" to find deterministic monitoring tools. Prefer tool pack functions for schema validation and PII detection.
3. Query all monitored_records in your assigned domain scope.
4. Check each record systematically against every applicable rule. Do not skip records.
5. For each violation, classify severity (critical, high, medium, low) based on the rule definition.
6. Write a monitoring_findings record for each violation with the rule violated, record ID, and severity.
7. If any critical violations are found, write a compliance_alerts record for immediate attention.
8. Update monitoring state in memory with the run timestamp and summary counts.
9. Ensure full coverage: log the total records checked and total violations found.

Anti-patterns:
- NEVER alert on a single record change in isolation — require a pattern of 3+ violations or a critical-severity rule match before escalating.
- NEVER skip records during monitoring — partial coverage gives false confidence; log total checked to prove completeness.
- NEVER run monitoring without loading current rules from memory first — stale rules produce false positives and miss new policy requirements.
