---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: meeting-summarizer
  displayName: "Meeting Summarizer"
  version: "1.0.3"
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
presence:
  email:
    required: true
    provider: agentmail
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/report-generation@1.0.0"
  - ref: "skills/task-management@1.0.0"
  - ref: "skills/follow-up-tracking@1.0.0"
plugins:
  - ref: "gog@latest"
    required: true
    reason: "Google Calendar for meeting context and attendee lists, Drive for storing and sharing summaries"
    config:
      scopes: ["calendar.readonly", "drive"]
mcpServers:
  - ref: "tools/notion"
    required: false
    reason: "Publishes meeting summaries and action items to Notion pages"
  - ref: "tools/agentmail"
    required: true
    reason: "Email meeting summaries, action items, and follow-up reminders to attendees"
  - ref: "tools/composio"
    required: false
    reason: "Connect to calendar and project management tools for meeting context and task assignment"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-google-workspace
      name: "Connect Google Workspace"
      description: "Links Google Calendar and Drive for meeting context and summary storage"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Calendar provides meeting context, attendees, and agendas; Drive stores summaries"
      ui:
        icon: google
        actionLabel: "Connect Google Workspace"
        helpUrl: "https://docs.schemabounce.com/integrations/google"
    - id: connect-agentmail
      name: "Connect email for summaries"
      description: "Enables emailing meeting summaries and action item reminders to attendees"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Primary delivery channel for meeting summaries and follow-up reminders"
      ui:
        icon: email
        actionLabel: "Connect Email"
    - id: set-mission
      name: "Set organization mission"
      description: "Helps the bot prioritize which decisions and action items are most relevant"
      type: north_star
      key: mission
      group: configuration
      priority: recommended
      reason: "Mission context improves summary relevance and action item prioritization"
      ui:
        inputType: textarea
        placeholder: "e.g., We build real-time data infrastructure for enterprises"
    - id: import-meeting-notes
      name: "Import initial meeting notes"
      description: "Provides baseline data for the bot to start generating summaries"
      type: data_presence
      entityType: meeting_notes
      minCount: 1
      group: data
      priority: required
      reason: "The bot needs meeting notes to process — without input data it cannot run"
      ui:
        actionLabel: "Add Meeting Notes"
        emptyState: "No meeting notes found. Paste notes, upload a transcript, or connect your calendar."
        helpUrl: "https://docs.schemabounce.com/bots/meeting-summarizer/getting-started"
    - id: connect-notion
      name: "Connect Notion for summaries"
      description: "Publishes meeting summaries and action items directly to Notion pages"
      type: mcp_connection
      ref: tools/notion
      group: connections
      priority: optional
      reason: "Team knowledge base integration for searchable meeting history"
      ui:
        icon: notion
        actionLabel: "Connect Notion"
goals:
  - name: extract_action_items
    description: "Extract clear, attributed action items from every meeting"
    category: primary
    metric:
      type: count
      entity: action_items
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when meeting notes exist"
  - name: summary_completeness
    description: "Every processed meeting produces a structured summary"
    category: primary
    metric:
      type: rate
      numerator: { entity: meeting_summaries }
      denominator: { entity: meeting_notes, filter: { status: "processed" } }
    target:
      operator: ">="
      value: 1.0
      period: per_run
  - name: recurring_theme_tracking
    description: "Identify and flag topics that recur across multiple meetings"
    category: health
    metric:
      type: count
      source: memory
      namespace: recurring_themes
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: summary_delivery
    description: "Summaries delivered to attendees promptly after processing"
    category: secondary
    metric:
      type: boolean
      check: email_sent_after_summary
    target:
      operator: "=="
      value: true
      period: per_run
---

# Meeting Summarizer

Processes meeting notes into structured summaries. Extracts action items, decisions, and follow-ups.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
