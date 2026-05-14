---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: sales
  displayName: Sales
  version: "1.0.0"
  description: "Sales contacts, companies, deals, interactions, and market signals for sales and revenue operations teams"
  domain: sales
  category: domain
  tags:
    - sales
    - crm
    - deals
    - pipeline
    - revenue
    - market-intelligence
    - revops
  author: SchemaBounce
compatibility:
  teams: ["sales-team"]
  composableWith:
    - marketing
    - customer-service
    - finance
entityPrefix: "sal_"
entityCount: 5
graphEdgeTypes:
  - WORKS_AT
  - OPPORTUNITY_FOR
  - INTERACTED_WITH
vectorCollections:
  - sal_interactions
  - sal_market_signals
---

# Sales

A domain data kit for sales and revenue operations teams. Covers contacts, companies, deals, interaction history, and market intelligence signals.

## What's Included

- **Contacts** - sales contact records with lifecycle status, source attribution, and segmentation
- **Companies** - account records with firmographic data, revenue estimates, and relationship status
- **Deals** - pipeline opportunities with stage, value, probability, and close date tracking
- **Interactions** - call logs, email summaries, meeting notes, and demo records
- **Market Signals** - competitive intelligence, news triggers, and intent signals for prospecting

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Pipeline Coverage | 3-4x quota | Insufficient coverage is the leading indicator of a miss |
| Win Rate | >25% overall | Track by stage, segment, and rep to find coaching opportunities |
| Average Deal Size | Track vs plan | Growing ADS signals better ICP targeting |
| Sales Cycle Length | <60 days (SMB), <120 days (enterprise) | Longer cycles tie up rep capacity |
| CRM Hygiene Score | >90% | Missing fields cause inaccurate forecasts |

## Graph Relationships

- `WORKS_AT` links contacts to their companies for account-based selling
- `OPPORTUNITY_FOR` links deals to their primary contact and company
- `INTERACTED_WITH` links interactions to the contacts and deals they involve

## Composability

Pairs with `marketing` to track MQL-to-SQL conversion and campaign-sourced revenue. Pairs with `customer-service` to surface churn risk signals from support that inform renewal forecasts.
