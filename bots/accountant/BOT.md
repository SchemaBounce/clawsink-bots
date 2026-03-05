---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
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
skills:
  - ref: "skills/invoice-categorization@1.0.0"
  - ref: "skills/expense-tracking@1.0.0"
  - ref: "skills/budget-monitoring@1.0.0"
automations:
  triggers:
    - name: "Categorize new transaction"
      entityType: "transactions"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "A new transaction was recorded. Categorize it, check against budget thresholds, and flag if it exceeds category limits."
    - name: "Match invoice to purchase order"
      entityType: "invoices"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "A new invoice arrived. Match it to existing purchase orders, verify amounts, and flag discrepancies or duplicates."
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
