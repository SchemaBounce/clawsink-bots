---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: saas-growth
  displayName: "SaaS Growth"
  version: "1.0.0"
  description: "Customer retention, sales optimization, onboarding automation, and content planning for SaaS."
  tags: ["saas", "growth", "retention", "onboarding"]
  targetMarket: "saas"
bots:
  - churn-predictor
  - sales-pipeline
  - customer-onboarding
  - content-scheduler
skills:
  - trend-analysis
  - sentiment-analysis
  - notification-dispatch
requirements:
  minTier: "starter"
---

# SaaS Growth

A growth-focused team for SaaS companies. Predicts churn, optimizes sales pipelines, automates onboarding, and manages content scheduling.

## Included Bots

- **Churn Predictor** — CDC-triggered on user activity changes, flags at-risk accounts
- **Sales Pipeline** — Daily analysis of sales funnel and conversion rates
- **Customer Onboarding** — CDC-triggered on new customer creation
- **Content Scheduler** — Weekday content planning and scheduling

## Target Market

SaaS companies focused on retention, growth, and customer success.
