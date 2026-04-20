---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: customer-feedback
  displayName: Customer Feedback
  version: "1.0.0"
  description: Customer feedback kit covering support tickets, reviews, NPS responses, and feature requests for B2B SaaS.
  category: horizontal
  tags:
    - customer-feedback
    - support
    - nps
    - reviews
    - feature-requests
    - customer-success
    - tickets
  author: SchemaBounce
compatibility:
  teams: []
  composableWith:
    - restaurant-group
    - ecommerce-operations
    - saas-growth
    - fitness-studio
entityPrefix: fb_
entityCount: 4
graphEdgeTypes:
  - RAISED_BY
  - REVIEW_OF
vectorCollections:
  - fb_tickets
  - fb_reviews
  - fb_feature_requests
useCases:
  - "Capture every support ticket with channel, severity, and resolution time"
  - "Collect and categorize reviews from web, app stores, and in-product prompts"
  - "Run NPS surveys and segment detractors, passives, and promoters"
  - "Log feature requests with vote counts to feed the roadmap"
---

# Customer Feedback

A horizontal data kit for managing the full customer feedback lifecycle. Consolidates support tickets, product reviews, NPS survey responses, and feature requests into a unified feedback system. Migrated and enhanced from the shared support domain schema with added graph relationships, vector search, and domain memory.

## What's Included

- **Tickets** -- Customer support tickets with severity, assignment, SLA tracking, and resolution data (migrated from `shared/domain-schemas/support.json`)
- **Reviews** -- Product and service reviews from multiple platforms with rating and sentiment analysis
- **NPS Responses** -- Net Promoter Score survey responses with scoring and follow-up tracking
- **Feature Requests** -- Customer feature requests with voting, prioritization, and delivery tracking

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| First Response Time | <1 hour | Customer experience expectation |
| Resolution Time | <24 hours | Support efficiency |
| CSAT | >90% | Overall satisfaction health |
| NPS | >40 | Customer loyalty indicator |
| Feature Request Conversion Rate | >10% | Product-market feedback loop |
| Ticket Deflection Rate | >30% | Self-service effectiveness |

## Graph Relationships

- **RAISED_BY** links feature requests to the support tickets that originally surfaced them
- **REVIEW_OF** links reviews to related support tickets for correlation analysis

## Migration Note

Entity schemas for `fb_tickets` are enhanced from the existing `shared/domain-schemas/support.json` ticket definition, with the `fb_` prefix added and additional fields for SLA tracking, channel source, and satisfaction scoring.

## Composability

Pairs naturally with:
- **restaurant-group** -- Guest feedback and review management for hospitality
- **ecommerce-operations** -- Product review aggregation and return reason analysis
- **saas-growth** -- Product feedback loop driving feature prioritization
- **fitness-studio** -- Member feedback and experience tracking
