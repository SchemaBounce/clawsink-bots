---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: saas
  displayName: SaaS Metrics
  version: "1.0.0"
  description: "B2B SaaS platform metrics — accounts, subscriptions, feature usage, onboarding, and NPS tracking"
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
  author: SchemaBounce
compatibility:
  teams:
    - saas-growth
  composableWith:
    - customer-feedback
    - content-marketing
entityPrefix: "saas_"
entityCount: 5
graphEdgeTypes:
  - SUBSCRIBED_TO
  - USES_FEATURE
vectorCollections:
  - saas_nps_scores
---

# SaaS Metrics

A complete data kit for B2B SaaS platforms that need to track the full customer lifecycle: from account creation through subscription management, feature adoption monitoring, onboarding progress, and customer satisfaction via NPS.

## What's Included

- **Accounts** — customer organizations with plan tier, MRR, and lifecycle status
- **Subscriptions** — plan details with billing cycles, renewal dates, and expansion tracking
- **Feature Usage** — per-account feature adoption with usage counts and last-active timestamps
- **Onboarding Progress** — step-by-step onboarding completion tracking with time-to-value measurement
- **NPS Scores** — Net Promoter Score submissions with free-text feedback (vector-searchable)

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| MRR Growth Rate | >5% MoM | Core revenue health indicator |
| Churn Rate | <5% monthly | Retention is cheaper than acquisition |
| NPS | >40 | Predicts long-term retention and referrals |
| Trial-to-Paid Conversion | >15% | Measures product-market fit |
| Feature Adoption Rate | >60% | Sticky features reduce churn |
| Time to Value | <7 days | Fast activation drives conversion |

## Graph Relationships

- `SUBSCRIBED_TO` links accounts to their active subscriptions
- `USES_FEATURE` links accounts to the features they actively use

## Composability

Pairs well with **customer-feedback** (deeper sentiment analysis) and **content-marketing** (content-led growth tracking). The `saas_` prefix ensures clean coexistence with horizontal kits like CRM or Financial Ops.
