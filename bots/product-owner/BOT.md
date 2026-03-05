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
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
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
  zone2Domains: ["product", "marketing"]
skills:
  - inline: "core-analysis"
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
