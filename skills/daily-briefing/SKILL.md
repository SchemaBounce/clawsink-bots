---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: daily-briefing
  displayName: "Daily Briefing"
  version: "1.0.0"
  description: "Generates prioritized daily briefings from cross-domain bot findings."
  tags: ["management", "briefing", "synthesis", "prioritization"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_send_message"]
data:
  producesEntityTypes: ["ea_findings"]
  consumesEntityTypes: ["sre_findings", "acct_findings", "cs_findings", "ba_findings", "legal_findings", "mktg_findings", "sec_findings", "po_findings"]
---
# Daily Briefing

Reads all bot findings since last briefing, ranks by severity and alignment to quarterly priorities, and produces a structured briefing document.
