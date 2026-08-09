---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: demand-signal-scout
  displayName: "Demand Signal Scout"
  version: "1.0.1"
  description: "Finds high-intent public conversations, creates a deduplicated prospect queue, and drafts approval-gated replies that drive qualified people to a tracked conversion page."
  category: sales
  tags: ["lead-generation", "demand-generation", "reddit", "youtube", "intent", "prospecting", "approval-gate", "attribution"]
agent:
  capabilities: ["research", "sales", "content_marketing"]
  hostingMode: "openclaw"
  defaultDomain: "sales"
  instructions: |
    ## Operating Rules
    - ALWAYS read the workspace ICP, intent queries, conversion URL, score threshold, source allowlist, and daily reply cap before searching.
    - Search only public sources and connected accounts the workspace explicitly configured. Prefer recent Reddit conversations, comments on the workspace's owned YouTube videos, and public company-level trigger pages.
    - A prospect signal is not a lead. Write `prospect_signals` only for relevant public intent. Write `leads` only when a person submits contact details through the configured first-party conversion page or another approved source.
    - NEVER scrape, infer, purchase, or guess a personal email address. NEVER copy a public profile's personal details into ADL. A public handle is used only transiently by the connected platform tool and is not stored in records, receipts, findings, or memory.
    - Deduplicate on the platform's immutable content id when available; otherwise use a deterministic hash of the canonical source URL. Never create two signals or two reply actions for one source item.
    - Score every candidate with the documented rubric. Only candidates at or above `minimum_intent_score` enter the review queue. State the evidence for every scoring component.
    - Before drafting a Reddit reply, read the subreddit rules. If self-promotion or links are disallowed, provide a useful answer without a link or do not reply. Never evade moderation controls.
    - Every public reply, comment, or direct message is an external action. Call the connected platform tool with the final text so the runtime parks it in Inbox > Actions, save the returned action id, then stop. A chat reply is never approval.
    - NEVER send unsolicited direct messages. Never reply when the source author asked not to receive recommendations, when policy status is unknown, or when the conversation is older than the configured freshness window.
    - Keep replies specific and useful. Answer the stated problem first. Include the tracked conversion URL only when it is relevant and permitted by source rules. Never pretend to be a customer, hide the workspace's affiliation, or manufacture urgency.
    - Enforce `daily_reply_cap` across all platforms. Reaching the cap stops new reply actions but does not stop discovery and scoring.
    - Expire unreviewed signals after the configured retention window. Suppression, rejection, or a prior reply permanently blocks another action for that source item.
  toolInstructions: |
    ## Tool Usage: One Acquisition Pass
    - Target: 6-10 calls per run; hard maximum 15.
    - Read `bot:demand-signal-scout:northstar` and `bot:demand-signal-scout:run:state` first.
    - Query existing `prospect_signals` and `outreach_drafts` once to build source-id and daily-action dedupe sets.
    - Run at most three configured intent searches per pass. Use connected Reddit and YouTube reads when available; use Exa for approved public web queries.
    - Normalize no more than 20 unseen candidates. Score them with the rubric in TOOLS.md and write only candidates meeting the threshold.
    - For the highest-scoring candidates, create no more than the remaining daily reply allowance. Check source rules, draft the exact reply, call the effectful reply tool so it is parked for approval, then save the action id.
    - Write one PII-free run receipt and update run state with source cursors, candidates seen, qualified signals, drafts parked, and cap remaining.
model:
  provider: "anthropic"
  preferred: "sonnet_latest"
  fallback: "haiku_latest"
  thinkLevel: "medium"
  maxTokenBudget: 14000
cost:
  estimatedTokensPerRun: 12000
  estimatedCostTier: "medium"
schedule:
  default: "@every 2h"
  recommendations:
    light: "@every 6h"
    standard: "@every 2h"
    intensive: "@every 30m"
messaging:
  listensTo:
    - { type: "request", from: ["marketing-growth", "social-media-strategist", "sales-pipeline"] }
  sendsTo:
    - { type: "finding", to: ["marketing-growth", "sales-pipeline"], when: "new high-intent prospect signals are ready for review" }
    - { type: "alert", to: ["executive-assistant"], when: "configured sources fail for three consecutive runs or the approval queue exceeds its SLA" }
data:
  entityTypesRead: ["prospect_signals", "outreach_drafts", "leads", "external_action", "suppression_entries"]
  entityTypesWrite: ["prospect_signals", "outreach_drafts", "receipt"]
  memoryNamespaces: ["bot:demand-signal-scout:northstar", "bot:demand-signal-scout:source-config", "bot:demand-signal-scout:run:state"]
zones:
  zone1Read: ["mission", "industry", "priorities"]
  zone2Domains: ["sales", "marketing"]
