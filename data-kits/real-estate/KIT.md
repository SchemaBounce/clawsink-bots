---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: real-estate
  displayName: Real Estate Agency
  version: "1.0.0"
  description: Residential real estate data kit covering listings, clients, showings, offers, and transactions.
  category: industry
  tags:
    - real-estate
    - property
    - residential
    - listings
    - brokerage
    - mls
  author: SchemaBounce
compatibility:
  teams:
    - real-estate-agency
  composableWith:
    - crm-contacts
    - financial-ops
entityPrefix: re_
entityCount: 5
graphEdgeTypes:
  - VIEWED
  - MADE_OFFER
  - OWNED_BY
vectorCollections:
  - re_listings
useCases:
  - "Track every active listing with price history, media, and status"
  - "Match clients to listings by criteria and log each showing"
  - "Follow an offer from submission through acceptance, with counter history"
  - "Manage a transaction from contract to close with deadlines and tasks"
---

# Real Estate Agency

A comprehensive data kit for residential real estate brokerages and agencies. Tracks the full property lifecycle from listing through showing, offer, and closing. Designed for independent agents, small brokerages, and property management firms.

## What's Included

- **Listings** — Active and historical property listings with pricing, features, and MLS data
- **Clients** — Buyer and seller profiles with preferences and qualification status
- **Showings** — Property viewing appointments with feedback tracking
- **Offers** — Purchase offers with terms, contingencies, and negotiation status
- **Transactions** — Closed deals with commission, timeline, and settlement details

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Days on Market | <30 days | Pricing accuracy and market demand |
| List-to-Sale Ratio | 97-100% | Listing price accuracy |
| Showing-to-Offer Conversion | 10-15% | Lead quality and agent effectiveness |
| Average Commission | 2.5-3% | Revenue per transaction |
| Market Absorption Rate | Varies | Inventory health indicator |

## Graph Relationships

- **VIEWED** links clients to listings they have toured with showing feedback
- **MADE_OFFER** links clients to listings with offer terms and status
- **OWNED_BY** links listings to their seller/owner clients

## Composability

Pairs naturally with:
- **crm-contacts** — Enrich client records with full CRM contact history
- **financial-ops** — Track commission income and transaction accounting
