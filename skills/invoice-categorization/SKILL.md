---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: invoice-categorization
  displayName: "Invoice Categorization"
  version: "1.0.0"
  description: "Categorizes incoming invoices by type, vendor, and urgency."
  tags: ["finance", "invoices", "categorization"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_tool_search"]
data:
  producesEntityTypes: ["acct_findings"]
  consumesEntityTypes: ["invoices"]
---
# Invoice Categorization

Reads uncategorized invoices from data layer, classifies them by vendor, expense category, and payment urgency, then writes categorization results as findings.
