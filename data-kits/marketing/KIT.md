---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: marketing
  displayName: Marketing
  version: "1.0.0"
  description: "Marketing campaigns, content assets, social posts, leads, and brand assets for marketing and growth teams"
  domain: marketing
  category: domain
  tags:
    - marketing
    - campaigns
    - content
    - social-media
    - leads
    - brand
    - seo
    - growth
  author: SchemaBounce
compatibility:
  teams: ["marketing-team"]
  composableWith:
    - sales
    - customer-service
entityPrefix: "mkt_"
entityCount: 5
graphEdgeTypes:
  - GENERATED_BY
  - PUBLISHED_TO
  - ATTRIBUTED_TO
vectorCollections:
  - mkt_content
  - mkt_brand_assets
---

# Marketing

A domain data kit for marketing teams. Covers campaigns, content assets, social posts, marketing leads, and brand assets.

## What's Included

- **Campaigns** - marketing campaigns with budget tracking, channels, and performance metrics
- **Content** - articles, whitepapers, videos, and other assets with publication status and engagement data
- **Social Posts** - social media posts across platforms linked to campaigns with impression and engagement data
- **Leads** - inbound marketing leads with scoring, source attribution, and lifecycle status
- **Brand Assets** - logos, templates, brand guidelines, and creative assets with usage rights

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Marketing Qualified Leads (MQL) | Track vs plan | Measures top-of-funnel health |
| Cost per Lead | <$150 for SMB, <$500 for enterprise | Ensures sustainable acquisition economics |
| Content Engagement Rate | >3% per post | Below 1% signals content or audience mismatch |
| Campaign ROI | >200% | Minimum bar for continued channel investment |
| Lead Conversion Rate (MQL to SQL) | >25% | Validates lead quality before sales handoff |

## Graph Relationships

- `GENERATED_BY` links leads to the campaign or content that acquired them
- `PUBLISHED_TO` links content to the social posts that distributed it
- `ATTRIBUTED_TO` links campaigns to the leads they generated

## Composability

Pairs with `sales` to track MQL-to-SQL conversion and closed-revenue attribution. Pairs with `customer-service` to close the loop on churn-driven feedback influencing content strategy.
