---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: blog-writer
  displayName: "Blog Writer"
  version: "1.0.5"
  description: "Weekly technical blog content creation for SchemaBounce and OpenCLAW platforms."
  category: content
  tags: ["blog", "content", "writing", "seo", "marketing"]
agent:
  capabilities: ["writing", "research", "seo"]
  hostingMode: "openclaw"
  defaultDomain: "content"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 keys (brand_voice, product_catalog, company_glossary) before writing any content. Every post must match the established tone, use correct product names, and reference current features.
    - ALWAYS check the editorial_calendar memory namespace before selecting a topic to avoid duplicate coverage. Mark topics as "in-progress" when starting a draft.
    - NEVER auto-publish content. All posts must be submitted as blog_drafts entities with status "draft" and routed to executive-assistant for human review.
    - NEVER include pricing specifics, competitor names, or unreleased feature details unless explicitly present in product_catalog zone1 data.
    - Orchestrate sub-agents in strict sequence: researcher validates topic feasibility first, writer drafts from research notes, editor reviews against brand_voice. Do not skip the editor pass.
    - When receiving a request from marketing-growth, extract the target topic, audience, and publish window. Store these in editorial_calendar memory before beginning research.
    - After completing a draft, send a finding to marketing-growth (for promotion planning) and to social-media-strategist (for social distribution) with the blog title, summary, and target publish date.
    - If the researcher sub-agent cannot find sufficient source material, send a request to executive-assistant explaining the gap rather than producing a thin post.
    - Alternate content sections (SchemaBounce vs OpenCLAW) across consecutive runs. Track the last section in editorial_calendar memory.
    - Cap each blog post at 1500 words unless the request explicitly specifies long-form content.
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 16000
cost:
  estimatedTokensPerRun: 15000
  estimatedCostTier: "medium"
