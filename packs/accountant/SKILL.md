---
apiVersion: openclaw.schemabounce.com/v1
kind: SkillPack
metadata:
  name: accountant
  displayName: "Accountant"
  version: "1.0.0"
  description: "Invoice categorization, expense tracking, budget monitoring, billing anomaly detection."
  category: finance
  tags: ["finance", "invoices", "expenses", "budget", "billing"]
agent:
  capabilities: ["finance", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "finance"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
  maxTokenBudget: 50000
schedule:
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "business-analyst"] }
    - { type: "finding", from: ["inventory-manager"] }
  sendsTo:
    - { type: "finding", to: ["business-analyst", "executive-assistant"], when: "budget anomaly or overspend detected" }
    - { type: "alert", to: ["executive-assistant"], when: "critical billing issue or payment failure" }
data:
  entityTypesRead: ["transactions", "invoices", "inv_findings"]
  entityTypesWrite: ["acct_findings", "acct_alerts", "transactions", "invoices"]
  memoryNamespaces: ["working_notes", "learned_patterns", "thresholds"]
zones:
  zone1Read: ["mission", "budget_constraints", "industry"]
  zone2Domains: ["finance"]
requirements:
  minTier: "starter"
---

# Accountant

Monitors financial health by tracking invoices, categorizing expenses, monitoring budgets, and detecting billing anomalies. Runs daily to keep financial data organized.

## What It Does

- Categorizes new invoices and transactions
- Tracks spending against budget constraints
- Detects billing anomalies (unexpected charges, duplicate invoices)
- Monitors payment patterns and cash flow indicators
- Flags overdue invoices and upcoming payment deadlines

## Escalation Behavior

- **Critical**: Payment failure, billing system error → alerts executive-assistant
- **High**: Budget overspend, large unexpected charge → finding to business-analyst
- **Medium**: Invoice categorization uncertainty → logged as acct_findings
- **Low**: Routine transaction processing → memory update only

## Recommended Setup

Set these North Star keys:
- `budget_constraints` — Monthly/quarterly budget limits by category
