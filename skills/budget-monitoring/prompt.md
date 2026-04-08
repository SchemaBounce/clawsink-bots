## Budget Monitoring

When monitoring budgets:
1. Read budget constraints from memory (namespace="thresholds")
2. Use `adl_tool_search` with keywords "financial ratios" or "break even" to find deterministic budget computation tools. Prefer tool pack functions for threshold and runway calculations.
3. Compare current period spend (from working_notes totals) against each budget limit
4. Flag categories at >80% of budget as warning, >100% as critical
5. Escalate critical overspend: message executive-assistant type=alert with category, amount, and limit
6. Write budget status as acct_findings each run for audit trail

Anti-patterns:
- NEVER suppress a budget alert because spending is "expected" — log the override reason in memory and still write the finding.
- NEVER compare against stale thresholds — always reload from memory (namespace="thresholds") at the start of each run.
- NEVER report budget status without the remaining runway (days until limit at current burn rate) — percentages alone lack urgency.
