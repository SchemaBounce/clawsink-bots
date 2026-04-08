---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: ab-testing
  displayName: "A/B Testing"
  version: "1.0.0"
  description: "Designs, monitors, and evaluates A/B experiments with statistical rigor."
  tags: ["analytics", "experimentation", "growth", "statistics"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_send_message", "adl_tool_search"]
data:
  producesEntityTypes: ["experiment_results", "experiment_recommendations"]
  consumesEntityTypes: ["experiments", "experiment_metrics"]
---
# A/B Testing

Monitors running experiments, calculates statistical significance, and recommends ship/kill decisions.
