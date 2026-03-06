## Record Monitoring

1. Load monitoring rules, policies, and thresholds from memory.
2. Query all monitored_records in your assigned domain scope.
3. Check each record systematically against every applicable rule. Do not skip records.
4. For each violation, classify severity (critical, high, medium, low) based on the rule definition.
5. Write a monitoring_findings record for each violation with the rule violated, record ID, and severity.
6. If any critical violations are found, write a compliance_alerts record for immediate attention.
7. Update monitoring state in memory with the run timestamp and summary counts.
8. Ensure full coverage: log the total records checked and total violations found.
