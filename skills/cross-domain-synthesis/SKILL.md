---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: cross-domain-synthesis
  displayName: "Cross-Domain Synthesis"
  version: "1.0.0"
  description: "Identifies patterns and correlations across multiple business domains."
  tags: ["management", "analysis", "cross-domain", "patterns"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_write_memory", "adl_tool_search"]
data:
  producesEntityTypes: ["ea_findings"]
  consumesEntityTypes: ["sre_findings", "acct_findings", "cs_findings", "ba_findings", "mktg_findings"]
---
# Cross-Domain Synthesis

Detects patterns that span multiple domains -- for example, an infrastructure issue causing support ticket spikes that affect revenue projections.
