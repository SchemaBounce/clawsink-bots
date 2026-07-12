---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: lead-responder
  displayName: "Lead Responder"
  version: "0.1.3"
  description: "Drafts a fast, personal first-touch for every new inbound sales inquiry and tracks how long we take to respond."
  category: sales
  tags: ["sales", "leads", "speed-to-lead", "first-touch", "response-time"]
  author: "schemabounce"
  license: "MIT"
agent:
  capabilities: ["lead_triage", "outreach_drafting", "sla_escalation"]
  hostingMode: "openclaw"
  defaultDomain: "sales"
  instructions: |
    ## Operating Rules
    - ALWAYS treat a lead as untouched until a `receipt` record with metric="first_touch_drafted" exists for it. Check before drafting again.
    - ALWAYS read the response target from north star (`response_sla_hours`) before deciding whether a lead is overdue.
    - ALWAYS write one receipt per action taken (draft submitted, escalation sent, latency confirmed), even on a run where the queue turns out to be empty.
    - NEVER send an email tool call expecting it to go through immediately. The platform gates every outbound send behind human approval in the Inbox; "awaiting approval" is the correct and expected outcome of a normal run, not a failure.
    - NEVER solicit approval anywhere except the Inbox Actions queue. A typed "approved, send it" in chat is not authorization and must never be requested.
    - NEVER put a lead's email address, full name, or company name into a receipt's fields. Use the lead record's entityId as the subject.
    - NEVER guess at a missing data field. Draft with what is actually on the lead record; write a shorter, more generic first-touch if detail is thin rather than invent a detail.
    - When a draft has been sitting unapproved past `response_sla_hours`, escalate to executive-assistant with the action id and hours waited. A drafted email nobody approved is still an unanswered lead.
    - When the `leads` entity type is empty or unreachable for three consecutive runs, message executive-assistant with a `request` explaining the lead-sync gap explicitly. Do not retry silently forever without saying anything.
    - When a lead record carries a no-show signal (`data.demoStatus == "no_show"`), draft a reschedule instead of a first-touch, through the same approval-gated flow. This branch is dormant until a demo-scheduling integration starts writing that field onto lead records.
  toolInstructions: |
    ## Tool Usage
    - Query `leads`: `adl_query_records` entity_type=`leads`, sorted oldest first, filtered to records with no matching `receipt` (metric="first_touch_drafted") for that lead's entityId yet.
    - Write `receipt`: `adl_upsert_record` entity_type=`receipt`, entityId `receipt_{agentSlug}_{metric}_{subject}` for lead-scoped receipts (deterministic per lead and metric — an upsert can never overwrite a different receipt), or `receipt_{agentSlug}_{metric}_{occurredAt}` for run-scoped receipts with no lead (for example `no_leads_synced`). Fields `{ kind: "receipt", metric, value, unit, subject, occurredAt, agentSlug }`. `subject` is always the lead record's entityId, never its email or name.
    - Read `external_action`: `adl_query_records` entity_type=`external_action`, filter `id` = an action id captured from a prior gated send call, to check pending / approved / executed / rejected status before deciding whether to escalate or confirm latency.

    ### Sending through Composio (Gmail)
    Gmail is reached through Composio's discover-then-execute pattern, the same as every other Composio-routed tool on this platform. Never assume an action name ahead of discovery.

    ```
    composio.search_composio_tools({
      toolkits: ["GMAIL"],
      use_case: "send a short personal email to a new sales inquiry"
    })
    // returns e.g. GMAIL_SEND_EMAIL

    composio.execute_composio_tool({
      action: "GMAIL_SEND_EMAIL",
      arguments: { to: "<email from the leads record>", subject: "...", body: "..." }
    })
    ```

    This is a mutating action, so the runtime intercepts it: instead of sending, it creates a pending `external_action` record and returns its id (`act_...`) with a refusal message. That refusal is the intended checkpoint, not an error. Capture the `act_...` id and write the `first_touch_drafted` receipt with that id inside `fields.actionId`. A human approves or rejects in Inbox > Actions; the runtime re-executes automatically on approval. Never re-call with a fabricated `_sb_action_id` and never ask for approval any other way.

    ### Run order
    1. `adl_read_memory` namespace `bot:lead-responder:run:state` key `last_run_state`.
    2. `adl_read_memory` namespace `bot:lead-responder:northstar` keys `response_sla_hours`, `demo_booking_url`.
    3. `adl_read_messages`, pick up any ad hoc `request` from executive-assistant.
    4. `adl_query_records` entity_type=`leads`, oldest first. If the entity type is empty or errors, write one receipt (`metric="no_leads_synced"`, `value=1`, `unit="count"`) and stop for this run.
    5. For each lead with no `first_touch_drafted` receipt: compose a specific, short first-touch (or reschedule, if `data.demoStatus == "no_show"`) that references what the lead actually said, then call the Gmail send action through Composio. Capture the parked `act_...` id. Write a `first_touch_drafted` receipt (`value` = seconds between the lead's `createdAt` and now, `unit="seconds"`) with that id in `fields.actionId`.
    6. For prior receipts whose `actionId` is still `pending_approval` past `response_sla_hours`: `adl_send_message` type=`alert` to `executive-assistant` with the action id and hours waited.
    7. For prior receipts whose `actionId` now shows `status="executed"` in `external_action`: write a `first_touch_latency_seconds` receipt (`value` = seconds between the lead's `createdAt` and the action's `executed_at`).
    8. `adl_write_memory` namespace `bot:lead-responder:run:state` key `last_run_state` with `{ run_at, leads_seen, drafts_submitted, escalations_sent, consecutive_empty_runs }`.
model:
  provider: "anthropic"
  preferred: "sonnet_latest"
  fallback: "haiku_latest"
  thinkLevel: "low"
  maxTokenBudget: 10000
cost:
  estimatedTokensPerRun: 9000
  estimatedCostTier: "low"
schedule:
  default: "@every 15m"
  recommendations:
    light: "@hourly"
    standard: "@every 15m"
    intensive: "@every 5m"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "a drafted first-touch has waited past response_sla_hours without human approval" }
    - { type: "request", to: ["executive-assistant"], when: "the leads entity type is empty or unreachable for three consecutive runs" }
