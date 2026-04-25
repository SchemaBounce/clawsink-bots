---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: lead-researcher
  displayName: "Lead Researcher"
  version: "1.0.0"
  description: "Researches B2B leads and their companies, surfaces news signals, and writes AI-generated research briefs to help your team personalize outreach."
  category: sales
  tags: ["sales", "leads", "research", "crm", "outreach", "b2b", "prospecting"]
agent:
  capabilities: ["lead_enrichment", "company_research", "outreach_personalization"]
  hostingMode: "openclaw"
  defaultDomain: "crm"
  instructions: |
    ## Operating Rules
    - ALWAYS read `last_run_state` memory before querying leads — resume from the correct batch position.
    - ALWAYS check for an existing research brief (generatedAt within 7 days) before generating a new one for the same lead.
    - NEVER fabricate company or lead details — write `null` fields rather than guesses. Every claim in a research brief must trace to a record in the CRM or a news_item you are writing in this same run.
    - NEVER process more than 20 leads per run. Prioritize by status (`new` before `contacted`) then by `created_at` ascending (oldest unworked first).
    - NEVER overwrite a lead's `status` without logging the rationale in the brief's `content` field.
    - When a lead has a `companyId`, always fetch the company record first — company context is required for a quality brief.
    - When writing news_items, set `entityId` to the company's entity_id and `entityType` to `companies`. Only write net-new signals — query existing news_items for the company first.
    - After writing a research brief, add a one-line memory entry to the `leads` namespace (`adl_add_memory`) so future runs have prior context without querying records again.
    - Target 6–10 tool calls per run across a batch of up to 20 leads. Work efficiently: read all leads in one query, batch company reads, then write briefs in order.
  toolInstructions: |
    ## Tool Usage — Efficient Batching
    - Step 1: `adl_read_messages` — check inbox for direct research requests
    - Step 2: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 3: `adl_query_records` entity_type: `leads` filter: `status IN [new, contacted]` limit: 20 — get batch
    - Step 4: If no leads and no messages → `adl_write_memory` key `last_run_state` → STOP
    - Step 5: For each lead with a companyId → `adl_get_record` entity_type: `companies`
    - Step 6: `adl_query_records` entity_type: `news_items` filter: `entityId = {companyId}` — check existing signals
    - Step 7: `adl_search_memory` namespace: `leads` query: "{firstName} {lastName} {company}" — prior context
    - Step 8: Write brief → `adl_write_record` entity_type: `research_briefs`
    - Step 9: Write any new signals → `adl_write_record` entity_type: `news_items`
    - Step 10: `adl_add_memory` namespace: `leads` — one-line summary of brief for future runs
    - Step 11: `adl_write_memory` key `last_run_state` — update timestamp and count
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
    - { type: "request", from: ["*"] }
  sendsTo: []
data:
  entityTypesRead:
    - leads
    - companies
    - news_items
    - outreach_templates
    - research_briefs
  entityTypesWrite:
    - news_items
    - research_briefs
  memoryNamespaces:
    - leads
    - companies
zones:
  zone1Read: ["mission", "icp"]
  zone2Domains: ["crm"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
plugins: []
mcpServers: []
presence:
  email:
    required: false
  web:
    browsing: false
    search: false
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-icp
      name: "Define your ideal customer profile"
      description: "Tells the researcher what kinds of leads and companies to prioritize"
      type: north_star
      key: icp
      group: configuration
      priority: required
      reason: "Research quality improves dramatically when the agent knows your ICP — it determines which signals are relevant and which templates match"
      ui:
        inputType: text
        placeholder: "e.g., VP of Engineering at Series A–C SaaS companies with 50–500 employees"
    - id: set-mission
      name: "Set your outreach mission"
      description: "The product or service you are selling — used to frame research briefs and template recommendations"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "The researcher needs to know what you are selling to identify relevant buying signals"
      ui:
        inputType: text
        placeholder: "e.g., Real-time data infrastructure for engineering teams that need sub-second pipeline latency"
    - id: seed-leads
      name: "Seed your lead list"
      description: "Sample leads are pre-loaded so the agent has something to research on its first run"
      type: data_presence
      entityType: leads
      minCount: 1
      group: data
      priority: recommended
      reason: "The agent runs its first research pass immediately after deployment — leads must exist"
      ui:
        actionLabel: "View Leads"
        emptyState: "No leads yet. The sample data kit has pre-loaded 20 leads — they will appear here after seeding."
goals:
  - name: briefs_generated
    description: "Produce at least one research brief per day while unworked leads exist"
    category: primary
    metric:
      type: count
      entity: research_briefs
    target:
      operator: ">="
      value: 1
      period: daily
      condition: "when new or contacted leads exist"
  - name: lead_coverage
    description: "All new leads have a research brief within 48 hours of being added"
    category: primary
    metric:
      type: ratio
      numerator: { entity: research_briefs }
      denominator: { entity: leads, filter: { status: "new" } }
    target:
      operator: ">="
      value: 0.9
      period: weekly
  - name: news_signal_capture
    description: "News signals captured for leads with known companies"
    category: secondary
    metric:
      type: count
      entity: news_items
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when leads have companyId set"
  - name: memory_freshness
    description: "last_run_state memory updated each run"
    category: health
    metric:
      type: boolean
      check: last_run_state_updated
    target:
      operator: "=="
      value: true
      period: per_run
---

# Lead Researcher

Researches B2B leads daily. For every unworked lead, it fetches the company record, surfaces recent news signals, and writes a concise research brief — so your team walks into every conversation prepared.

## What It Does Each Run

1. Reads the inbox for direct research requests
2. Queries up to 20 unworked leads (status: `new` or `contacted`)
3. Pulls company context for each lead
4. Checks for existing news signals; captures new ones
5. Writes a research brief per lead with: verdict, evidence bullets, recommended template, suggested angle
6. Updates memory so future runs don't re-research the same leads

## Research Brief Format

Each brief leads with a one-sentence verdict, followed by:
- Company context (stage, industry, hiring signals, recent news)
- Lead context (role level, tenure indicators, LinkedIn activity)
- Recommended outreach template (matched by industry + company stage)
- Suggested first-touch angle (why now, what to reference)

## No External APIs Required

This bot operates entirely within the Agent Data Layer — no CRM OAuth, no web browsing, no email setup. It works with the leads and companies already in your CRM data. Add an MCP browser tool later if you want live web enrichment.
