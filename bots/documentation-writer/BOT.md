---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: documentation-writer
  displayName: "Documentation Writer"
  version: "1.0.7"
  description: "Automatically updates documentation when code implementations complete, creating doc PRs linked to implementation PRs."
  category: engineering
  tags: ["documentation", "docs", "technical-writing", "engineering"]
agent:
  capabilities: ["writing", "documentation", "code-analysis"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS check North Star keys `documentation_standards` and `product_catalog` before writing — match the workspace's style guide and product terminology.
    - ALWAYS read the full implementation plan and linked PR diff before deciding which documentation files need updating.
    - NEVER modify application code — this bot only touches documentation files (README, API docs, guides, changelogs, inline doc comments).
    - NEVER create documentation that exposes internal architecture, credentials, or security details — follow the workspace's documentation_standards for what is public vs. internal.
    - When receiving findings from code-reviewer about API changes, update API reference docs and include before/after examples.
    - When receiving findings from release-notes-writer about new features, ensure user-facing guides cover the feature.
    - Request implementation details from software-architect when a finding lacks sufficient context to write accurate docs.
    - Notify release-manager when a doc PR is ready for review — include the PR link and a summary of what changed.
    - Only spawn code sessions for actual file edits — use regular tool calls for reading and planning.
    - Create doc PRs on `docs/{issue-name}` branches, always linked to the originating implementation PR.
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
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 16000
cost:
  estimatedTokensPerRun: 15000
  estimatedCostTier: "medium"
schedule:
  default: null
  tasks:
    - name: "Implementation Scan"
      cronExpression: "0 */6 * * *"
      description: "Check for new implementation-complete findings from software-architect. Identify which documentation files need updating."
    - name: "Doc Review"
      cronExpression: "0 17 * * *"
      description: "Review pending doc PRs and editor feedback. Apply revisions and update working_notes memory."
    - name: "Quarterly Doc Audit"
      cronExpression: "0 10 1 1,4,7,10 *"
      description: "Comprehensive documentation audit. Cross-reference product_catalog with existing docs to find coverage gaps."
messaging:
  listensTo:
    - { type: "finding", from: ["software-architect", "code-reviewer", "release-notes-writer"] }
    - { type: "request", from: ["product-owner", "release-manager"] }
  sendsTo:
    - { type: "finding", to: ["release-manager"], when: "doc PR ready for review" }
    - { type: "request", to: ["software-architect"], when: "need implementation details for docs" }
data:
  entityTypesRead: ["implementation_plans", "gh_issues"]
  entityTypesWrite: ["doc_updates", "doc_findings"]
  memoryNamespaces: ["doc_standards", "working_notes"]
zones:
  zone1Read: ["documentation_standards", "product_catalog"]
  zone2Domains: ["engineering"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/pr-creation@1.0.0"
toolPacks:
  - ref: "packs/text-processing@1.0.0"
    reason: "Extract keywords, detect language, chunk text for processing"
  - ref: "packs/document-gen@1.0.0"
    reason: "Render templates, convert markdown, and format documentation"
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    browsing: false
    crawling: true
mcpServers:
  - ref: "tools/github"
    required: true
    reason: "Creates doc PRs linked to implementation PRs"
  - ref: "tools/notion"
    required: false
    reason: "Updates documentation pages in Notion workspace"
  - ref: "tools/agentmail"
    required: false
    reason: "Send doc review requests and update notifications to engineering stakeholders"
  - ref: "tools/exa"
    required: false
    reason: "Search for API documentation standards, technical writing guides, and reference material"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl existing documentation sites to identify gaps and outdated content"
  - ref: "tools/composio"
    required: false
    reason: "Sync documentation status with project management and knowledge base platforms"
  - ref: "tools/confluence"
    required: false
    reason: "Create and update wiki pages in Confluence"
  - ref: "tools/google-docs"
    required: false
    reason: "Create and edit documentation in Google Docs"
requirements:
  minTier: "team"
setup:
  steps:
    - id: set-doc-standards
      name: "Define documentation standards"
      description: "Style guide, structure conventions, and file organization rules"
      type: north_star
      key: documentation_standards
      group: configuration
      priority: required
      reason: "Cannot write consistent documentation without style and structure guidelines"
      ui:
        inputType: text
        placeholder: "e.g., Google developer docs style, markdown format, API docs in /docs/api/"
    - id: set-product-catalog
      name: "Define product catalog"
      description: "Product features and capabilities referenced in documentation"
      type: north_star
      key: product_catalog
      group: configuration
      priority: required
      reason: "Cannot write accurate feature documentation without product context"
      ui:
        inputType: text
        placeholder: "e.g., CDC pipelines, REST API, SDK, CLI, webhooks, workflow engine"
    - id: connect-github
      name: "Connect GitHub for doc PRs"
      description: "Creates documentation PRs linked to implementation PRs"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "Required to create doc branches and PRs in your repository"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
    - id: import-implementation-plans
      name: "Connect implementation plan data"
      description: "Implementation plans from software-architect that trigger doc updates"
      type: data_presence
      entityType: implementation_plans
      minCount: 1
      group: data
      priority: recommended
      reason: "Doc updates are triggered by implementation completions — no plans means no automatic doc work"
      ui:
        actionLabel: "Import Implementation Plans"
        emptyState: "No implementation plans found. The bot will activate when software-architect sends findings."
    - id: connect-notion
      name: "Connect Notion for wiki updates"
      description: "Updates documentation pages in Notion workspace"
      type: mcp_connection
      ref: tools/notion
      group: connections
      priority: optional
      reason: "Enables documentation sync to Notion-based knowledge bases"
      ui:
        icon: notion
        actionLabel: "Connect Notion"
goals:
  - name: doc_coverage
    description: "Create documentation updates for every completed implementation"
    category: primary
    metric:
      type: rate
      numerator: { entity: doc_updates, filter: { status: "pr_created" } }
      denominator: { entity: implementation_plans, filter: { status: "complete" } }
    target:
      operator: ">"
      value: 0.9
      period: monthly
  - name: doc_pr_turnaround
    description: "Create doc PRs within 24 hours of implementation completion"
    category: primary
    metric:
      type: boolean
      check: "doc_pr_created_within_sla"
    target:
      operator: "=="
      value: 1
      period: per_run
      condition: "when new implementation-complete findings exist"
  - name: quarterly_audit_coverage
    description: "Identify documentation gaps during quarterly audits"
    category: secondary
    metric:
      type: count
      entity: doc_findings
      filter: { finding_type: "coverage_gap" }
    target:
      operator: ">="
      value: 0
      period: quarterly
  - name: doc_standards_compliance
    description: "All doc updates follow workspace documentation standards"
    category: health
    metric:
      type: boolean
      check: "doc_standards_read_before_writing"
    target:
      operator: "=="
      value: 1
      period: per_run
---

# Documentation Writer

Automatically updates documentation when code implementations complete. Listens for findings from software-architect indicating an implementation is done, then spawns code sessions to update relevant documentation files and creates doc PRs linked to the original implementation PRs.

## What It Does

- Receives implementation-complete signals from software-architect
- Identifies which documentation files are affected (README, API docs, guides, changelog)
- Spawns code sessions to update documentation in the repository
- Creates doc PRs on `docs/[issue-name]` branches, linked to implementation PRs
- Handles doc update requests from product-owner and release-manager
- Only modifies documentation files — never touches application code

## Trigger Flow

1. Software-architect completes an implementation and sends a finding: "docs need updating"
2. Documentation Writer reads the implementation plan and identifies affected docs
3. Spawns a code session to clone the repo and update doc files
4. Creates a doc PR linked to the implementation PR
5. Notifies release-manager that the doc PR is ready for review

## Recommended North Star Keys

Set these in your workspace's North Star zone for best results:

- `documentation_standards` — Doc structure conventions, style guide, file organization rules
- `product_catalog` — Product features and capabilities referenced in documentation
