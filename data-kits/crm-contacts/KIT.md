---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: crm-contacts
  displayName: CRM Contacts
  version: "1.0.0"
  description: "B2B sales pipeline data — contacts, companies, deals, and interaction history with semantic search"
  category: horizontal
  tags:
    - crm
    - contacts
    - sales
    - pipeline
    - deals
    - b2b
    - lead-management
    - interactions
  author: SchemaBounce
compatibility:
  teams: []
  composableWith:
    - restaurant
    - real-estate
    - ecommerce
    - legal
    - consulting
    - fitness
    - construction
entityPrefix: "crm_"
entityCount: 4
graphEdgeTypes:
  - WORKS_AT
  - RELATED_TO
vectorCollections:
  - crm_interactions
useCases:
  - "Track every person and company you talk to with lifecycle status"
  - "Run a B2B sales pipeline: log deals, update stages, measure win rate"
  - "Search past interactions by meaning with pgvector-backed semantic search"
  - "Segment contacts by tags, source, or status for follow-up campaigns"
---

# CRM Contacts

A horizontal CRM data kit that provides the foundational contact, company, deal, and interaction entities needed by virtually any business. Designed for B2B sales pipelines but flexible enough to adapt to any relationship-driven domain.

## What's Included

- **Contacts** — people your organization interacts with, including lifecycle status, lead source, and segmentation tags
- **Companies** — organizations and accounts with industry, size, revenue, and relationship status
- **Deals** — sales opportunities with pipeline stages, probability weighting, and value tracking
- **Interactions** — meeting notes, call logs, and email summaries with semantic search for finding past conversations

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Lead Conversion Rate | >20% | Measures sales effectiveness |
| Sales Cycle Length | <45 days | Shorter cycles = faster revenue |
| Pipeline Velocity | >$50K/week | Revenue flow rate through pipeline |
| Win Rate | >30% | Proposal-to-close effectiveness |
| Avg Deal Size | Track trend | Revenue optimization indicator |
| Customer Acquisition Cost | Track trend | Efficiency of sales investment |

## Graph Relationships

- `WORKS_AT` links contacts to the companies they belong to
- `RELATED_TO` links deals to the primary contacts involved

## Composability

This is a horizontal kit designed to compose with virtually any industry kit. The `crm_` prefix prevents collisions with industry-specific entity names. A restaurant team gets `rest_` entities for operations and `crm_` entities for supplier and vendor relationships.

## Migration Note

This kit enhances the legacy `shared/domain-schemas/crm.json` schema pack with graph relationships, vector search over interaction notes, and memory-bootstrapped sales KPIs.
