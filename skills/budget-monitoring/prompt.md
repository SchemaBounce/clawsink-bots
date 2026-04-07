## Budget Monitoring

When monitoring budgets:
1. Read budget constraints from memory (namespace="thresholds")
2. Compare current period spend (from working_notes totals) against each budget limit
3. Flag categories at >80% of budget as warning, >100% as critical
4. Escalate critical overspend: message executive-assistant type=alert with category, amount, and limit
5. Write budget status as acct_findings each run for audit trail

Anti-patterns:
- NEVER suppress a budget alert because spending is "expected" — log the override reason in memory and still write the finding.
- NEVER compare against stale thresholds — always reload from memory (namespace="thresholds") at the start of each run.
- NEVER report budget status without the remaining runway (days until limit at current burn rate) — percentages alone lack urgency.
