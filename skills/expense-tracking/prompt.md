## Expense Tracking

When tracking expenses:
1. Query recent transactions (entity_type="transactions") since last run
2. Use `adl_tool_search` with keywords "financial" or "outlier" to find deterministic computation tools. Prefer tool pack functions for statistical calculations over manual math.
3. Maintain running totals by category in memory (namespace="working_notes")
4. Detect anomalies: charges >2x the category average, new vendors with large amounts, duplicate charges within 48 hours
5. Write anomalies as acct_findings with severity=high for large deviations

Anti-patterns:
- NEVER categorize uncertain expenses automatically — flag for human review with the ambiguity reason.
- NEVER skip duplicate detection — check vendor + amount + date within 48h window before processing; duplicates cause double payments.
- NEVER overwrite running totals without reading the previous value from memory first — concurrent runs can lose data.
