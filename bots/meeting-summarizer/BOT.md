---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: meeting-summarizer
  displayName: "Meeting Summarizer"
  version: "1.0.0"
  description: "Summarizes meeting notes and creates action items."
  category: productivity
  tags: ["meetings", "notes", "actions"]
agent:
  capabilities: ["summarization", "task_extraction"]
  hostingMode: "openclaw"
  defaultDomain: "general"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
schedule:
  default: null
  manual: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["meeting_notes", "attendee_lists"]
  entityTypesWrite: ["meeting_summaries", "action_items"]
  memoryNamespaces: ["decision_log", "recurring_themes"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["general"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Meeting Summarizer

Processes meeting notes into structured summaries. Extracts action items, decisions, and follow-ups.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
