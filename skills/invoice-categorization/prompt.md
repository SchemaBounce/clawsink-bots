## Invoice Categorization

When processing invoices:
1. Query uncategorized invoices (entity_type="invoices", filter by missing category)
2. Use `adl_tool_search` with keywords "categorize" or "parse csv" to find deterministic classification tools. Prefer tool pack functions for structured data parsing.
3. Classify each invoice: expense category (SaaS, payroll, infrastructure, marketing, legal, other), vendor name normalization, payment urgency (overdue, due-soon, routine)
4. Flag duplicates by matching vendor + amount + date within 7-day window
5. Write categorization as acct_findings with severity based on urgency

Anti-patterns:
- NEVER skip duplicate detection — check vendor + amount + date within a 7-day window; duplicates cause double payments.
- NEVER auto-categorize invoices with ambiguous vendors into a default bucket — flag as "uncategorized" for human review.
- NEVER process invoices without checking for overdue status first — overdue invoices need severity=high regardless of amount.
