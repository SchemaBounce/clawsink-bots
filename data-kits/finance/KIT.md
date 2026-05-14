---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: finance
  displayName: Finance
  version: "1.0.0"
  description: "Finance team data covering transactions, invoices, budgets, recurring charges, and fraud signals for business accounting and risk monitoring"
  domain: finance
  category: domain
  tags:
    - finance
    - accounting
    - invoices
    - transactions
    - budgets
    - cash-flow
    - fraud-detection
    - recurring-billing
    - bookkeeping
  author: SchemaBounce
compatibility:
  teams:
    - finance-team
  composableWith:
    - engineering
    - legal-compliance
    - hr
entityPrefix: "fin_"
entityCount: 5
graphEdgeTypes:
  - PAID_BY
  - GENERATES
  - FLAGS
vectorCollections: []
---

# Finance

A domain data kit for finance teams. Covers transactions, invoices, budgets, recurring charges, and fraud signal records. Tuned for internal finance departments rather than small business bookkeeping.

## What's Included

- **Transactions** - Income, expenses, and transfers with categorization and reconciliation tracking
- **Invoices** - Accounts receivable and payable with aging, line items, and payment terms
- **Budgets** - Period-based budget allocation with spend tracking and variance analysis
- **Recurring Charges** - Subscriptions, retainers, and periodic charges with auto-invoice capability
- **Fraud Signals** - Transaction anomaly records with investigation status and risk scoring

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Gross Margin | >50% (services), >30% (product) | Core profitability |
| Net Profit Margin | >10% | Business sustainability |
| Cash Flow Runway | >6 months | Survival metric |
| Accounts Receivable Days | <30 days | Cash collection efficiency |
| Budget Variance | <5% | Planning accuracy |
| Fraud Detection Rate | >95% within 24 hours | Financial integrity |

## Graph Relationships

- **PAID_BY** links a transaction to the invoice it settles
- **GENERATES** links a recurring charge to the invoices it creates automatically
- **FLAGS** links a fraud signal to the transaction it relates to

## Composability

Pairs with:
- **engineering** - map engineering cost center spend to deployment output
- **legal-compliance** - link invoice disputes and fraud findings to legal matters
- **hr** - align headcount growth to budget allocation trends
