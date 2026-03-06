---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: content-scheduler
  displayName: "Content Scheduler"
  version: "1.0.0"
  description: "Plans and schedules content calendar across channels."
  category: marketing
  tags: ["content", "calendar", "planning"]
agent:
  capabilities: ["content_planning", "scheduling"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "0 9 * * 1-5"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["content_calendar", "channel_configs"]
  entityTypesWrite: ["scheduled_posts", "content_plans"]
  memoryNamespaces: ["editorial_calendar", "performance_data"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["marketing"]
skills:
  - ref: "skills/record-monitoring@1.0.0"
plugins:
  - ref: "gog@latest"
    required: true
    reason: "Google Calendar for managing the content publishing schedule and editorial deadlines"
    config:
      scopes: ["calendar.events"]
requirements:
  minTier: "starter"
---

# Content Scheduler

Manages content scheduling across channels. Plans posts, tracks performance, and optimizes publishing times.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
