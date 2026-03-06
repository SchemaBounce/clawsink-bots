---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: blog-writer
  displayName: "Blog Writer"
  version: "1.0.0"
  description: "Weekly technical blog content creation for SchemaBounce and OpenCLAW platforms."
  category: content
  tags: ["blog", "content", "writing", "seo", "marketing"]
agent:
  capabilities: ["writing", "research", "seo"]
  hostingMode: "openclaw"
  defaultDomain: "content"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
cost:
  estimatedTokensPerRun: 35000
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
data:
  entityTypesRead: ["blog_topics", "product_docs"]
  entityTypesWrite: ["blog_drafts", "editorial_notes"]
  memoryNamespaces: ["editorial_calendar", "writing_notes", "topic_research"]
zones:
  zone1Read: ["brand_voice", "product_catalog", "company_glossary"]
  zone2Domains: ["content"]
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Managed OAuth for blog API — handles token refresh and scoping"
    config:
      apps: ["blog"]
      scopes: ["blog:write"]
requirements:
  minTier: "starter"
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
