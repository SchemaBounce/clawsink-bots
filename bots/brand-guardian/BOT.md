---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: brand-guardian
  displayName: "Brand Guardian"
  version: "1.0.3"
  description: "Brand consistency monitoring, guideline enforcement, and asset review."
  category: design
  tags: ["brand", "consistency", "guidelines", "design", "content-review", "brand-audit"]
agent:
  capabilities: ["analytics", "compliance"]
  hostingMode: "openclaw"
  defaultDomain: "design"
  instructions: |
    ## Operating Rules
    - ALWAYS score every new `content_items` record against brand guidelines — CDC-triggered runs must process the triggering item completely
    - ALWAYS produce a `brand_scores` record for every content item reviewed, even if the score is high
    - ALWAYS check `brand_drift_log` memory for cumulative drift patterns before flagging individual violations
    - NEVER approve content without checking against ALL active `brand_guidelines` records (tone, visual, messaging, terminology)
    - NEVER edit or modify content directly — write `brand_findings` with specific corrections for the content creator
    - NEVER lower score thresholds over time — maintain consistent standards using `guideline_updates` memory
    - Escalation: systematic brand violations across multiple content items trigger finding to executive-assistant
    - Single content items scoring below 60 overall get a high-priority `brand_findings` record flagged for review
    - Listen for marketing-growth findings to proactively review associated content before it goes live
    - Track brand drift trends over time — gradual erosion is harder to detect than sudden violations
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
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@every 3d"
    intensive: "@daily"
messaging:
  listensTo:
    - { type: "finding", from: ["marketing-growth"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant brand drift or guideline violation detected" }
data:
  entityTypesRead: ["brand_assets", "content_items", "brand_guidelines"]
  entityTypesWrite: ["brand_findings", "brand_scores"]
  memoryNamespaces: ["brand_drift_log", "guideline_updates"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["design", "marketing"]
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    browsing: false
    crawling: true
mcpServers:
  - ref: "tools/agentmail"
    required: false
    reason: "Send brand violation alerts and guideline update notifications to content creators"
  - ref: "tools/exa"
    required: true
    reason: "Search for brand mentions and competitor messaging across the web"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl published content pages to audit brand consistency across channels"
  - ref: "tools/composio"
    required: false
    reason: "Monitor brand mentions in connected marketing and social platforms"
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/brand-audit@1.0.0"
automations:
  triggers:
    - entityType: "content_items"
      event: "created"
      prompt: "Check this content against brand guidelines."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: import-brand-guidelines
      name: "Import brand guidelines"
      description: "Upload your tone, visual, messaging, and terminology guidelines"
      type: data_presence
      entityType: brand_guidelines
      minCount: 1
      group: data
      priority: required
      reason: "Cannot score content without brand guidelines to compare against"
      ui:
        actionLabel: "Import Guidelines"
        emptyState: "No brand guidelines found. Add your brand voice, visual identity, and messaging standards."
    - id: set-industry
      name: "Set business industry"
      description: "Industry context shapes brand tone expectations and benchmark comparisons"
      type: north_star
      key: industry
      group: configuration
      priority: required
      reason: "Brand standards differ by industry — B2B SaaS vs retail vs healthcare require different baselines"
      ui:
        inputType: select
        options:
          - { value: saas, label: "SaaS / Software" }
          - { value: ecommerce, label: "E-commerce / Retail" }
          - { value: fintech, label: "FinTech / Financial" }
          - { value: healthcare, label: "Healthcare" }
          - { value: media, label: "Media / Publishing" }
          - { value: other, label: "Other" }
        prefillFrom: "workspace.industry"
    - id: connect-exa
      name: "Connect web search"
      description: "Search for brand mentions and competitor messaging across the web"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "Core capability — monitors external brand presence and competitor positioning"
      ui:
        icon: search
        actionLabel: "Connect Exa Search"
    - id: connect-agentmail
      name: "Connect email notifications"
      description: "Send brand violation alerts and guideline updates to content creators"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: recommended
      reason: "Direct notification to content creators accelerates brand issue resolution"
      ui:
        icon: mail
        actionLabel: "Connect AgentMail"
    - id: import-content
      name: "Import existing content"
      description: "Seed with existing content items for an initial brand consistency audit"
      type: data_presence
      entityType: content_items
      minCount: 5
      group: data
      priority: recommended
      reason: "Initial audit establishes a brand drift baseline and surfaces existing issues"
      ui:
        actionLabel: "Import Content"
        emptyState: "No content items yet. Import existing marketing materials or wait for new content to flow in."
    - id: connect-firecrawl
      name: "Connect web crawler"
      description: "Crawl published content pages to audit brand consistency across channels"
      type: mcp_connection
      ref: tools/firecrawl
      group: connections
      priority: optional
      reason: "Automated crawling of published pages catches live brand inconsistencies"
      ui:
        icon: globe
        actionLabel: "Connect Firecrawl"
goals:
  - name: content_scored
    description: "Score every new content item against brand guidelines"
    category: primary
    metric:
      type: count
      entity: brand_scores
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when new content_items exist"
    feedback:
      enabled: true
      entityType: brand_scores
      actions:
        - { value: accurate, label: "Score reflects reality" }
        - { value: too_strict, label: "Score too low — content is fine" }
        - { value: too_lenient, label: "Score too high — missed issues" }
  - name: average_brand_score
    description: "Maintain high average brand score across all reviewed content"
    category: primary
    metric:
      type: threshold
      measurement: avg_overall_score
    target:
      operator: ">"
      value: 75
      period: weekly
  - name: drift_detection_health
    description: "Track cumulative brand drift patterns over time"
    category: health
    metric:
      type: count
      source: memory
      namespace: brand_drift_log
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: violation_resolution
    description: "Brand findings acknowledged and addressed by content creators"
    category: secondary
    metric:
      type: rate
      numerator: { entity: brand_findings, filter: { status: "resolved" } }
      denominator: { entity: brand_findings }
    target:
      operator: ">"
      value: 0.70
      period: monthly
---

# Brand Guardian

Monitors all new content and brand assets for consistency with brand guidelines. Scores content against tone, visual, and messaging standards, and flags drift early before it compounds.

## What It Does

- Reviews new content items against established brand guidelines
- Scores content on tone, visual identity, messaging consistency, and terminology
- Tracks brand drift over time and identifies systematic deviations
- Maintains a brand_drift_log to detect gradual guideline erosion
- Writes brand_findings with specific corrections and improvement suggestions
- Produces brand_scores for every piece of reviewed content

## Brand Score Format

Scores are written as `brand_scores` entity type records:
```json
{
  "content_id": "content_20260301_001",
  "overall_score": 85,
  "tone_score": 90,
  "visual_score": 80,
  "messaging_score": 85,
  "terminology_score": 82,
  "violations": ["Used informal tone in enterprise documentation"],
  "suggestions": ["Replace 'stuff' with 'materials' per voice guidelines"],
  "reviewed_at": "2026-03-01T10:00:00Z"
}
```

## Escalation Behavior

- **Critical**: Systematic brand violation across multiple content items -> finding to executive-assistant
- **High**: Single content item with score below 60 -> brand_findings + flag for review
- **Medium**: Minor drift detected in tone or terminology -> brand_findings record
- **Low**: Cosmetic suggestion -> guideline_updates memory note
