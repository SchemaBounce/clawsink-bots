---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: financial-toolkit
  displayName: Financial Toolkit
  version: 1.0.0
  description: Financial calculations, forecasting, invoicing, and payment reconciliation
  category: Finance
  tags: [finance, accounting, tax, invoicing, forecasting, roi, depreciation]
  icon: finance
tools:
  - name: calculate_amortization
    description: Generate a loan amortization schedule with principal, interest, and balance per period
    category: calculation
  - name: forecast_revenue
    description: Project future revenue using historical data and growth assumptions
    category: forecasting
  - name: currency_convert
    description: Convert amounts between currencies using provided exchange rates
    category: conversion
  - name: calculate_tax
    description: Calculate tax liability based on income brackets and deductions
    category: calculation
  - name: generate_invoice
    description: Generate a structured invoice document from line items and billing details
    category: document
  - name: categorize_expense
    description: Classify an expense into standard accounting categories
    category: classification
  - name: financial_ratios
    description: Compute key financial ratios from balance sheet and income statement data
    category: analysis
  - name: cash_flow_projection
    description: Project cash inflows and outflows over a specified time horizon
    category: forecasting
  - name: break_even_analysis
    description: Calculate the break-even point given fixed costs, variable costs, and price per unit
    category: analysis
  - name: calculate_roi
    description: Calculate return on investment from cost and gain inputs
    category: calculation
  - name: depreciation_schedule
    description: Generate asset depreciation schedules using straight-line or declining balance methods
    category: calculation
  - name: reconcile_payments
    description: Match expected payments against received payments and flag discrepancies
    category: reconciliation
---

# Financial Toolkit

Financial calculations, forecasting, invoicing, and payment reconciliation. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent handling accounting, budgeting, or financial reporting tasks.

## Use Cases

- Generate amortization schedules for loan comparisons
- Forecast revenue based on historical trends
- Categorize expenses for monthly bookkeeping
- Calculate financial ratios from uploaded statements
- Reconcile expected vs received payments

## Tools

### calculate_amortization
Generate a full loan amortization schedule showing principal, interest, and remaining balance for each period.

### forecast_revenue
Project future revenue from historical data points using linear, exponential, or custom growth models.

### currency_convert
Convert monetary amounts between currencies using a provided exchange rate table.

### calculate_tax
Compute tax liability given income, brackets, filing status, and deductions.

### generate_invoice
Build a structured invoice from line items, tax rates, and billing/shipping details.

### categorize_expense
Classify a transaction into standard accounting categories (COGS, SGA, R&D, etc.) based on description and amount.

### financial_ratios
Compute key ratios (current, quick, debt-to-equity, gross margin, net margin, ROE, ROA) from financial statement inputs.

### cash_flow_projection
Project cash inflows and outflows over weekly, monthly, or quarterly horizons with configurable assumptions.

### break_even_analysis
Calculate break-even volume and revenue given fixed costs, variable cost per unit, and selling price.

### calculate_roi
Compute return on investment percentage and net gain from cost and revenue inputs.

### depreciation_schedule
Generate depreciation schedules using straight-line, declining balance, or sum-of-years-digits methods.

### reconcile_payments
Match expected payments against actual receipts by reference ID and flag missing, duplicate, or amount-mismatched entries.
