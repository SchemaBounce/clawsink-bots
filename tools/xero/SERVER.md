---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: xero
  displayName: "Xero"
  version: "1.0.0"
  description: "Xero accounting, invoices, contacts, bank transactions, and reports"
  tags: ["xero", "accounting", "invoices", "finance", "bookkeeping"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "xero-mcp@1.5.2"]
env:
  - name: XERO_CLIENT_ID
    description: "Xero OAuth2 client ID"
    required: true
  - name: XERO_CLIENT_SECRET
    description: "Xero OAuth2 client secret"
    required: true
  - name: XERO_TENANT_ID
    description: "Xero organization tenant ID"
    required: true
tools:
  - name: create_invoice
    description: "Create a sales invoice"
    category: invoices
  - name: list_invoices
    description: "List invoices"
    category: invoices
  - name: get_invoice
    description: "Get invoice details"
    category: invoices
  - name: send_invoice
    description: "Email an invoice"
    category: invoices
  - name: list_contacts
    description: "List contacts"
    category: contacts
  - name: create_contact
    description: "Create a contact"
    category: contacts
  - name: list_bank_transactions
    description: "List bank transactions"
    category: banking
  - name: create_bill
    description: "Create a bill/accounts payable"
    category: invoices
  - name: get_profit_loss
    description: "Get profit and loss report"
    category: reports
  - name: get_balance_sheet
    description: "Get balance sheet"
    category: reports
  - name: list_accounts
    description: "List chart of accounts"
    category: accounts
---

# Xero MCP Server

Provides Xero accounting tools for bots that manage invoicing, contacts, bank transactions, and financial reporting.

## Which Bots Use This

- **accountant** -- Invoicing, bill creation, bank transaction reconciliation, and financial reports (P&L, balance sheet)
- **executive-assistant** -- Financial summaries, outstanding invoice tracking, and cash flow visibility

## Setup

1. Create a Xero app at [developer.xero.com](https://developer.xero.com) and note the client ID and secret
2. Add `XERO_CLIENT_ID`, `XERO_CLIENT_SECRET`, and `XERO_TENANT_ID` to your workspace secrets
3. The tenant ID can be found in your Xero organization settings
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Xero server instance across finance bots:

```yaml
mcpServers:
  - ref: "tools/xero"
    reason: "Finance bots need Xero access for invoicing, reporting, and bookkeeping"
    config:
      default_currency: "USD"
```