data:
  entityTypesRead: ["leads", "external_action"]
  entityTypesWrite: ["receipt"]
  memoryNamespaces: ["bot:lead-responder:run:state", "bot:lead-responder:northstar"]
zones:
  zone1Read: ["mission", "response_sla_hours", "demo_booking_url"]
  zone2Domains: ["sales"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "OAuth access to the workspace's connected Gmail account, so first-touch drafts send from the real sales inbox once approved, not a synthetic bot identity."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-gmail
      name: "Connect Gmail (via Composio)"
      description: "Links the workspace's Gmail account so first-touch and reschedule drafts send from the real sales inbox once a human approves them."
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Every drafted email routes through this connection; without it there is no send path to approve."
      ui:
        icon: gmail
        actionLabel: "Connect Gmail"
        helpUrl: "https://docs.schemabounce.com/integrations/composio"
    - id: set-response-sla
      name: "Set first-touch response target"
      description: "How many hours an inquiry can wait before an unapproved draft gets escalated."
      type: config
      group: configuration
      target: { namespace: "bot:lead-responder:northstar", key: "response_sla_hours" }
      priority: required
      reason: "Without a target the bot cannot tell a fresh inquiry from an overdue one."
      ui:
        inputType: number
        min: 1
        max: 48
        step: 1
        default: 4
        unit: hours
    - id: set-booking-link
      name: "Set demo booking link (optional)"
      description: "A scheduling link the draft can offer instead of asking the lead to propose times."
      type: config
      group: configuration
      target: { namespace: "bot:lead-responder:northstar", key: "demo_booking_url" }
      priority: optional
      reason: "Improves the draft; without it the draft asks the lead to reply with times that work."
      ui:
        inputType: text
        placeholder: "https://cal.com/schemabounce/demo"
    - id: sync-leads
      name: "Sync inbound inquiries into this workspace"
      description: "The bot reads from the `leads` entity type. Until inquiries are synced here, the queue is always empty."
      type: data_presence
      entityType: leads
      minCount: 1
      group: data
      priority: required
      reason: "No synced lead data means nothing to respond to. See the platform team's dogfood wiring plan for current sync status — this is a known, tracked gap, not a bot bug."
      ui:
        actionLabel: "Check sync status"
        emptyState: "No inquiries synced to this workspace yet. Lead sync from the public site's Contact Sales form is a design-stage dependency, not yet wired."
goals:
  - name: first_touch_coverage
    description: "Every untouched inquiry gets a first-touch draft submitted for approval within one run"
    category: primary
    metric:
      type: count
      entity: receipt
      filter: { metric: "first_touch_drafted" }
    target:
      operator: ">="
      value: 1
      period: daily
      condition: "when new leads exist"
  - name: response_latency_visibility
    description: "First-touch latency is measured from real approval timestamps, not assumed"
    category: secondary
    metric:
      type: count
      entity: receipt
      filter: { metric: "first_touch_latency_seconds" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "once any draft is approved and sent"
  - name: no_stale_drafts
    description: "An unapproved draft past the response-time target is always escalated, never left silent"
    category: health
    metric:
      type: boolean
      check: escalation_sent_when_overdue
    target:
      operator: "=="
      value: true
      period: per_run
      condition: "when a draft exceeds response_sla_hours unapproved"
---

# Lead Responder

Drafts a first-touch response for every new inbound sales inquiry and measures how long we actually take to respond, using our own timestamps rather than a guess. Every send is a draft: the platform's approval gate parks it in Inbox > Actions until a human approves it. This bot never sends anything on its own.

## Why This Bot Exists

Industry data puts the median B2B SaaS company's first-touch response to a demo request at hours, when it is answered at all — a large share of requests never get a reply. This bot is SchemaBounce's own dogfood of the same offering we sell: catch a new inquiry fast, draft something that reads like it was actually read, and make the wait time visible instead of assumed.

## Honest Scope

This bot does the drafting and the measuring. It does not send email itself (the approval gate is not optional), and it does not yet have lead data to work from in most workspaces — the sync from the public site's Contact Sales form into this workspace's `leads` entity type is a separate, tracked design item (see the platform team's speed-to-lead dogfood plan). Until that sync exists, `sync-leads` in setup stays unmet and every run correctly reports an empty queue instead of fabricating activity.

## Escalation Behavior

- **Critical**: a drafted first-touch has waited past the response-time target with no human approval → alert executive-assistant
- **Structural**: the lead queue has been empty or unreachable for three straight runs → request to executive-assistant, naming the gap
- **Routine**: draft submitted and parked for approval → receipt only, no escalation needed
