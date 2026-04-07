---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: quickbooks
  displayName: "QuickBooks"
  version: "1.0.0"
  description: "QuickBooks Online accounting — invoices, payments, expenses, and reports"
  tags: ["quickbooks", "accounting", "invoices", "payments", "finance"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "quickbooks-mcp"]
env:
  - name: QUICKBOOKS_CLIENT_ID
    description: "QuickBooks OAuth client ID"
    required: true
  - name: QUICKBOOKS_CLIENT_SECRET
    description: "QuickBooks OAuth client secret"
    required: true
  - name: QUICKBOOKS_REALM_ID
    description: "QuickBooks company ID"
    required: true
  - name: QUICKBOOKS_REFRESH_TOKEN
    description: "QuickBooks OAuth refresh token"
    required: true
tools:
  - name: create_invoice
    description: "Create an invoice"
    category: invoices
  - name: list_invoices
    description: "List invoices"
    category: invoices
  - name: get_invoice
    description: "Get invoice details"
    category: invoices
  - name: send_invoice
    description: "Email an invoice to customer"
    category: invoices
  - name: create_payment
    description: "Record a payment"
    category: payments
  - name: list_payments
    description: "List payments"
    category: payments
  - name: create_expense
    description: "Create an expense entry"
    category: expenses
  - name: list_expenses
    description: "List expenses"
    category: expenses
  - name: get_profit_loss
    description: "Get profit and loss report"
    category: reports
  - name: get_balance_sheet
    description: "Get balance sheet report"
    category: reports
  - name: list_customers
    description: "List customers"
    category: contacts
  - name: list_vendors
    description: "List vendors"
    category: contacts
---

# QuickBooks MCP Server

Provides QuickBooks Online API tools for bots that manage invoices, payments, expenses, and financial reports.

## Which Bots Use This

- **accountant** -- Creates invoices, tracks expenses, reconciles payments, and generates financial reports
- **executive-assistant** -- Pulls profit/loss and balance sheet reports for leadership reviews

## Setup

1. Create a QuickBooks Developer account and register an app at developer.intuit.com
2. Connect your QuickBooks Online company and obtain OAuth credentials
3. Add `QUICKBOOKS_CLIENT_ID`, `QUICKBOOKS_CLIENT_SECRET`, `QUICKBOOKS_REALM_ID`, and `QUICKBOOKS_REFRESH_TOKEN` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single QuickBooks server instance across finance bots:

```yaml
mcpServers:
  - ref: "tools/quickbooks"
    reason: "Finance bots need QuickBooks access for invoicing, expense tracking, and reporting"
    config:
      default_currency: "USD"
```
