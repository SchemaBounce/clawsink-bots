---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: cdc-event-analysis
  displayName: "CDC Event Analysis"
  version: "1.0.0"
  description: "Analyzes CDC events to detect patterns, anomalies, and actionable signals in real-time data changes."
  tags: ["cdc", "events", "real-time", "analysis"]
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_write_memory"]
data:
  consumesEntityTypes: ["cdc_events"]
  producesEntityTypes: ["event_findings", "event_alerts"]
---
# CDC Event Analysis

Analyzes incoming CDC events to detect patterns, anomalies, and actionable signals in real-time data changes. The skill reads the specific triggering event, compares it against baseline patterns stored in memory, classifies severity, and writes findings or alerts as needed.

## When to Use

Use this skill in bots that react to real-time CDC event streams and need to classify or triage individual change events as they arrive.

## Typical Bots

SRE monitors, fraud detection bots, data quality watchers, and any bot that processes CDC-triggered workflows.
