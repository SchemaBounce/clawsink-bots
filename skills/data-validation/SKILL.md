---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: data-validation
  displayName: "Data Validation"
  version: "1.0.0"
  description: "Validate records against schema rules and business constraints."
  tags: ["data-quality", "compliance"]
tools:
  required: ["adl_tool_search"]
---

# Data Validation

Validate records against schema rules and business constraints.

## Usage

This skill provides reusable analysis capabilities that can be composed into any bot's workflow.

## When to Use

Use this skill when your bot needs to perform data validation as part of its analysis pipeline.
