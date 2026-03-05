---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: bug-triage
  displayName: "Bug Triage"
  version: "1.0.0"
  description: "Triages bug reports by severity and assigns owners."
  category: engineering
  tags: ["bugs", "triage", "severity"]
agent:
  capabilities: ["bug_analysis", "prioritization"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
  maxTokenBudget: 50000
schedule:
  default: null
  manual: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["bug_reports", "team_capacity"]
  entityTypesWrite: ["triage_decisions", "severity_scores"]
  memoryNamespaces: ["bug_patterns", "resolution_times"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Bug Triage

Triages incoming bug reports. Analyzes severity, identifies root causes, and assigns to appropriate team members.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
