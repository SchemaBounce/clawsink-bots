---
apiVersion: openclaw.schemabounce.com/v1
kind: SkillPack
metadata:
  name: business-analyst
  displayName: "Business Analyst"
  version: "1.0.0"
  description: "Cross-domain analysis, trend detection, and strategic recommendations from all bot findings."
  category: management
  tags: ["analysis", "trends", "strategy", "cross-domain", "insights"]
agent:
  capabilities: ["analytics", "management"]
  hostingMode: "openclaw"
  defaultDomain: "management"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
  maxTokenBudget: 100000
schedule:
  default: "@every 12h"
  recommendations:
    light: "@daily"
    standard: "@every 12h"
    intensive: "@every 6h"
messaging:
  listensTo:
    - { type: "finding", from: ["sre-devops", "data-engineer", "accountant", "customer-support", "inventory-manager", "legal-compliance", "marketing-growth"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "strategic insight or cross-domain correlation" }
    - { type: "request", to: ["data-engineer", "accountant"], when: "needs deeper data for analysis" }
data:
  entityTypesRead: ["sre_findings", "de_findings", "acct_findings", "cs_findings", "inv_findings", "legal_findings", "mktg_findings", "transactions", "pipeline_status", "incidents"]
  entityTypesWrite: ["ba_findings", "ba_alerts"]
  memoryNamespaces: ["working_notes", "learned_patterns", "trend_baselines"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["management", "operations", "finance", "support", "engineering"]
requirements:
  minTier: "starter"
---

# Business Analyst

The analytical brain of the bot team. Reads findings from ALL domain-specific bots, detects cross-domain trends, and produces strategic recommendations aligned with business priorities.

## What It Does

- Correlates findings across all bot domains (ops, finance, support, engineering)
- Detects trends: recurring issues, improving/degrading metrics, seasonal patterns
- Produces strategic recommendations tied to quarterly priorities
- Identifies cost-saving opportunities and efficiency gains
- Flags risks that span multiple domains

## Escalation Behavior

- Sends strategic insights and cross-domain correlations to executive-assistant
- Requests deeper data from data-engineer or accountant when analysis needs more context
- Does not receive alerts directly — works on findings from other bots
