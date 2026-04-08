---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: knowledge-base-curator
  displayName: "Knowledge Base Curator"
  version: "1.0.5"
  description: "Organizes and updates knowledge base articles."
  category: productivity
  tags: ["knowledge", "documentation", "organization"]
agent:
  capabilities: ["content_organization", "knowledge_management"]
  hostingMode: "openclaw"
  defaultDomain: "general"
  instructions: |
    ## Operating Rules
    - ALWAYS read `content_quality` memory before analysis — prior quality scores and staleness markers prevent re-auditing fresh content.
    - ALWAYS read `search_patterns` memory to identify which topics users search for most — prioritize gap analysis for high-search, low-coverage topics.
    - NEVER delete or archive a KB article without first writing an organization_suggestions record explaining why — all content decisions must be traceable.
    - NEVER mark an article as outdated based solely on age — verify against current product state or recent support findings before flagging.
    - When customer-support sends a finding about common questions lacking KB coverage, prioritize creating a kb_updates record with a draft outline for that topic.
    - Send a finding to customer-support when a KB article is updated or created that covers a known support gap — close the feedback loop.
    - Escalate to executive-assistant (finding) only for significant systemic KB gaps (e.g., entire product area undocumented) or critically outdated content that could mislead users.
    - Use the memory-lancedb plugin for semantic search across article content — detect near-duplicate articles and identify content clusters that should be consolidated.
    - Prioritize actionable improvements (merge duplicates, update outdated steps, fill gaps) over cosmetic suggestions.
    - Track content quality scores in memory across runs to measure improvement trajectory, not just point-in-time state.
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
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["customer-support"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant KB gap or outdated content requiring review" }
    - { type: "finding", to: ["customer-support"], when: "KB article updated or created covering common support topic" }
data:
  entityTypesRead: ["kb_articles", "usage_analytics"]
  entityTypesWrite: ["kb_updates", "organization_suggestions"]
  memoryNamespaces: ["content_quality", "search_patterns"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["general", "support"]
presence:
  web:
    search: true
    crawling: true
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
plugins:
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    required: true
    reason: "Semantic recall of article content for gap detection, duplicate identification, and content quality tracking across runs"
mcpServers:
  - ref: "tools/notion"
    required: false
    reason: "Manages knowledge base articles and documentation in Notion"
  - ref: "tools/exa"
    required: true
    reason: "Search for authoritative sources to verify and enrich knowledge base content"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl product documentation and help sites to identify content gaps and outdated information"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-mission
      name: "Set product/company mission"
      description: "Company context used to evaluate KB article relevance and accuracy"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "KB quality audits must be grounded in what the product actually does"
      ui:
        inputType: text
        placeholder: "We help businesses move data in real-time..."
    - id: connect-exa
      name: "Connect web search"
      description: "Search for authoritative sources to verify and enrich KB content"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "Content verification and gap filling require external source research"
      ui:
        icon: search
        actionLabel: "Connect Exa Search"
    - id: import-kb-articles
      name: "Import knowledge base articles"
      description: "Existing articles are needed for quality auditing and gap analysis"
      type: data_presence
      entityType: kb_articles
      minCount: 5
      group: data
      priority: required
      reason: "Cannot audit or organize content without existing KB articles"
      ui:
        actionLabel: "Import Articles"
        emptyState: "No KB articles found. Import from your knowledge base platform."
    - id: connect-firecrawl
      name: "Connect web crawler"
      description: "Crawl product docs and help sites to identify content gaps"
      type: mcp_connection
      ref: tools/firecrawl
      group: connections
      priority: recommended
      reason: "Crawling existing documentation surfaces outdated pages and broken links"
      ui:
        icon: crawl
        actionLabel: "Connect Firecrawl"
    - id: import-usage-analytics
      name: "Import search analytics"
      description: "User search patterns reveal which topics need better coverage"
      type: data_presence
      entityType: usage_analytics
      minCount: 10
      group: data
      priority: recommended
      reason: "Search analytics identify high-demand topics with low or missing coverage"
      ui:
        actionLabel: "Import Analytics"
        emptyState: "No usage analytics found. Import search logs from your KB platform."
goals:
  - name: content_quality_audit
    description: "Audit KB articles for accuracy, freshness, and completeness each run"
    category: primary
    metric:
      type: count
      entity: kb_updates
      filter: { type: { "$in": ["outdated_flag", "update_suggestion", "gap_draft"] } }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "at least one actionable improvement per weekly run"
  - name: gap_coverage
    description: "High-search topics have corresponding KB articles"
    category: primary
    metric:
      type: rate
      numerator: { entity: kb_articles, filter: { coverage_status: "covered" } }
      denominator: { entity: usage_analytics, filter: { search_volume: { "$gt": 10 } } }
    target:
      operator: ">"
      value: 0.80
      period: monthly
      condition: "80% of high-demand topics have KB coverage"
  - name: duplicate_detection
    description: "Identify and suggest consolidation of near-duplicate articles"
    category: secondary
    metric:
      type: count
      entity: organization_suggestions
      filter: { type: "duplicate_merge" }
    target:
      operator: ">="
      value: 0
      period: monthly
  - name: quality_score_tracking
    description: "Content quality scores tracked and improving over time"
    category: health
    metric:
      type: count
      source: memory
      namespace: content_quality
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "cumulative growth"
---

# Knowledge Base Curator

Reviews knowledge base content weekly. Identifies outdated articles, suggests improvements, and organizes content.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
