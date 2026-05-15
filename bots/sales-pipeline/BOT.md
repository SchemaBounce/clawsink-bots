---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: sales-pipeline
  displayName: "Sales Pipeline"
  version: "1.0.9"
  description: "Analyzes sales funnel and identifies bottlenecks."
  category: sales
  tags: ["sales", "funnel", "pipeline"]
agent:
  capabilities: ["sales_analysis", "forecasting"]
  hostingMode: "openclaw"
  defaultDomain: "sales"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 key (mission) before analyzing pipeline data, align all forecasts and recommendations with the company's current stage and goals.
    - ALWAYS compare current pipeline metrics against conversion_rates and stage_durations memory baselines before flagging anomalies. Only escalate deviations exceeding 15% from baseline.
    - NEVER modify deal records in the source CRM. Your role is analysis and insight generation. Write pipeline_reports and deal_insights entities, not deal modifications.
    - NEVER include customer PII (names, emails, company names) in pipeline_reports or findings sent to other bots. Use anonymized deal IDs and segment labels only.
    - When a deal closes successfully, immediately send a finding to customer-onboarding with the deal ID, product tier, and any special requirements noted during the sales process.
    - When a deal is lost with a feature-related reason, send a finding to market-intelligence with the feature gap description and deal stage at loss. This feeds the feature parity analysis.
    - Send pipeline stage velocity data and deal conversion metrics to revops for revenue forecasting and operations alignment.
    - Escalate to executive-assistant only for pipeline health alerts: forecast deviation >20%, pipeline coverage ratio dropping below 3x, or a critical deal stalled beyond 2x average stage duration.
    - Update conversion_rates memory each run with stage-to-stage conversion percentages and stage_durations memory with average days per stage.
    - When receiving onboarding feedback from customer-onboarding, log patterns in stage_durations memory to identify whether sales handoff quality affects onboarding success.
  toolInstructions: |
    ## Tool Usage

    Two classes of MCP tools are wired here. Call them differently:

    - **Direct-host tools** (Stripe, AgentMail, Exa, Hyperbrowser): namespaced calls like `stripe.list_charges(...)`, `agentmail.send(...)`, `exa.search(...)`, `hyperbrowser.scrape(...)`. The runtime routes these straight through.
    - **Composio-routed tools** (Salesforce, HubSpot, Google Calendar, Gmail, plus any other CRM toolkit the workspace connects via Composio): always use the discover-then-execute pattern. Never assume action names.

    ### Composio discover-then-execute pattern

    ```
    composio.search_composio_tools({
      toolkits: ["SALESFORCE"],
      use_case: "list open opportunities updated in the last 24 hours"
    })
    // returns canonical action names like SALESFORCE_LIST_OPPORTUNITIES, SALESFORCE_GET_OPPORTUNITY, ...

    composio.execute_composio_tool({
      action: "SALESFORCE_LIST_OPPORTUNITIES",
      arguments: { last_modified_after: "2026-04-25T00:00:00Z", limit: 200 }
    })
    ```

    Action names shown below are typical shapes (e.g. `SALESFORCE_LIST_OPPORTUNITIES`, `HUBSPOT_LIST_DEALS`, `GOOGLECALENDAR_CREATE_EVENT`, `GMAIL_SEND_EMAIL`), not guarantees. Always verify with `search_composio_tools` first.

    ### Daily / per-run order of operations

    1. `adl_read_memory` namespace `bot:sales-pipeline:state` key `last_run_state`. Get last run timestamp and per-CRM cursors.
    2. `adl_read_memory` namespace `conversion_rates` and `stage_durations`. Load baselines for anomaly comparison and the `coverage_target` value.
    3. `adl_read_messages`. Pick up `request` from executive-assistant and `finding` from revops or customer-onboarding.
    4. **Pull CRM data (Composio):**
       - `composio.search_composio_tools({ toolkits: ["SALESFORCE"], use_case: "list opportunities updated since last run with stage, amount, close date, owner, last activity" })` then execute the returned action.
       - Same for HubSpot when present: `composio.search_composio_tools({ toolkits: ["HUBSPOT"], use_case: "list deals updated since last run with dealstage, amount, hs_lastmodifieddate" })`, execute.
       - When you need a single record's detail, discover the GET action and call it: e.g. `SALESFORCE_GET_OPPORTUNITY` with `id`, or `HUBSPOT_GET_DEAL` with `deal_id`.
    5. **Verify revenue side (direct Stripe):** for closed-won deals, `stripe.list_charges({ customer: <stripe_customer_id>, created: { gte: <close_ts> } })` to confirm payment landed. Use `stripe.list_subscriptions` for recurring deals. This closes the loop between CRM and actual revenue.
    6. **Score and analyze:** spawn `deal-scorer` on active deals, then `bottleneck-detector` on stage transitions, then `at-risk-alerter` on the scored set.
    7. **Outreach drafting (when prompted by request, never auto-fired):**
       - For warm follow-ups to existing CRM contacts, use Gmail via Composio: `composio.search_composio_tools({ toolkits: ["GMAIL"], use_case: "send email with subject and body to contact" })` then execute, e.g. `composio.execute_composio_tool({ action: "GMAIL_SEND_EMAIL", arguments: { to: "<email>", subject: "...", body: "..." } })`. Gmail is preferred for replies on existing threads because the user's signature, address, and history are attached.
       - For cold outreach not tied to an existing thread, prefer `agentmail.send({ to: "<email>", subject: "...", body: "...", tags: ["sales-pipeline", "cold-outreach"] })` to keep cold sends out of the user's primary inbox.
    8. **Calendar:** when a deal needs a demo or follow-up booked, `composio.search_composio_tools({ toolkits: ["GOOGLECALENDAR"], use_case: "create event with attendees and conferencing" })` then execute the returned action with `start`, `end`, `attendees`, and `summary`. Treat the bot's role as proposing the event; if the workspace requires user confirmation, write a `pipeline_reports` row instead of executing.
    9. **Research and enrichment (direct):**
       - `exa.search({ query: "<company> recent funding news", num_results: 5 })` for semantic prospect research; broad, non-URL questions.
       - `hyperbrowser.scrape({ url: "<specific_company_or_linkedin_url>" })` when you have a URL and need the page contents (pricing pages, case studies, public profiles).
       - Use Exa first for "find me X about Y", Hyperbrowser only when you already have the URL.
    10. **Write outputs:** `adl_upsert_record` entity_type=`pipeline_reports` (one per run, summary metrics), `adl_upsert_record` entity_type=`deal_insights` (one per stalled deal, at-risk deal, or notable transition). Anonymize: deal IDs and segment labels only, no customer PII.
    11. **Routing:**
       - Closed-won → `adl_send_message` type=`finding` to `customer-onboarding` with deal ID, product tier, special requirements.
       - Lost with feature reason → `adl_send_message` type=`finding` to `market-intelligence` with the gap and stage at loss.
       - Stage velocity / conversion metrics → `adl_send_message` type=`finding` to `revops`.
       - Pipeline health alert (forecast deviation >20%, coverage <3x, critical deal stalled) → `adl_send_message` type=`finding` to `executive-assistant`.
    12. `adl_write_memory` namespace `conversion_rates` (stage-to-stage rates), `stage_durations` (avg days per stage), `bot:sales-pipeline:state` key `last_run_state` with new timestamp.

    ### Examples

    Pulling Salesforce opportunities updated in the last day:
    ```
    composio.search_composio_tools({ toolkits: ["SALESFORCE"], use_case: "list opportunities updated since timestamp with stage, amount, close date, owner" })
    // returns e.g. SALESFORCE_LIST_OPPORTUNITIES
    composio.execute_composio_tool({
      action: "SALESFORCE_LIST_OPPORTUNITIES",
      arguments: { last_modified_after: "2026-04-25T00:00:00Z", limit: 200 }
    })
    ```

    Booking a discovery call:
    ```
    composio.search_composio_tools({ toolkits: ["GOOGLECALENDAR"], use_case: "create 30 minute event with attendees and Google Meet link" })
    composio.execute_composio_tool({
      action: "GOOGLECALENDAR_CREATE_EVENT",
      arguments: {
        calendar_id: "primary",
        summary: "Discovery: Acme x Workspace",
        start: { dateTime: "2026-04-29T15:00:00-04:00" },
        end:   { dateTime: "2026-04-29T15:30:00-04:00" },
        attendees: [{ email: "buyer@acme.com" }],
        conferenceData: { createRequest: { requestId: "<uuid>" } }
      }
    })
    ```

    Cold outreach via AgentMail:
    ```
    agentmail.send({
      to: "vp-eng@prospect.com",
      subject: "Quick question about your data pipeline",
      body: "<plain text>",
      tags: ["sales-pipeline", "cold-outreach"]
    })
    ```

    Researching a prospect:
    ```
    exa.search({ query: "Acme Corp Series B announcement 2026", num_results: 5 })
    // pick the most relevant result, then:
    hyperbrowser.scrape({ url: "https://acme.com/about" })
    ```

    ### Hard rules

    - Never call `composio.execute_composio_tool` with an action name you did not first see in a `search_composio_tools` response.
    - Never write to the source CRM. No `_CREATE_`, `_UPDATE_`, `_DELETE_` actions on Salesforce or HubSpot deal/opportunity/contact records. Discover-then-execute on read-only actions only. The bot's job is analysis; updates are for revops.
    - Never include customer PII (names, emails, company names) in `pipeline_reports` or messages to non-sales bots. Anonymized deal IDs and segment labels only.
    - Gmail (Composio) for replies on existing threads. AgentMail (direct) for cold outreach. Don't mix them up.
    - Budget for 6-12 tool calls on a normal day. End-of-quarter forecasting runs may go higher; do not pad with discovery calls if you already have the action name in this run.
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
  default: "@daily"
  recommendations:
    light: "@every 2d"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["revops", "customer-onboarding"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "pipeline health alert or forecast deviation" }
    - { type: "finding", to: ["customer-onboarding"], when: "deal closed, new customer ready for onboarding" }
    - { type: "finding", to: ["revops"], when: "pipeline stage data or deal velocity metrics" }
    - { type: "finding", to: ["market-intelligence"], when: "deal loss reason or feature gap from prospect feedback" }
