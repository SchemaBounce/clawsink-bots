---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: content-marketing
  displayName: Content Marketing
  version: "1.0.0"
  description: Content lifecycle kit covering campaigns, social posts, content assets, and lead generation tracking.
  category: horizontal
  tags:
    - marketing
    - content
    - campaigns
    - social-media
    - lead-generation
    - digital-marketing
  author: SchemaBounce
compatibility:
  teams: []
  composableWith:
    - saas-growth
    - ecommerce-operations
    - consulting-firm
entityPrefix: mkt_
entityCount: 4
graphEdgeTypes:
  - PART_OF
  - PROMOTES
  - GENERATED_BY
vectorCollections:
  - mkt_content
---

# Content Marketing

A horizontal data kit for managing the full content marketing lifecycle. Tracks content assets from ideation through publication, connects them to campaigns, manages social distribution, and measures lead generation effectiveness.

## What's Included

- **Content** -- Articles, whitepapers, videos, and other content assets with full metadata
- **Campaigns** -- Marketing campaigns with budgets, channels, and performance tracking
- **Social Posts** -- Social media posts across platforms linked to campaigns
- **Leads** -- Inbound leads generated through content marketing efforts

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Content Engagement Rate | >2% | Measures audience resonance |
| Email Open Rate | >25% | Email channel effectiveness |
| Click-Through Rate | >3% | Content-to-action conversion |
| Lead Generation Cost | Varies | Marketing spend efficiency |
| Social Reach Growth | >5% MoM | Audience expansion velocity |
| Campaign ROI | >300% | Overall marketing effectiveness |

## Graph Relationships

- **PART_OF** links social posts to the campaigns they belong to
- **PROMOTES** links content assets to the campaigns they support
- **GENERATED_BY** links leads back to the campaigns that produced them

## Composability

Pairs naturally with:
- **saas-growth** -- Align content strategy with product-led growth metrics
- **ecommerce-operations** -- Drive product awareness through content funnels
- **consulting-firm** -- Thought leadership content for professional services