schedule:
  default: "@weekly"
  recommendations:
    light: "@monthly"
    standard: "@weekly"
    intensive: "@every 3d"
  # Preferred day/time: Monday 9 AM UTC
  cronExpression: "0 9 * * 1"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "marketing-growth"] }
    - { type: "finding", from: ["data-engineer", "product-owner"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "draft blog post ready for review" }
    - { type: "request", to: ["executive-assistant"], when: "missing context or unable to write" }
    - { type: "finding", to: ["marketing-growth"], when: "blog post published. Ready for promotion" }
    - { type: "finding", to: ["social-media-strategist"], when: "new blog content available for social distribution" }
data:
  entityTypesRead: ["blog_topics", "product_docs"]
  entityTypesWrite: ["blog_drafts", "editorial_notes"]
  memoryNamespaces: ["editorial_calendar", "writing_notes", "topic_research"]
zones:
  zone1Read: ["brand_voice", "product_catalog", "company_glossary"]
  zone2Domains: ["content", "marketing"]
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    browsing: false
    crawling: true
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/report-generation@1.0.0"
  - ref: "skills/trend-analysis@1.0.0"
  - ref: "skills/sentiment-analysis@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Managed OAuth for blog API. Handles token refresh and scoping"
    config:
      apps: ["blog"]
      scopes: ["blog:write"]
mcpServers:
  - ref: "tools/github"
    required: false
    reason: "Publishes blog posts via pull requests to content repository"
  - ref: "tools/agentmail"
    required: false
    reason: "Send editorial notifications and draft review requests to content stakeholders"
  - ref: "tools/exa"
    required: true
    reason: "Research trending topics, competitor content, and industry news for blog post ideation"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl reference articles and documentation sources for research material"
  - ref: "tools/composio"
    required: false
    reason: "Publish drafts to CMS platforms and coordinate with marketing automation tools"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-brand-voice
      name: "Define brand voice"
      description: "Tone, style guidelines, and terminology preferences for all content"
      type: north_star
      key: brand_voice
      group: configuration
      priority: required
      reason: "Every blog post must match the established brand tone and style"
      ui:
        inputType: text
        placeholder: "e.g., Technical but approachable, developer-focused, no marketing jargon"
        helpUrl: "https://docs.schemabounce.com/bots/blog-writer/brand-voice"
    - id: set-product-catalog
      name: "Define product catalog"
      description: "Current features, product names, and positioning for accurate references"
      type: north_star
      key: product_catalog
      group: configuration
      priority: required
      reason: "Prevents referencing outdated features or using incorrect product names"
      ui:
        inputType: text
        placeholder: "Product names, feature list, positioning summary"
    - id: connect-exa
      name: "Connect web search"
      description: "Research trending topics and industry news for blog ideation"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "Research capability is essential for factual, well-sourced blog content"
      ui:
        icon: search
        actionLabel: "Connect Web Search"
    - id: connect-github
      name: "Connect GitHub for publishing"
      description: "Publishes blog posts via pull requests to your content repository"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: recommended
      reason: "Enables automated draft submission via PR to content repo"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
    - id: set-company-glossary
      name: "Define company glossary"
      description: "Technical terms, acronyms, and product-specific terminology"
      type: north_star
      key: company_glossary
      group: configuration
      priority: recommended
      reason: "Ensures consistent terminology across all blog posts"
      ui:
        inputType: text
        placeholder: "e.g., CDC = Change Data Capture, Kolumn = our IaC tool"
    - id: connect-firecrawl
      name: "Connect web crawler"
      description: "Crawls reference articles and documentation for deeper research"
      type: mcp_connection
      ref: tools/firecrawl
      group: connections
      priority: optional
      reason: "Enables crawling reference material for more thorough research"
      ui:
        icon: crawl
        actionLabel: "Connect Crawler"
goals:
  - name: publish_cadence
    description: "Produce one blog draft per scheduled run"
    category: primary
    metric:
      type: count
      entity: blog_drafts
    target:
      operator: ">="
      value: 1
      period: per_run
      condition: "when no editorial calendar conflict"
  - name: content_quality
    description: "Drafts approved without major revisions"
    category: primary
    metric:
      type: rate
      numerator: { entity: blog_drafts, filter: { review_status: "approved" } }
      denominator: { entity: blog_drafts, filter: { review_status: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.8
      period: monthly
    feedback:
      enabled: true
      entityType: blog_drafts
      actions:
        - { value: approved, label: "Approved as-is" }
        - { value: minor_edits, label: "Minor edits needed" }
        - { value: major_revisions, label: "Major revisions" }
        - { value: rejected, label: "Rejected" }
  - name: topic_diversity
    description: "Alternate between product sections to maintain balanced coverage"
    category: secondary
    metric:
      type: boolean
      check: "alternated_sections_since_last_run"
    target:
      operator: "=="
      value: 1
      period: per_run
  - name: research_depth
    description: "Posts backed by sufficient source material"
    category: health
    metric:
      type: count
      source: memory
      namespace: topic_research
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "research notes exist for current topic"
---

# Blog Writer

Creates weekly technical blog posts for the SchemaBounce and OpenCLAW blog sections. Researches topics using product documentation, knowledge graph, and memory, then drafts full markdown posts submitted for human review.

## What It Does

- Writes one blog post per week, alternating between SchemaBounce and OpenCLAW sections
- Orchestrates three sub-agents in isolated sessions: **researcher** → **writer** → **editor**
- Researcher validates topic feasibility and gathers source material
- Writer drafts the full post from research notes
- Editor reviews for voice, accuracy, and style guide adherence (with revision cycles)
- Maintains an editorial calendar to avoid duplicate topics
- Submits all posts as drafts — never auto-publishes
- Notifies the team when a draft is ready for review

## Scheduling Options

### Claude Cowork (Recommended for Teams)

Use Claude Cowork's built-in cron scheduler for the simplest setup:

1. Open Claude Cowork
2. Create a new task: "Write a blog post for SchemaBounce/OpenCLAW"
3. Type `/schedule` and set cadence to weekly (Monday 9 AM)
4. Configure the task with workspace ID and service account credentials
5. Claude Cowork handles execution and retries automatically

### Self-Hosted Scheduler

For self-hosted deployments, register the agent via the platform API with the appropriate cron expression and capabilities.

### Service Account Setup

Both approaches require a service account with blog scopes. Create one in Workspace Settings > Service Accounts. Save the credentials — the secret is shown only once.

## Content Categories

| Section | Categories | Example Topics |
|---------|-----------|----------------|
| SchemaBounce | Fundamentals, Tutorials, Comparisons, Guides | CDC patterns, database tutorials, tool comparisons |
| OpenCLAW | Research, Agent Insights, Tutorials, Guides | Multi-agent patterns, SOUL.md design, knowledge graphs |

## Escalation Behavior

- **Normal**: Draft submitted, executive-assistant notified → human reviews in blog management UI
- **Blocked**: Missing product context → requests info from executive-assistant
- **Topic request**: Team member sends topic request → added to editorial calendar

## Recommended North Star Keys

Set these in your workspace's North Star zone for best results:

- `brand_voice` — Tone, style guidelines, terminology preferences
- `product_catalog` — Current features, pricing tiers, differentiators
- `company_glossary` — Product names, acronyms, technical terms
- `market_context` — Industry context for comparison posts
