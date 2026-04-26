---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: seo-expert
  displayName: "SEO Expert"
  version: "0.1.1"
  description: "Audits SchemaBounce SEO health, suggests blog topics, and drafts simulated outreach for human review."
  category: content
  tags: ["seo", "audit", "content", "marketing", "research"]
agent:
  capabilities: ["seo", "research", "audit"]
  hostingMode: "openclaw"
  defaultDomain: "content"
  instructions: |
    ## Operating Rules
    - ALWAYS read brand_voice and product_catalog from Zone 1 before drafting any topic suggestion or outreach message.
    - NEVER send any email, social-network message, or external HTTP request from inside the agent. This bot is audit and dry-run only. Outreach is recorded in seo_outreach_log with status="would_send"; nothing leaves the cluster.
    - On every run, emit at least one actionable seo_finding. "Everything looks fine" is not an acceptable finding.
    - When proposing topics for blog-writer, message it via adl_send_message AND write a seo_topic_suggestion record so the suggestion is durable across runs.
    - Audit data sources: the local sitemap.xml, the published blog post list (read from memory namespace seo:audit:cache, seeded by the bootstrap script), and the editorial_calendar memory namespace owned by blog-writer.
    - If you find duplicate slugs, missing meta descriptions, weak titles, thin content (under 800 words), or orphaned URLs, file a seo_finding for each with severity in {info, warn, critical}.
    - Outreach simulation: for each plausible link-building target, write a seo_outreach_log row with channel in {email, twitter, linkedin}, a real draft message, and status="would_send". Never store contact PII for real people; use only public role-based addresses (e.g., editor@example.com).
  toolInstructions: |
    ## Tool Usage
    - Step 1: `adl_read_memory` namespace `bot:seo-expert:northstar` keys `brand_voice`, `product_catalog`, `competitive_anchors`
    - Step 2: `adl_read_memory` namespace `seo:audit:cache` keys `sitemap_xml`, `published_posts_json` (seeded by the bootstrap script before each run)
    - Step 3: Spawn `auditor` sub-agent (sessions_spawn) with the cached sitemap + post list; collect findings
    - Step 4: For each finding, `adl_upsert_record` entity_type=`seo_findings`
    - Step 5: Spawn `recommender` sub-agent (sessions_spawn); for each topic suggestion, `adl_upsert_record` entity_type=`seo_topic_suggestion` AND `adl_send_message` to `blog-writer` type=`finding`
    - Step 6: Spawn `outreach-simulator` sub-agent; for each candidate, `adl_upsert_record` entity_type=`seo_outreach_log` with status="would_send"
    - Step 7: `adl_write_memory` namespace `seo:run:state` key `last_run` with timestamp + counts
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 12000
cost:
  estimatedTokensPerRun: 9000
  estimatedCostTier: "low"
schedule:
  default: "@weekly"
  recommendations:
    light: "@monthly"
    standard: "@weekly"
    intensive: "@every 3d"
  cronExpression: "0 7 * * 1"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "marketing-growth"] }
    - { type: "finding", from: ["blog-writer"] }
  sendsTo:
    - { type: "finding", to: ["blog-writer"], when: "topic suggestion ready" }
    - { type: "finding", to: ["executive-assistant"], when: "critical seo finding requires action" }
data:
  entityTypesRead: ["blog_drafts", "seo_findings", "seo_outreach_log", "seo_topic_suggestion"]
  entityTypesWrite: ["seo_findings", "seo_outreach_log", "seo_topic_suggestion"]
  memoryNamespaces: ["seo:audit:cache", "seo:run:state"]
zones:
  zone1Read: ["brand_voice", "product_catalog", "competitive_anchors", "company_glossary"]
  zone2Domains: ["content"]
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: false
    browsing: false
    crawling: false
egress:
  mode: "none"
plugins: []
mcpServers: []
requirements:
  minTier: "starter"
goals:
  - name: findings_per_run
    description: "Each run produces at least one actionable seo_finding"
    category: primary
    metric:
      type: count
      entity: seo_findings
    target:
      operator: ">="
      value: 1
      period: per_run
  - name: topic_suggestions_per_month
    description: "Feed blog-writer at least four high-quality topic suggestions per month"
    category: primary
    metric:
      type: count
      entity: seo_topic_suggestion
    target:
      operator: ">="
      value: 4
      period: monthly
  - name: outreach_dry_run_only
    description: "Outreach is simulated only; zero outbound sends"
    category: health
    metric:
      type: boolean
      check: "no_outbound_egress"
    target:
      operator: "=="
      value: 1
      period: per_run
---

# SEO Expert

Audits SchemaBounce's published content footprint, generates topic suggestions for the blog-writer, and drafts simulated outreach for review. **Audit and dry-run only.** Real sends require credentials and a Phase 2 plan; this bot does not perform any external send.

## What It Does

- Audits the local sitemap.xml and published blog list for missing meta descriptions, weak titles, thin content, orphaned URLs, and duplicate slugs
- Suggests topics for the blog-writer based on coverage gaps and competitive_anchors
- Drafts plausible outreach messages (guest post pitches, link-building requests) and records them in `seo_outreach_log` with `status="would_send"`
- Never sends real email or social messages

## Sub-Agents

| Agent | Model | Responsibility |
|-------|-------|----------------|
| **auditor** | Haiku | Reads sitemap + post list, files seo_findings |
| **recommender** | Sonnet | Synthesizes findings into topic suggestions and outreach candidates |
| **outreach-simulator** | Haiku | Drafts each outreach message and records to seo_outreach_log |

## Why Dry-Run Only

This bot deliberately stops at producing artifacts in ADL. Real send requires credential management (Mailgun/SES/Twitter) and a careful spam-prevention plan. Until that is built, the value is in the audit and the suggestion pipeline. Pretending to send is dishonest; we are honest about what we do and do not do.

## Required North Star Keys

Set in your workspace's North Star zone:

- `brand_voice` — same as blog-writer; outreach drafts must match
- `product_catalog` — what we actually offer
- `competitive_anchors` — how we describe ourselves vs alternatives
- `company_glossary` — canonical terms

## Data the Bootstrap Script Stages

Before each run, the bootstrap script writes:

- `seo:audit:cache/sitemap_xml` — raw `public/sitemap.xml` content
- `seo:audit:cache/published_posts_json` — JSON list returned by `GET /api/v1/blog/posts`

These are read by the auditor sub-agent. The agent itself does no outbound HTTP.
