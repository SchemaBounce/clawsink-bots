---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: executive-assistant
  displayName: "Executive Assistant"
  version: "1.0.17"
  description: "Synthesizes all bot outputs, prioritizes across domains, delivers daily briefings."
  category: management
  tags: ["synthesis", "briefings", "prioritization", "follow-ups", "coordination"]
agent:
  capabilities: ["management", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "platform-ops"
  instructions: |
    ## Operating Rules
    - ALWAYS read messages from ALL bots before producing a briefing, never skip a domain
    - ALWAYS check `follow_ups` memory namespace at run start to resume tracked action items
    - ALWAYS prioritize findings against North Star `priorities` and `mission`: rank by business impact, not recency
    - NEVER produce a briefing without reading zone1 keys (`mission`, `industry`, `stage`, `priorities`) first
    - NEVER ignore alerts. Every `*_alerts` record must appear in the briefing or be explicitly triaged
    - NEVER modify or delete findings written by other bots, only read and synthesize
    - Escalation: you are the TOP of the chain, do not escalate further; produce the final prioritized output for the human operator
    - Cross-bot coordination: route requests to the right specialist (business-analyst for analysis, accountant for financial data, sre-devops for infrastructure, mentor-coach for team health)
    - When a finding spans multiple domains, tag it as cross-domain and include source bot references
    - Write `ea_findings` for synthesized insights, `ea_alerts` only for items requiring immediate human attention, `tasks` for trackable action items
  toolInstructions: |
    ## Tool Usage

    ### Budget
    - Target 5 to 10 tool calls per run. Hard cap 15. Most runs end with no external calls because no new findings landed.

    ### Run loop (always)
    1. `adl_read_memory` key `last_run_state`: get last run timestamp and pending follow-ups.
    2. `adl_read_messages`: pull new alerts, findings, and requests from other bots.
    3. `adl_query_records` filter `created_at > {last_run_timestamp}` for the entity types declared in `data.entityTypesRead`. One batched query.
    4. If zero new records and no due follow-ups, `adl_write_memory` to bump the timestamp and STOP.
    5. Otherwise: synthesize the briefing, then dispatch via the channel + integration tools below, then write `ea_findings` / `ea_alerts` / `tasks`.

    ### Channel + integration tools

    Every channel and integration is reached through a connected tool. Learn each server's tools from its tool list and descriptions, or find one with `adl_tool_search`; read the description, then call it. Never assume a tool name or argument shape ahead of discovery: guessing fails and burns the run budget.

    **Chat (internal distribution).** Use for the leadership briefing post and for high-priority pings to a named channel. Read recent context first when synthesizing cross-domain items.
    - Post the P0/P1 summary to the leadership briefing channel to publish the briefing.
    - Read recent channel history when an alert references a channel discussion you need context on.
    - Reply in an existing incident thread to attach a follow-up instead of opening a new one.

    **Email delivery (executives).** Primary delivery channel for the daily briefing. The agent's inbox is provisioned via `presence.email`.
    - Confirm the inbox id once per cold start with the connected email tool, then cache it in memory.
    - Send the synthesized briefing to the executive with subject "Daily Briefing for <date>".
    - List recent threads to catch executive replies and feed them back into `follow_ups` memory as new tasks.
    - Answer follow-ups in the existing thread; never start a new thread when one exists.

    **Web search (industry context for briefings).** Run sparingly. Only when a finding from business-analyst or marketing-growth references an external trend that needs a sentence of supporting context.
    - Search for headline framing, or use date-bounded, domain-restricted search for competitor monitoring.
    - Skip it entirely on routine runs. Budget: at most 1 search per briefing.

    **Browser (KPI dashboards behind auth).** Use when a finding cites a metric that the bot needs to verify against a hosted dashboard the agent has credentials for.
    - Scrape static dashboards directly.
    - Use a connected browser tool's agentic mode (for example logging in to an analytics product and reading a weekly active users number) only when scraping is blocked by JS rendering. It is expensive; prefer a connected analytics tool first if available.

    **Audio briefings (opt-in).** Skip unless the executive has explicitly requested an audio version. The user opts in via setup; if they have not, do not generate audio. When opted in, produce audio of a briefing summary (max 90 seconds) and attach it to the email.

    **Calendar, mail, docs and meetings (any connected tool).** Find the tool for each job by description, then call it.
    - Calendar: find free 30 minute slots, create a meeting with the recommended attendees (request a video link if the briefing mentions a video meeting), and list upcoming events for the next 24 hours to surface the morning agenda.
    - Mailbox, read-only triage during synthesis: list unread important emails from the last 24 hours, or pull a single conversation when an alert points at one. Never use the mailbox tool to send the briefing itself.
    - Documents: create a document with the briefing for longer-form weekly retrospectives, or append findings to an existing one.
    - Video meetings: when the briefing schedules a meeting that needs a specific video product, create it and embed the join URL in the calendar event description.

    ### Order of operations
    1. ADL reads first (memory, messages, records). No external call until you know there is something to brief on.
    2. Chat channel history second when synthesizing items that reference a thread, so the briefing has accurate context.
    3. Calendar, video meetings and documents before delivery, so the briefing can include scheduled follow-ups.
    4. Email and chat post last, because once the briefing is out, retraction is awkward.
    5. Memory write last (`adl_write_memory` with new timestamp + open follow-ups) so a partial run does not skip work next cycle.

    ### What not to do
    - Do not call a tool you have not first seen in a server's tool list or an `adl_tool_search` result in this run. Tool names drift between server releases.
    - Do not use the executive mailbox tool to send the briefing. The agent's own inbox is the canonical sender. Mailbox read access exists only to triage executive inbox signals.
    - Do not loop over per-bot domains with one query each. Batch into one `adl_query_records` call with a multi-`entity_type` filter.
    - Do not generate audio briefings unless the user opted in. Audio generation calls cost real money per character.
model:
  provider: "anthropic"
  preferred: "haiku_latest"
  fallback: "haiku_latest"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@every 4h"
  recommendations:
    light: "@every 8h"
    standard: "@every 4h"
    intensive: "@every 2h"
messaging:
  listensTo:
    - { type: "alert", from: ["*"] }
    - { type: "finding", from: ["business-analyst", "accountant", "legal-compliance", "product-owner", "mentor-coach", "platform-optimizer", "pipeline-cost-optimizer", "agent-cost-optimizer"] }
    - { type: "text", from: ["*"] }
  sendsTo:
    - { type: "request", to: ["business-analyst", "sre-devops", "accountant", "mentor-coach"], when: "needs cross-domain analysis" }
    - { type: "text", to: ["*"], when: "daily briefing distribution" }
data:
  entityTypesRead: ["sre_findings", "de_findings", "ba_findings", "acct_findings", "cs_findings", "inv_findings", "legal_findings", "mktg_findings", "sec_findings", "po_findings", "mentor_findings", "opt_findings", "platform_health_reports", "tasks", "team_health_reports", "sre_alerts", "de_alerts", "acct_alerts", "cs_alerts", "inv_alerts", "legal_alerts", "mktg_alerts", "sec_alerts", "po_alerts", "mentor_alerts", "opt_alerts"]
  entityTypesWrite: ["ea_findings", "ea_alerts", "tasks"]
  memoryNamespaces: ["working_notes", "learned_patterns", "follow_ups"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["management", "operations", "finance", "support", "engineering", "compliance", "product"]
egress:
  mode: "none"
skills:
  - ref: "skills/schemabounce"
plugins:
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    required: true
    reason: "Reads 22+ entity types across all domains; heavy cross-run recall for briefing continuity and follow-up tracking"
  - ref: "microsoft-teams@latest"
    slot: "channel"
    required: false
    reason: "Distributes daily briefings and priority alerts to Teams channels"
presence:
  email:
    required: true
    provider: agentmail
  web:
    search: true
    browsing: true
    crawling: false
  voice:
    required: false
    provider: elevenlabs
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-mission
      name: "Define company mission"
      description: "Your company's mission statement, bots align all findings to this"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Cannot prioritize or contextualize findings without the company mission"
      ui:
        inputType: text
        placeholder: "e.g., Enable real-time data infrastructure for every business"
    - id: set-priorities
      name: "Set quarterly priorities"
      description: "Top 3-5 business priorities used to rank findings by impact"
      type: north_star
      key: priorities
      group: configuration
      priority: required
      reason: "Cannot rank findings without knowing what matters most this quarter"
      ui:
        inputType: text
        placeholder: "e.g., 1. Reduce churn below 5%, 2. Ship v2 API, 3. SOC 2 certification"
    - id: set-stage
      name: "Define business stage"
      description: "Current business stage adjusts briefing formality and detail level"
      type: north_star
      key: stage
      group: configuration
      priority: recommended
      reason: "Adapts briefing tone and focus areas to your growth stage"
      ui:
        inputType: text
        placeholder: "e.g., seed, series-a, growth, enterprise"
    - id: connect-agentmail
      name: "Connect email for briefing delivery"
      description: "Sends daily briefings and priority alerts to executive inboxes"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Primary delivery channel for daily briefings and urgent alerts"
      ui:
        icon: mail
        actionLabel: "Connect Email"
    - id: connect-slack
      name: "Connect Slack for real-time alerts"
      description: "Posts critical alerts and briefing summaries to leadership channels"
      type: mcp_connection
      ref: tools/slack
      group: connections
      priority: recommended
      reason: "Enables real-time alert delivery to leadership channels"
      ui:
        icon: slack
        actionLabel: "Connect Slack"
    - id: connect-composio
      name: "Connect task management tools"
      description: "Sync follow-up items with calendar, CRM, and project management"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "Enables action item tracking across calendar and project management tools"
      ui:
        icon: composio
        actionLabel: "Connect Task Management"
goals:
  - name: briefing_completeness
    description: "Include all bot domains in every briefing, never skip a domain"
    category: primary
    metric:
      type: boolean
      check: "all_domains_read_before_briefing"
    target:
      operator: "=="
      value: 1
      period: per_run
  - name: alert_triage
    description: "Triage every alert received, no alert goes unacknowledged"
    category: primary
    metric:
      type: rate
      numerator: { entity: ea_findings, filter: { source_type: "alert", triaged: true } }
      denominator: { entity: ea_findings, filter: { source_type: "alert" } }
    target:
      operator: "=="
      value: 1.0
      period: per_run
  - name: follow_up_tracking
    description: "Track and resurface incomplete action items across runs"
    category: secondary
    metric:
      type: count
      entity: tasks
      filter: { status: "open" }
    target:
      operator: ">="
      value: 0
      period: per_run
      condition: "open items are surfaced in every briefing"
  - name: cross_domain_coverage
    description: "Read findings from all active domains before synthesizing"
    category: health
    metric:
      type: boolean
      check: "zone1_keys_read_before_output"
    target:
      operator: "=="
      value: 1
      period: per_run
---

# Executive Assistant

The central coordinator bot. Synthesizes outputs from ALL other bots, prioritizes findings across domains, produces daily briefings, and tracks follow-up items.

## What It Does

- Reads all bot findings and alerts from every domain
- Prioritizes items against quarterly priorities from North Star
- Generates structured daily briefings
- Tracks action items and follow-ups across runs
- Routes cross-domain requests to the right specialist bot

## Escalation Behavior

This bot is the TOP of the escalation chain. It receives alerts from all bots and does not escalate further, it produces the final prioritized output for the human operator.

## Recommended Setup

Ensure these North Star keys are filled:
- `mission`: Company mission (bots align to this)
- `priorities`: Top 3 quarterly priorities (used for ranking)
- `stage`: Business stage (adjusts formality and detail)
