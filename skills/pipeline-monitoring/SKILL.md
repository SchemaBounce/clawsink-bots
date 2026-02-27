---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: pipeline-monitoring
  displayName: "Pipeline Monitoring"
  version: "1.0.0"
  description: "Monitors CDC pipeline health metrics including throughput, latency, and DLQ depth."
  tags: ["operations", "pipelines", "monitoring", "cdc"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_write_memory"]
data:
  producesEntityTypes: ["sre_findings"]
  consumesEntityTypes: ["pipeline_status"]
---
# Pipeline Monitoring

Checks pipeline health metrics (throughput, latency, error rates, DLQ depth) against learned baselines and flags deviations.
