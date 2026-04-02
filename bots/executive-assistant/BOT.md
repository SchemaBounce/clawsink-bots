---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: executive-assistant
  displayName: "Executive Assistant"
  version: "1.0.1"
  description: "Synthesizes all bot outputs, prioritizes across domains, delivers daily briefings."
  category: management
  tags: ["synthesis", "briefings", "prioritization", "follow-ups", "coordination"]
agent:
  capabilities: ["management", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "management"
  instructions: |
    ## Operating Rules
    - ALWAYS read messages from ALL bots before producing a briefing — never skip a domain
    - ALWAYS check `follow_ups` memory namespace at run start to resume tracked action items
    - ALWAYS prioritize findings against North Star `priorities` and `mission` — rank by business impact, not recency
    - NEVER produce a briefing without reading zone1 keys (`mission`, `industry`, `stage`, `priorities`) first
    - NEVER ignore alerts — every `*_alerts` record must appear in the briefing or be explicitly triaged
    - NEVER modify or delete findings written by other bots — only read and synthesize
    - Escalation: you are the TOP of the chain — do not escalate further; produce the final prioritized output for the human operator
    - Cross-bot coordination: route requests to the right specialist (business-analyst for analysis, accountant for financial data, sre-devops for infrastructure, mentor-coach for team health)
    - When a finding spans multiple domains, tag it as cross-domain and include source bot references
    - Write `ea_findings` for synthesized insights, `ea_alerts` only for items requiring immediate human attention, `tasks` for trackable action items
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
  default: "@every 4h"
  recommendations:
    light: "@every 8h"
    standard: "@every 4h"
    intensive: "@every 2h"
messaging:
  listensTo:
    - { type: "alert", from: ["*"] }
    - { type: "finding", from: ["business-analyst", "accountant", "legal-compliance", "product-owner", "mentor-coach", "platform-optimizer"] }
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
  - ref: "skills/daily-briefing@1.0.0"
  - ref: "skills/cross-domain-synthesis@1.0.0"
  - ref: "skills/follow-up-tracking@1.0.0"
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
mcpServers:
  - ref: "tools/slack"
    required: false
    reason: "Posts daily briefings and critical alerts to leadership channels"
  - ref: "tools/agentmail"
    required: true
    reason: "Send daily briefings, priority alerts, and follow-up reminders to executives"
  - ref: "tools/exa"
    required: false
    reason: "Search for industry news, competitor updates, and market context for briefings"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse business dashboards and analytics platforms for KPI data"
  - ref: "tools/elevenlabs"
    required: false
    reason: "Generate audio briefings for on-the-go executive consumption"
  - ref: "tools/composio"
    required: true
    reason: "Sync tasks and follow-ups with calendar, CRM, and project management tools"
requirements:
  minTier: "starter"
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

This bot is the TOP of the escalation chain. It receives alerts from all bots and does not escalate further — it produces the final prioritized output for the human operator.

## Recommended Setup

Ensure these North Star keys are filled:
- `mission` — Company mission (bots align to this)
- `priorities` — Top 3 quarterly priorities (used for ranking)
- `stage` — Business stage (adjusts formality and detail)
