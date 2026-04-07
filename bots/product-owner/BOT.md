---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: product-owner
  displayName: "Product Owner"
  version: "1.0.5"
  description: "Customer feedback aggregation, market analysis, feature prioritization, backlog management via structured GitHub issue specs."
  category: management
  tags: ["product", "backlog", "feedback", "market-analysis", "prioritization", "github-issues"]
agent:
  capabilities: ["analytics", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "product"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star `product_roadmap` and `priorities` before prioritizing feature requests
    - ALWAYS aggregate multiple customer signals before writing a `gh_issues` record — never create an issue from a single data point
    - ALWAYS include `customer_signals` count and `source_findings` references in every gh_issues record for traceability
    - NEVER create duplicate gh_issues — search existing records by title/theme before writing new ones
    - NEVER prioritize features without aligning to the product roadmap and quarterly priorities
    - NEVER contact customer-support directly unless requesting clarification on specific feedback (use type=request)
    - Escalation: major churn signals or competitive threats go to executive-assistant immediately as type=finding
    - Send emerging customer signal patterns to business-analyst for deeper cross-domain analysis
    - Track feature request frequency over time in `customer_signals` memory to identify growing demand
    - Write structured `gh_issues` with user stories, acceptance criteria, and priority — ready for human review and GitHub creation
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
  default: "@every 12h"
  recommendations:
    light: "@daily"
    standard: "@every 12h"
    intensive: "@every 6h"
messaging:
  listensTo:
    - { type: "finding", from: ["customer-support", "business-analyst", "marketing-growth"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "prioritized feature recommendation or market shift" }
    - { type: "finding", to: ["business-analyst"], when: "customer signal pattern needing deeper analysis" }
    - { type: "request", to: ["customer-support"], when: "need more detail on specific customer feedback" }
data:
  entityTypesRead: ["cs_findings", "ba_findings", "mktg_findings", "tickets", "contacts", "campaigns"]
  entityTypesWrite: ["po_findings", "po_alerts", "gh_issues", "feature_requests"]
  memoryNamespaces: ["working_notes", "learned_patterns", "customer_signals", "backlog_priorities"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities", "product_roadmap"]
  zone2Domains: ["product", "marketing", "support"]
presence:
  email:
    required: true
    provider: agentmail
  web:
    search: true
    browsing: true
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
mcpServers:
  - ref: "tools/jira"
    required: false
    reason: "Prioritizes backlog, creates feature requests, manages roadmap"
  - ref: "tools/linear"
    required: false
    reason: "Prioritizes backlog and roadmap in Linear"
  - ref: "tools/agentmail"
    required: true
    reason: "Send feature prioritization updates, roadmap changes, and stakeholder communications"
  - ref: "tools/exa"
    required: true
    reason: "Search for customer feedback trends, feature request patterns, and competitive product capabilities"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse competitor product pages and user forums to gather feature intelligence"
  - ref: "tools/composio"
    required: false
    reason: "Connect to product management and customer feedback SaaS platforms"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-product-roadmap
      name: "Define product roadmap"
      description: "Set your current roadmap so features are prioritized against strategic goals"
      type: north_star
      key: product_roadmap
      group: configuration
      priority: required
      reason: "Cannot prioritize feature requests without a roadmap to align against"
      ui:
        inputType: textarea
        placeholder: "e.g., Q2: self-serve onboarding, Q3: enterprise SSO, Q4: marketplace launch"
    - id: set-priorities
      name: "Set quarterly priorities"
      description: "Define the top priorities for feature evaluation and backlog ordering"
      type: north_star
      key: priorities
      group: configuration
      priority: required
      reason: "Priorities determine which customer signals get escalated vs. deferred"
      ui:
        inputType: textarea
        placeholder: "e.g., 1. Reduce churn 2. Increase enterprise adoption 3. Improve onboarding"
    - id: connect-exa
      name: "Connect Exa for market research"
      description: "Enables searching for customer feedback trends and competitive product capabilities"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "Market intelligence and feature trend research for informed prioritization"
      ui:
        icon: exa
        actionLabel: "Connect Exa"
    - id: connect-agentmail
      name: "Connect email for stakeholder updates"
      description: "Sends feature prioritization updates, roadmap changes, and issue specs to stakeholders"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Primary channel for stakeholder communication and feature update delivery"
      ui:
        icon: email
        actionLabel: "Connect Email"
    - id: connect-project-tracker
      name: "Connect project tracker"
      description: "Links Jira or Linear so the bot can manage backlog and create feature requests"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "Backlog management and feature request tracking in your existing project tool"
      ui:
        icon: composio
        actionLabel: "Connect Project Tracker"
        helpUrl: "https://docs.schemabounce.com/integrations/project-management"
    - id: import-cs-findings
      name: "Import customer support findings"
      description: "Seed the bot with existing customer feedback for immediate signal clustering"
      type: data_presence
      entityType: cs_findings
      minCount: 5
      group: data
      priority: recommended
      reason: "Pre-existing customer signals enable immediate feature opportunity analysis"
      ui:
        actionLabel: "Import Findings"
        emptyState: "No customer support findings yet. The bot will begin processing once customer-support sends findings."
goals:
  - name: produce_feature_specs
    description: "Generate structured GitHub issue specs from aggregated customer signals"
    category: primary
    metric:
      type: count
      entity: gh_issues
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when customer signals exist"
  - name: signal_aggregation
    description: "Cluster customer feedback into themes before creating feature specs"
    category: primary
    metric:
      type: rate
      numerator: { entity: gh_issues, filter: { customer_signals: { "$gt": 1 } } }
      denominator: { entity: gh_issues }
    target:
      operator: ">="
      value: 0.8
      period: monthly
  - name: customer_signal_tracking
    description: "Continuously track and accumulate customer feedback patterns"
    category: health
    metric:
      type: count
      source: memory
      namespace: customer_signals
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: roadmap_alignment
    description: "Feature specs reference and align with the defined product roadmap"
    category: secondary
    metric:
      type: rate
      numerator: { entity: gh_issues, filter: { roadmap_aligned: true } }
      denominator: { entity: gh_issues }
    target:
      operator: ">="
      value: 0.9
      period: monthly
---

# Product Owner

Aggregates customer feedback from support tickets, marketing insights, and business analysis into a prioritized product backlog. Writes structured GitHub issue specs as ADL records for human review and creation.

## What It Does

- Reads customer support findings and tickets for feature requests, pain points, and churn signals
- Reads marketing and business analyst findings for market trends and competitive intel
- Clusters feedback into themes and identifies high-impact feature opportunities
- Prioritizes features against the product roadmap from North Star
- Writes structured gh_issues records (title, body, labels, priority, user_stories, acceptance_criteria)
- Tracks feature request frequency and customer impact scores over time

## GitHub Issue Spec Format

Issues are written as `gh_issues` entity type records:
```json
{
  "title": "Short issue title",
  "body": "Detailed description with context",
  "labels": ["enhancement", "customer-request"],
  "priority": "high",
  "user_stories": ["As a user, I want X so that Y"],
  "acceptance_criteria": ["Given A, when B, then C"],
  "customer_signals": 5,
  "source_findings": ["cs_20260224_003", "ba_20260224_001"]
}
```

## Escalation Behavior

- **Critical**: Major customer churn signal, competitive threat → finding to executive-assistant
- **High**: High-impact feature opportunity with strong signal → finding to executive-assistant
- **Medium**: Feature request cluster, market trend → gh_issues record + po_findings
- **Low**: Individual feedback notes → customer_signals memory update
