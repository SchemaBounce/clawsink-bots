---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: marketing-toolkit
  displayName: Marketing Toolkit
  version: 1.0.0
  description: UTM tracking, funnel analysis, attribution, and customer lifecycle metrics
  category: Marketing
  tags: [utm, funnel, cohort, attribution, ltv, churn, campaign, leads]
  icon: megaphone
tools:
  - name: generate_utm
    description: Generate UTM-tagged URLs with source, medium, campaign, and content parameters
    category: tracking
  - name: funnel_analysis
    description: Calculate conversion rates and drop-off between funnel stages
    category: analysis
  - name: cohort_analysis
    description: Group users into cohorts by signup date and track retention over time
    category: analysis
  - name: attribution_model
    description: Allocate conversion credit across touchpoints using first, last, or linear models
    category: attribution
  - name: ltv_calculator
    description: Estimate customer lifetime value from revenue, retention, and discount rate
    category: metrics
  - name: churn_predictor
    description: Calculate churn probability from engagement signals and historical patterns
    category: metrics
  - name: campaign_roi
    description: Calculate campaign ROI from spend, impressions, clicks, and conversions
    category: metrics
  - name: lead_score
    description: Score leads based on demographic and behavioral attributes
    category: scoring
---

# Marketing Toolkit

UTM tracking, funnel analysis, attribution, and customer lifecycle metrics. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent managing marketing campaigns, growth metrics, or customer analytics.

## Use Cases

- Generate UTM-tagged URLs for campaign tracking
- Analyze conversion funnels to identify drop-off points
- Build cohort retention tables from user activity data
- Attribute conversions across multiple marketing touchpoints
- Score inbound leads for sales prioritization

## Tools

### generate_utm
Build URLs with UTM parameters (source, medium, campaign, term, content) for consistent campaign tracking.

### funnel_analysis
Calculate stage-by-stage conversion rates and absolute drop-off from an ordered list of funnel events.

### cohort_analysis
Group users by signup week or month and compute retention rates over subsequent periods.

### attribution_model
Distribute conversion credit across touchpoints using first-touch, last-touch, linear, or time-decay models.

### ltv_calculator
Estimate customer lifetime value from average revenue per period, retention rate, and discount rate.

### churn_predictor
Compute churn risk scores from engagement metrics (login frequency, feature usage, support tickets) and historical churn patterns.

### campaign_roi
Calculate return on investment for marketing campaigns from spend, revenue generated, impressions, clicks, and conversions.

### lead_score
Assign a numeric score to leads based on weighted attributes (company size, role, engagement, source channel).
