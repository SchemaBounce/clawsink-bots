---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: stripe
  displayName: "Stripe"
  version: "1.0.0"
  description: "Stripe payment and billing tools for financial operations"
  tags: ["stripe", "payments", "billing", "subscriptions", "invoices"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-stripe", "--tools=all"]
env:
  - name: STRIPE_API_KEY
    description: "Stripe API secret key (sk_live_... or sk_test_...)"
    required: true
tools:
  - name: stripe_list_customers
    description: "List customers with optional filters"
    category: customers
  - name: stripe_create_customer
    description: "Create a new customer"
    category: customers
  - name: stripe_list_invoices
    description: "List invoices with optional filters"
    category: invoices
  - name: stripe_create_invoice
    description: "Create a draft invoice"
    category: invoices
  - name: stripe_list_subscriptions
    description: "List active subscriptions"
    category: subscriptions
  - name: stripe_list_charges
    description: "List payment charges"
    category: payments
  - name: stripe_create_refund
    description: "Create a refund for a charge"
    category: payments
  - name: stripe_list_balance_transactions
    description: "List balance transactions"
    category: payments
  - name: stripe_retrieve_balance
    description: "Get current account balance"
    category: payments
  - name: stripe_list_payment_intents
    description: "List payment intents"
    category: payments
  - name: stripe_search_charges
    description: "Search charges with query"
    category: payments
  - name: stripe_list_disputes
    description: "List payment disputes"
    category: payments
---

# Stripe MCP Server

Provides Stripe payment and billing tools for bots that manage financial operations, invoicing, and subscription tracking.

## Which Bots Use This

- **accountant** -- Reconciles invoices, tracks payments, monitors disputes
- **revenue-analyst** -- Analyzes MRR/ARR trends, subscription metrics
- **fraud-detector** -- Monitors charges for suspicious patterns, reviews disputes

## Setup

1. Get your Stripe API key from the Stripe Dashboard (use test keys for development)
2. Add `STRIPE_API_KEY` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

```yaml
mcpServers:
  - ref: "tools/stripe"
    reason: "Financial bots need Stripe access for payment tracking and reconciliation"
```
