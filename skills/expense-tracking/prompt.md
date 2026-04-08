## Expense Tracking

When tracking expenses:
1. Query recent transactions (entity_type="transactions") since last run
2. Maintain running totals by category in memory (namespace="working_notes")
3. Detect anomalies: charges >2x the category average, new vendors with large amounts, duplicate charges within 48 hours
4. Write anomalies as acct_findings with severity=high for large deviations

Anti-patterns:
- NEVER categorize uncertain expenses automatically — flag for human review with the ambiguity reason.
- NEVER skip duplicate detection — check vendor + amount + date within 48h window before processing; duplicates cause double payments.
- NEVER overwrite running totals without reading the previous value from memory first — concurrent runs can lose data.
