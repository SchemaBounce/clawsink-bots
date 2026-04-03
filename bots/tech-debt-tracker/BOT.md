---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: tech-debt-tracker
  displayName: "Tech Debt Tracker"
  version: "1.0.1"
  description: "Analyzes code review findings and quality metrics to identify technical debt patterns, track debt over time, and suggest refactoring priorities."
  category: engineering
  tags: ["tech-debt", "code-quality", "refactoring", "engineering"]
agent:
  capabilities: ["analysis", "pattern-detection", "reporting"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS check North Star keys `quality_standards` and `tech_stack` before classifying debt — thresholds (coverage, complexity, duplication) are workspace-specific.
    - ALWAYS classify each debt item with severity (critical/high/medium/low), area (module/service), and estimated remediation effort (hours/days).
    - ALWAYS cross-reference new findings against existing `tech_debt_items` to avoid creating duplicate entries — update severity or evidence on existing items instead.
    - NEVER create a debt item without linking it to at least one source finding (review_findings or code_quality_metrics).
    - Route refactoring opportunities to software-architect when the debt item has a clear remediation path and estimated effort under 2 days.
    - Route backlog suggestions to sprint-planner when debt items warrant scheduled work — include priority justification and effort estimate.
    - Send trend summaries to release-manager on each scheduled run so codebase health is visible in release planning.
    - When receiving findings from code-reviewer, check if the issue matches an existing debt pattern in `debt_patterns` memory — if so, increment the frequency count.
    - When receiving findings from api-tester, correlate test failures with known debt areas to surface compounding risks.
    - Update `debt_patterns` memory when patterns emerge across 3+ findings — flag the pattern as systemic.
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
    light: "@monthly"
    standard: "@weekly"
    intensive: "@every 3d"
  cronExpression: "0 6 * * 1"
messaging:
  listensTo:
    - { type: "finding", from: ["code-reviewer", "api-tester"] }
  sendsTo:
    - { type: "finding", to: ["software-architect"], when: "refactoring opportunity identified" }
    - { type: "finding", to: ["sprint-planner"], when: "backlog items suggested from debt analysis" }
    - { type: "finding", to: ["release-manager"], when: "debt trend report ready" }
data:
  entityTypesRead: ["review_findings", "code_quality_metrics", "gh_issues"]
  entityTypesWrite: ["tech_debt_items", "quality_trends"]
  memoryNamespaces: ["debt_patterns", "working_notes"]
zones:
  zone1Read: ["quality_standards", "tech_stack"]
  zone2Domains: ["engineering"]
egress:
  mode: "none"
skills:
  - ref: "skills/trend-analysis@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
mcpServers:
  - ref: "tools/github"
    required: false
    reason: "Tracks technical debt issues across repositories"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-quality-standards
      name: "Define quality standards"
      description: "Set coverage thresholds, complexity limits, and acceptable duplication levels"
      type: north_star
      key: quality_standards
      group: configuration
      priority: required
      reason: "Cannot classify debt severity without workspace-specific quality thresholds"
      ui:
        inputType: json
        placeholder: '{"min_coverage": 80, "max_complexity": 15, "max_duplication_pct": 5}'
    - id: set-tech-stack
      name: "Set tech stack"
      description: "Languages, frameworks, and tools in use — contextualizes debt analysis"
      type: north_star
      key: tech_stack
      group: configuration
      priority: required
      reason: "Debt classification and remediation advice depend on the technology context"
      ui:
        inputType: text
        placeholder: "TypeScript, React, Go, PostgreSQL"
    - id: connect-github
      name: "Connect GitHub"
      description: "Tracks technical debt issues and correlates with code review findings"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: recommended
      reason: "Enables issue tracking, duplicate detection, and PR-level debt correlation"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
    - id: import-review-findings
      name: "Import code review findings"
      description: "Seed with existing findings so debt patterns are detected from day one"
      type: data_presence
      entityType: review_findings
      minCount: 5
      group: data
      priority: recommended
      reason: "Pattern detection requires multiple findings — sparse data delays actionable insights"
      ui:
        actionLabel: "Import Findings"
        emptyState: "No review findings yet. Code Reviewer bot will generate these, or import from your code quality tool."
    - id: import-quality-metrics
      name: "Import quality metrics"
      description: "Baseline coverage, complexity, and duplication data for trend tracking"
      type: data_presence
      entityType: code_quality_metrics
      minCount: 1
      group: data
      priority: recommended
      reason: "Trend analysis needs at least one data point to establish a baseline"
      ui:
        actionLabel: "Import Metrics"
        emptyState: "No quality metrics found. Connect your CI pipeline or import a coverage report."
goals:
  - name: debt_items_identified
    description: "Identify and classify technical debt items from review findings and quality metrics"
    category: primary
    metric:
      type: count
      entity: tech_debt_items
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when new findings or metrics exist"
    feedback:
      enabled: true
      entityType: tech_debt_items
      actions:
        - { value: accurate, label: "Good classification" }
        - { value: overstated, label: "Severity too high" }
        - { value: understated, label: "Severity too low" }
        - { value: duplicate, label: "Already tracked elsewhere" }
  - name: trend_reporting
    description: "Produce quality trend data showing debt trajectory over time"
    category: primary
    metric:
      type: count
      entity: quality_trends
    target:
      operator: ">"
      value: 0
      period: weekly
  - name: pattern_detection_health
    description: "Continuously learn systemic debt patterns from recurring findings"
    category: health
    metric:
      type: count
      source: memory
      namespace: debt_patterns
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: remediation_routing
    description: "Route actionable debt items to software-architect or sprint-planner"
    category: secondary
    metric:
      type: count
      entity: tech_debt_items
      filter: { status: "routed" }
    target:
      operator: ">"
      value: 0
      period: monthly
---

# Tech Debt Tracker

Analyzes code review findings and quality metrics to identify technical debt patterns, categorize and prioritize debt items, and track quality trends over time. Helps engineering teams make data-driven refactoring decisions.

## What It Does

- Consumes findings from code-reviewer and api-tester to identify recurring quality issues
- Classifies debt items by severity, area, and estimated remediation effort
- Tracks quality trends per module and per time period (coverage, complexity, duplication)
- Sends refactoring recommendations to software-architect when patterns emerge
- Suggests backlog items to sprint-planner when debt warrants scheduled work
- Reports trend summaries to release-manager for visibility into codebase health

## How It Works with Other Bots

Tech Debt Tracker sits downstream of code-reviewer and api-tester, consuming their findings as input. It synthesizes these into structured debt items and trend data, then routes actionable recommendations to software-architect (for refactoring), sprint-planner (for backlog prioritization), and release-manager (for reporting).

## Recommended North Star Keys

Set these in your workspace's North Star zone for best results:

- `quality_standards` — Code coverage thresholds, complexity limits, acceptable duplication levels
- `tech_stack` — Languages, frameworks, and tools in use for contextualizing debt analysis