data:
  entityTypesRead: ["deals", "pipeline_stages"]
  entityTypesWrite: ["pipeline_reports", "deal_insights"]
  memoryNamespaces: ["conversion_rates", "stage_durations"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["sales", "revenue"]
egress:
  mode: "restricted"
  allowedDomains: ["api.hubspot.com", "*.salesforce.com", "api.pipedrive.com"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "OAuth access to CRM platforms (Salesforce, HubSpot, Pipedrive) for reading deal stages and pipeline data"
mcpServers:
  - ref: "tools/stripe"
    required: false
    reason: "Verifies deal payments and tracks payment-linked revenue"
  - ref: "tools/agentmail"
    required: true
    reason: "Send deal alerts and pipeline health summaries to sales stakeholders"
  - ref: "tools/exa"
    required: false
    reason: "Research prospect companies and competitive intelligence for deal qualification"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse prospect websites and LinkedIn profiles for deal enrichment"
  - ref: "tools/composio"
    required: true
    reason: "Connect to CRM platforms (Salesforce, HubSpot, Pipedrive) for deal data sync"
  - ref: "tools/salesforce"
    required: false
    reason: "Query accounts, contacts, opportunities, and cases in Salesforce CRM"
  - ref: "tools/hubspot"
    required: false
    reason: "Manage contacts, deals, companies, and pipeline stages in HubSpot"
  - ref: "tools/google-calendar"
    required: false
    reason: "Schedule demo calls and follow-up meetings with prospects"
  - ref: "tools/gmail"
    required: false
    reason: "Send personalized follow-up emails to prospects and buyers"
presence:
  email:
    required: true
    provider: agentmail
  web:
    browsing: true
    search: true
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-crm
      name: "Connect CRM platform"
      description: "Links your CRM so the bot can read deals, pipeline stages, and conversion data"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source, deal stage data and pipeline metrics come from the CRM"
      ui:
        icon: composio
        actionLabel: "Connect CRM"
        helpUrl: "https://docs.schemabounce.com/integrations/crm"
    - id: connect-email
      name: "Connect email for deal alerts"
      description: "Send pipeline health summaries and stalled deal alerts to sales leadership"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Sales stakeholders need real-time alerts on pipeline health and critical deal changes"
      ui:
        icon: email
        actionLabel: "Connect Email"
    - id: set-mission
      name: "Set company mission and stage"
      description: "Aligns pipeline analysis with your company's current goals and growth stage"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Pipeline recommendations differ for seed-stage vs growth-stage companies"
      ui:
        inputType: text
        placeholder: "e.g., Series B SaaS company targeting mid-market enterprise"
    - id: set-pipeline-coverage
      name: "Set pipeline coverage target"
      description: "Minimum pipeline-to-quota ratio before the bot triggers a health alert"
      type: config
      group: configuration
      target: { namespace: conversion_rates, key: coverage_target }
      priority: recommended
      reason: "Industry standard is 3x coverage, adjust based on your sales cycle and win rate"
      ui:
        inputType: slider
        min: 2.0
        max: 5.0
        step: 0.5
        default: 3.0
    - id: import-deals
      name: "Import historical deals"
      description: "Past deal data establishes conversion rate baselines and stage duration norms"
      type: data_presence
      entityType: deals
      minCount: 50
      group: data
      priority: recommended
      reason: "At least 50 closed deals needed for meaningful stage-to-stage conversion baselines"
      ui:
        actionLabel: "Import Deals"
        emptyState: "No deal history found. Connect your CRM first to pull historical data."
        helpUrl: "https://docs.schemabounce.com/data/import"
    - id: connect-stripe
      name: "Connect Stripe for payment verification"
      description: "Verify deal payments and track payment-linked revenue"
      type: mcp_connection
      ref: tools/stripe
      group: connections
      priority: recommended
      reason: "Payment verification closes the loop between pipeline and actual revenue"
      ui:
        icon: stripe
        actionLabel: "Connect Stripe"
goals:
  - name: pipeline_health_monitoring
    description: "Produce daily pipeline health reports with conversion and velocity metrics"
    category: primary
    metric:
      type: count
      entity: pipeline_reports
    target:
      operator: ">="
      value: 1
      period: daily
  - name: stalled_deal_detection
    description: "Identify deals stalled beyond 2x average stage duration"
    category: primary
    metric:
      type: count
      entity: deal_insights
      filter: { insight_type: "stalled_deal" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when stalled deals exist"
  - name: conversion_baseline_accuracy
    description: "Stage-to-stage conversion rates tracked and updated each run"
    category: secondary
    metric:
      type: count
      source: memory
      namespace: conversion_rates
    target:
      operator: ">"
      value: 0
      period: daily
      condition: "updated each run"
  - name: handoff_quality
    description: "Closed-won deals trigger onboarding handoff within the same run"
    category: health
    metric:
      type: boolean
      check: onboarding_handoff_sent
    target:
      operator: "=="
      value: true
      period: per_run
      condition: "when deals close"
---

# Sales Pipeline

Analyzes the sales pipeline daily. Identifies stalled deals, conversion bottlenecks, and forecasts quarterly performance.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
