---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: stripe
  displayName: "Stripe"
  version: "1.0.0"
  description: "Stripe payment and billing tools for financial operations"
  tags: ["stripe", "payments", "billing", "subscriptions", "invoices"]
  category: "accounting"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
# Stripe uses HTTP Basic with the API key as the username and an empty
# password — the "single-credential http_basic" shape supported by the
# engine. Matches the curated mcp_validation.go behavior we are
# replacing.
auth:
  type: http_basic
  token_env: STRIPE_API_KEY

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@stripe/mcp@0.3.3", "--tools=all"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed OAuth
  # connection. Leaving these blank uses the workspace's Composio integration for
  # this service; provide values only to override the managed connection. Marked
  # required:true previously, which made the setup/reconnect modal demand
  # credentials the managed flow already covers.
  - name: STRIPE_API_KEY
    description: "Stripe API secret key (sk_live_... or sk_test_...)"
    required: false
    sensitive: true

# /v1/balance is a no-cost, no-side-effect endpoint that returns 200
# for a valid key and 401 for a bad one. Same endpoint the curated
# validator used.
validation:
  request:
    method: GET
    url: https://api.stripe.com/v1/balance
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Stripe rejected the API key (401). Check or regenerate the secret key in your Stripe Dashboard at https://dashboard.stripe.com/apikeys." }
    "403": { state: needs_setup, message: "Stripe API key lacks required permissions (403). Use a restricted key with at least 'Read' on Balance, or a secret key with full access." }
    "402": { state: failed, message: "Stripe account is past due (402). Resolve billing at https://dashboard.stripe.com/billing." }
    "default": { state: failed }
  timeout_ms: 5000

# /v1/balance is also safe to poll periodically — fast, no-cost,
# idempotent. Catches revoked keys between user sessions.
healthProbe:
  request:
    method: GET
    url: https://api.stripe.com/v1/balance
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

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
- **revenue-analyst** -- Analyzes MRR/ARR trends and subscription metrics
- **fraud-detector** -- Monitors charges for suspicious patterns
- **revops** -- Revenue operations and CAC/LTV analysis
- **sales-pipeline** -- Verifies deal payments and tracks revenue
- **churn-predictor** -- Analyzes subscription churn signals

## Setup

1. Get your Stripe API key from the Stripe Dashboard (use test keys for development)
2. Add `STRIPE_API_KEY` in the MCP connection setup
3. The server starts automatically when a bot that references it runs

## Team Usage

```yaml
mcpServers:
  - ref: "tools/stripe"
    reason: "Financial bots need Stripe access for payment tracking and reconciliation"
```