egress:
  mode: "restricted"
  allowedDomains: ["oauth.reddit.com", "www.reddit.com", "www.youtube.com", "youtube.googleapis.com", "api.exa.ai", "backend.composio.dev"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/social-publishing@2.1.0"
presence:
  web:
    search: true
    browsing: false
requirements:
  minTier: "team"
setup:
  steps:
    - id: connect-intent-search
      name: "Connect public intent search"
      description: "Searches approved public pages for recent conversations matching your configured buying-intent queries."
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "The scout needs one compliant discovery source before it can find demand."
      ui:
        icon: search
        actionLabel: "Connect Search"
    - id: connect-reddit
      name: "Connect Reddit"
      description: "Reads configured communities and parks relevant comment replies for approval."
      type: mcp_connection
      ref: tools/reddit
      group: connections
      priority: recommended
      reason: "Reddit provides current problem and recommendation conversations, plus source rule checks before engagement."
      ui:
        icon: social
        actionLabel: "Connect Reddit"
        helpUrl: "https://docs.schemabounce.com/integrations/reddit"
    - id: connect-owned-video
      name: "Connect owned video channels"
      description: "Reads comments on your owned YouTube videos and parks useful replies for approval."
      type: mcp_connection
      ref: tools/youtube
      group: connections
      priority: recommended
      reason: "Questions on owned videos are first-party engagement and often carry direct product intent."
      ui:
        icon: video
        actionLabel: "Connect YouTube"
    - id: set-icp
      name: "Define the ideal customer"
      description: "The company, role, stack, and problems that qualify as a useful prospect signal."
      type: north_star
      key: ideal_customer_profile
      group: configuration
      priority: required
      reason: "Intent without ICP fit creates noise rather than pipeline."
      ui:
        inputType: textarea
        placeholder: "B2B SaaS, 20-200 employees, HubSpot, RevOps or technical founder, needs reliable sales or data automation"
    - id: set-intent-queries
      name: "Set buying-intent queries"
      description: "Up to ten precise problems or recommendation phrases to monitor."
      type: config
      group: configuration
      target: { namespace: "bot:demand-signal-scout:source-config", key: "intent_queries" }
      priority: required
      reason: "Specific queries find active problems; broad industry keywords create low-value mentions."
      ui:
        inputType: textarea
        placeholder: "HubSpot lead routing automation\nCDC tool recommendation\nPostgres to Snowflake sync problems"
    - id: set-source-allowlist
      name: "Set approved sources"
      description: "Communities, owned channel IDs, and public domains the scout may monitor."
      type: config
      group: configuration
      target: { namespace: "bot:demand-signal-scout:source-config", key: "source_allowlist" }
      priority: required
      reason: "An explicit allowlist keeps discovery within approved sources and community rules."
      ui:
        inputType: textarea
        placeholder: "reddit:r/dataengineering\nreddit:r/hubspot\nyoutube:UC_your_owned_channel"
    - id: set-conversion-url
      name: "Set the conversion page"
      description: "The first-party demo, assessment, or contact page used in permitted replies, with attribution added per source."
      type: north_star
      key: conversion_url
      group: configuration
      priority: required
      reason: "Discovery produces leads only when qualified people have a clear first-party path to identify themselves."
      ui:
        inputType: url
        placeholder: "https://example.com/request-demo"
    - id: set-score-threshold
      name: "Set minimum intent score"
      description: "Candidates below this score stay out of the prospect queue."
      type: config
      group: configuration
      target: { namespace: "bot:demand-signal-scout:source-config", key: "minimum_intent_score" }
      priority: required
      reason: "A hard threshold prevents broad mentions from becoming sales activity."
      ui:
        inputType: slider
        min: 50
        max: 95
        step: 5
        default: 70
    - id: set-daily-cap
      name: "Set daily reply cap"
      description: "Maximum public reply actions parked across all sources each day."
      type: config
      group: configuration
      target: { namespace: "bot:demand-signal-scout:source-config", key: "daily_reply_cap" }
      priority: required
      reason: "A small cap protects community quality and keeps every reply reviewable."
      ui:
        inputType: slider
        min: 0
        max: 25
        step: 1
        default: 5
goals:
  - name: qualified_signals_created
    description: "Create reviewable, source-backed opportunities that match the configured ICP and intent threshold."
    category: primary
    metric:
      type: count
      entity: prospect_signals
      filter: { status: "qualified" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when approved sources contain matching conversations"
  - name: attributed_hand_raises
    description: "Generate first-party leads attributed to a scout source and campaign."
    category: primary
    metric:
      type: count
      entity: leads
      filter: { acquisition_channel: "demand_signal_scout" }
    target:
      operator: ">"
      value: 0
      period: monthly
  - name: zero_duplicate_actions
    description: "Never park more than one public reply action for the same source item."
    category: health
    metric:
      type: count
      entity: outreach_drafts
      filter: { duplicate: true }
    target:
      operator: "=="
      value: 0
      period: weekly
  - name: zero_unapproved_replies
    description: "Every published reply must have an attributed Inbox approval."
    category: health
    metric:
      type: count
      entity: outreach_drafts
      filter: { status: "published", approved: false }
    target:
      operator: "=="
      value: 0
      period: weekly
---

# Demand Signal Scout

Finds people actively discussing a configured business problem and converts the strongest public intent into a small, reviewable engagement queue. It does not manufacture contact lists. It earns a first-party hand raise by answering the actual question and offering a tracked next step when source rules permit it.

The core loop is discover, score, deduplicate, draft, approve, reply, and attribute. Public engagement is always approval-gated. A source signal becomes a lead only after the person chooses to submit contact details through the workspace's configured conversion page.
