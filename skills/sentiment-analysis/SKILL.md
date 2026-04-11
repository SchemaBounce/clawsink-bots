---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: sentiment-analysis
  displayName: "Sentiment Analysis"
  version: "1.0.0"
  description: "Analyze text sentiment and classify as positive, negative, or neutral."
  tags: ["nlp", "social"]
tools:
  required: ["adl_tool_search"]
---

# Sentiment Analysis

Analyze text sentiment and classify as positive, negative, or neutral.

## Usage

This skill provides reusable analysis capabilities that can be composed into any bot's workflow.

## When to Use

Use this skill when your bot needs to perform sentiment analysis as part of its analysis pipeline.
