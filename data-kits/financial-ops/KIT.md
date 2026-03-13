---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: financial-ops
  displayName: Financial Operations
  version: "1.0.0"
  description: "Small business accounting data — transactions, invoices, budgets, and recurring charges"
  category: horizontal
  tags:
    - finance
    - accounting
    - invoices
    - transactions
    - budgets
    - cash-flow
    - recurring-billing
    - bookkeeping
  author: SchemaBounce
compatibility:
  teams: []
  composableWith:
    - restaurant
    - real-estate
    - healthcare
    - ecommerce
    - legal
    - consulting
    - logistics
    - construction
entityPrefix: "fin_"
entityCount: 4
graphEdgeTypes:
  - PAID_BY
  - GENERATES
vectorCollections: []
---

# Financial Operations

A horizontal financial operations kit for small and mid-size businesses. Covers the core accounting entities: transactions, invoices, budgets, and recurring charges. Designed to compose with any industry kit to add financial tracking.

## What's Included

- **Transactions** — income, expenses, and transfers with categorization, vendor tracking, and reconciliation status
- **Invoices** — accounts receivable and payable with line items, payment terms, and aging tracking
- **Budgets** — period-based budget allocation with spend tracking and variance analysis
- **Recurring Charges** — automated recurring billing and subscription management with next-due-date tracking

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Gross Margin | >50% (services), >30% (product) | Core profitability indicator |
| Net Profit Margin | >10% | Business sustainability |
| Cash Flow Runway | >6 months | Survival metric for SMBs |
| Accounts Receivable Days | <30 days | Cash collection efficiency |
| Budget Variance | <5% | Planning accuracy |
| Revenue Growth Rate | >10% YoY | Business trajectory |

## Graph Relationships

- `PAID_BY` links transactions to the invoices they settle
- `GENERATES` links recurring charges to the invoices they automatically create

## Composability

This is the most broadly composable horizontal kit. It pairs with nearly every industry kit: restaurants need it for food cost tracking, legal firms for billable hour invoicing, construction for project-based budgeting, and e-commerce for order reconciliation.

## Migration Note

This kit enhances the legacy `shared/domain-schemas/finance.json` schema pack with graph relationships (transaction-to-invoice linking), recurring charge management, and memory-bootstrapped financial KPIs. The old `accounts` entity type is replaced by the more specific `fin_recurring` entity since bank account management is typically handled by external integrations.
