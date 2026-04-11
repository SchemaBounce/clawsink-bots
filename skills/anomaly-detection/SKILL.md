---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: anomaly-detection
  displayName: "Anomaly Detection"
  version: "1.0.0"
  description: "Statistical anomaly detection on numeric fields using z-score and IQR methods."
  tags: ["analytics", "data-quality"]
tools:
  required: ["adl_query_records", "adl_upsert_record", "adl_send_message", "adl_tool_search"]
---

# Anomaly Detection

Statistical anomaly detection on numeric fields using z-score and IQR methods.

## Usage

This skill provides reusable analysis capabilities that can be composed into any bot's workflow.

## When to Use

Use this skill when your bot needs to perform anomaly detection as part of its analysis pipeline.
