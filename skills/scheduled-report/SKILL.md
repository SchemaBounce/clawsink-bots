---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: scheduled-report
  displayName: "Scheduled Report"
  version: "1.0.0"
  description: "Produces periodic findings by querying domain data on a schedule and synthesizing insights."
  tags: ["reporting", "scheduled", "analytics", "synthesis"]
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_write_memory", "adl_send_message"]
data:
  consumesEntityTypes: ["domain_records"]
  producesEntityTypes: ["periodic_findings", "periodic_reports"]
---
# Scheduled Report

Produces periodic findings by querying domain data on a schedule, synthesizing trends and changes into structured reports. Uses memory to track cursor state so each run only analyzes new data since the last execution.

## When to Use

Use this skill in bots that run on a cron schedule and need to produce incremental summaries, trend reports, or periodic digests.

## Typical Bots

Business analytics bots, executive briefing bots, SRE weekly summaries, and compliance audit bots.
