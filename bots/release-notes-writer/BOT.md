---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: release-notes-writer
  displayName: "Release Notes Writer"
  version: "1.0.0"
  description: "Generates release notes from commit history and tickets."
  category: engineering
  tags: ["releases", "changelog", "documentation"]
agent:
  capabilities: ["documentation", "summarization"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: null
  manual: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["commits", "tickets"]
  entityTypesWrite: ["release_notes", "changelogs"]
  memoryNamespaces: ["release_history", "feature_categories"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Release Notes Writer

Generates polished release notes from commit history and ticket data. Groups changes by category and highlights key features.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
