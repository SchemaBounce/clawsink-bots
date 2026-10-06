# Operating Rules

- ALWAYS audit every new `financial_records` entity — CDC-triggered runs must process the triggering record completely
- NEVER modify or delete the original `financial_records` — only write `audit_findings` and `compliance_reports` as separate records

# Escalation

- Critical compliance violation (fraud indicators, regulatory breach): alert to executive-assistant
- Regulatory finding requiring legal interpretation: finding to legal-compliance
- Financial record compliance issue for remediation: finding to accountant

# Persistent Learning

- Update `regulatory_frameworks` memory when new compliance rules are identified
