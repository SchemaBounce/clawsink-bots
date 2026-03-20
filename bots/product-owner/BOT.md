---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: product-owner
  displayName: "Product Owner"
  version: "1.0.0"
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
    ## Tool Usage
    - Query `cs_findings` for customer pain points, feature requests, and churn signals
    - Query `ba_findings` for cross-domain trends that inform product strategy
    - Query `mktg_findings` for market trends, competitive intelligence, and positioning insights
    - Query `tickets` and `contacts` for raw customer data; `campaigns` for marketing context
    - Write to `gh_issues` with fields: `title`, `body`, `labels`, `priority`, `user_stories`, `acceptance_criteria`, `customer_signals`, `source_findings`
    - Write to `feature_requests` for tracking aggregated request themes and their signal strength
    - Write to `po_findings` for strategic product insights; `po_alerts` for urgent product risks
    - Use `working_notes` memory for in-progress feature clustering between runs
    - Use `customer_signals` memory to accumulate and count feedback themes across runs
    - Use `backlog_priorities` memory to maintain the current prioritized feature list
    - Use `learned_patterns` memory to store validated demand patterns (e.g., "enterprise customers consistently request SSO")
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 25000
  estimatedCostTier: "high"
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
egress:
  mode: "none"
skills:
  - ref: "skills/record-monitoring@1.0.0"
requirements:
  minTier: "starter"
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
