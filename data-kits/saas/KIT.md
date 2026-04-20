---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: saas
  displayName: SaaS Operations
  version: "2.0.0"
  description: "B2B SaaS operations data — accounts, subscriptions, feature usage, onboarding, NPS, incidents, deployments, content, sales pipeline, support, community, revenue metrics, feature requests, and market landscape"
  category: industry
  tags:
    - saas
    - subscriptions
    - mrr
    - churn
    - nps
    - onboarding
    - feature-adoption
    - b2b
    - sre
    - incidents
    - deployments
    - content
    - sales-pipeline
    - support
    - devrel
    - revenue-ops
  author: SchemaBounce
compatibility:
  teams:
    - saas-growth
    - saas-command-center
  composableWith:
    - customer-feedback
    - content-marketing
    - it-operations
    - crm-contacts
entityPrefix: "saas_"
entityCount: 14
graphEdgeTypes:
  - SUBSCRIBED_TO
  - USES_FEATURE
  - CAUSED_BY
  - DEPLOYED_TO_ACCOUNT
  - SUBMITTED_BY
  - REQUESTED_BY
  - RELATES_TO_DEAL
  - RESOLVED_FOR
  - TRACKS_PRODUCT
vectorCollections:
  - saas_nps_scores
  - saas_support_tickets
  - saas_content
  - saas_feature_requests
  - saas_incidents
useCases:
  - "Track every account's subscription tier, plan, and renewal date"
  - "Measure feature usage per account and surface adoption laggards"
  - "Tie support tickets, NPS responses, and feature requests to the account"
  - "Track incidents by affected customer and deployments by service"
---

# SaaS Operations

A comprehensive data kit for B2B SaaS platforms covering the full operational lifecycle: from account creation through subscription management, feature adoption, onboarding, customer satisfaction, incident management, deployment tracking, content operations, sales pipeline, support ticketing, community engagement, revenue analytics, feature request tracking, and market landscape monitoring.

## What's Included

- **Accounts** — customer organizations with plan tier, MRR, and lifecycle status
- **Subscriptions** — plan details with billing cycles, renewal dates, and expansion tracking
- **Feature Usage** — per-account feature adoption with usage counts and last-active timestamps
- **Onboarding Progress** — step-by-step onboarding completion tracking with time-to-value measurement
- **NPS Scores** — Net Promoter Score submissions with free-text feedback (vector-searchable)
- **Incidents** — production incident tracking with severity, impact, root cause analysis, and MTTR measurement
- **Deployments** — deployment records with rollback tracking, deploy types, and service versioning
- **Content** — content asset management with engagement metrics, audience targeting, and publishing workflow
- **Community Metrics** — cross-platform community engagement tracking (GitHub, Discord, forums, social)
- **Deals** — sales pipeline with stage tracking, deal values, win/loss analysis, and source attribution
- **Revenue Metrics** — periodic MRR/ARR snapshots with net revenue retention and expansion tracking
- **Support Tickets** — support ticket lifecycle with SLA tracking, categorization, and satisfaction scores
- **Market Landscape** — industry product tracking with positioning, pricing models, and feature comparisons
- **Feature Requests** — customer feature request tracking with voting, prioritization, and delivery status

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| MRR Growth Rate | >5% MoM | Core revenue health indicator |
| Churn Rate | <5% monthly | Retention is cheaper than acquisition |
| NPS | >40 | Predicts long-term retention and referrals |
| Trial-to-Paid Conversion | >15% | Measures product-market fit |
| Feature Adoption Rate | >60% | Sticky features reduce churn |
| Time to Value | <7 days | Fast activation drives conversion |
| MTTR | <1 hour | Service reliability and customer trust |
| Uptime | 99.95% | Maximum 21.9 minutes downtime per month |
| Deploy Frequency | Daily | Smaller blast radius per deployment |
| Net Revenue Retention | >110% | Expansion revenue exceeds churn |
| First Response Time | <2 hours | Support responsiveness drives satisfaction |
| CSAT | >4.2/5 | Direct measure of support quality |
| Win Rate | >25% | Sales effectiveness indicator |
| Content Engagement | >3 min avg read | Content quality and relevance signal |

## Graph Relationships

- `SUBSCRIBED_TO` links accounts to their active subscriptions
- `USES_FEATURE` links accounts to the features they actively use
- `CAUSED_BY` links incidents to the deployments that triggered them
- `DEPLOYED_TO_ACCOUNT` links deployments to the accounts they were rolled out to
- `SUBMITTED_BY` links support tickets to the accounts that submitted them
- `REQUESTED_BY` links feature requests to the accounts that requested them
- `RELATES_TO_DEAL` links support tickets to deals they may impact
- `RESOLVED_FOR` links incidents to the accounts affected by them
- `TRACKS_PRODUCT` links market landscape entries to related products in the landscape

## Composability

Pairs well with **customer-feedback** (deeper sentiment analysis), **content-marketing** (content-led growth tracking), **it-operations** (infrastructure and service monitoring), and **crm-contacts** (contact-level deal and support context). The `saas_` prefix ensures clean coexistence with horizontal kits like CRM or Financial Ops.
