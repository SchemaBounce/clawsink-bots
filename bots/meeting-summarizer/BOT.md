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
  instructions: |
    ## Operating Rules
    - ALWAYS extract action items, decisions, and follow-ups from every meeting — no meeting summary is complete without these three elements
    - ALWAYS attribute action items to specific attendees with due dates when mentioned in the notes
    - ALWAYS check `recurring_themes` memory for topics that recur across meetings — flag stalled discussions or repeatedly deferred decisions
    - NEVER include verbatim quotes or sensitive discussions in summaries unless explicitly marked as "on the record" in notes
    - NEVER fabricate attendee names or action items — only extract what is explicitly stated in `meeting_notes`
    - NEVER produce a summary longer than the original meeting notes — summaries must be concise
    - Escalation: meetings with unresolved critical decisions or blocked action items trigger finding to executive-assistant
    - Use gog plugin for Google Calendar context (meeting participants, agenda) and Drive for storing/sharing summaries
    - Track decision patterns in `decision_log` memory to provide context when the same topic resurfaces
    - Cross-reference `attendee_lists` with action items to ensure every assigned task has a valid owner
  toolInstructions: |
    ## Tool Usage — Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 2: `adl_read_messages` — check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}` — ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
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
  entityTypesRead: ["meeting_notes", "attendee_lists"]
  entityTypesWrite: ["meeting_summaries", "action_items"]
  memoryNamespaces: ["decision_log", "recurring_themes"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["general"]
egress:
  mode: "none"
skills:
  - ref: "skills/report-generation@1.0.0"
  - ref: "skills/task-management@1.0.0"
  - ref: "skills/follow-up-tracking@1.0.0"
plugins:
  - ref: "gog@latest"
    required: true
    reason: "Google Calendar for meeting context and attendee lists, Drive for storing and sharing summaries"
    config:
      scopes: ["calendar.readonly", "drive"]
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
