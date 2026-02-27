## Invoice Categorization

When processing invoices:
1. Query uncategorized invoices (entity_type="invoices", filter by missing category)
2. Classify each invoice: expense category (SaaS, payroll, infrastructure, marketing, legal, other), vendor name normalization, payment urgency (overdue, due-soon, routine)
3. Flag duplicates by matching vendor + amount + date within 7-day window
4. Write categorization as acct_findings with severity based on urgency
