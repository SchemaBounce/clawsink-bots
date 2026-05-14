---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: marketing-team
  displayName: "Marketing"
  version: "1.0.0"
  description: "Full-stack marketing automation covering growth, brand, content, scheduling, SEO, social strategy, and developer relations"
  domain: marketing
  category: marketing
  tags: ["marketing", "growth", "content", "seo", "social", "brand", "devrel"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/marketing-growth@1.0.0"
  - ref: "bots/brand-guardian@1.0.0"
  - ref: "bots/blog-writer@1.0.0"
  - ref: "bots/content-scheduler@1.0.0"
  - ref: "bots/seo-expert@1.0.0"
  - ref: "bots/social-media-strategist@1.0.0"
  - ref: "bots/devrel@1.0.0"
dataKits:
  - ref: "data-kits/marketing@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Marketing"
  context: "Marketing team running demand generation, content creation, brand management, SEO, social media, and developer relations programs"
  requiredKeys:
    - brand_voice_guidelines
    - target_icp
    - content_calendar_cadence
    - seo_target_keywords
    - social_channels
    - developer_community_platforms
orgChart:
  lead: marketing-growth
  domains:
    - name: "Growth and Demand"
      description: "Campaign strategy, lead generation, pipeline contribution, and marketing analytics"
      head: marketing-growth
    - name: "Content"
      description: "Blog posts, whitepapers, case studies, videos, and editorial calendar management"
      head: blog-writer
      children:
        - name: "SEO"
          description: "Keyword strategy, on-page optimization, and organic traffic growth"
          head: seo-expert
        - name: "Content Distribution"
          description: "Content scheduling and multi-channel publishing"
          head: content-scheduler
    - name: "Brand"
      description: "Brand consistency, asset management, and tone-of-voice enforcement"
      head: brand-guardian
    - name: "Social and Community"
      description: "Social media strategy, community engagement, and developer relations"
      head: social-media-strategist
  roles:
    - bot: marketing-growth
      role: lead
      reportsTo: null
      domain: growth-and-demand
    - bot: blog-writer
      role: specialist
      reportsTo: marketing-growth
      domain: content
    - bot: brand-guardian
      role: specialist
      reportsTo: marketing-growth
      domain: brand
    - bot: content-scheduler
      role: support
      reportsTo: blog-writer
      domain: content
    - bot: seo-expert
      role: support
      reportsTo: blog-writer
      domain: content
    - bot: social-media-strategist
      role: specialist
      reportsTo: marketing-growth
      domain: social-and-community
    - bot: devrel
      role: specialist
      reportsTo: marketing-growth
      domain: social-and-community
  escalation:
    critical: marketing-growth
    unhandled: marketing-growth
    paths:
      - name: "Brand Violation"
        trigger: "brand_usage_violation"
        chain: [brand-guardian, marketing-growth]
      - name: "Content Deadline Miss"
        trigger: "content_deadline_at_risk"
        chain: [content-scheduler, blog-writer, marketing-growth]
      - name: "SEO Traffic Drop"
        trigger: "seo_traffic_drop_significant"
        chain: [seo-expert, marketing-growth]
      - name: "Social Crisis"
        trigger: "social_sentiment_negative_spike"
        chain: [social-media-strategist, marketing-growth]
---
# Marketing

Seven bots covering the full marketing function: growth strategy and analytics, brand governance, content creation, content scheduling, SEO optimization, social media strategy, and developer relations.

## Included Bots

| Bot | Role | Focus |
|-----|------|-------|
| Marketing Growth | Lead, growth and demand | Campaign strategy, MQL pipeline, marketing analytics |
| Brand Guardian | Specialist, brand | Brand consistency, asset compliance, tone-of-voice |
| Blog Writer | Specialist, content | Blog posts, whitepapers, case studies, and long-form content |
| Content Scheduler | Support, content | Editorial calendar, scheduling, and multi-channel publishing |
| SEO Expert | Support, content | Keyword strategy, on-page optimization, organic traffic |
| Social Media Strategist | Specialist, social | Social strategy, community engagement, paid social |
| DevRel | Specialist, social | Developer community, technical content, open source presence |

## How They Work Together

Marketing Growth drives overall strategy and coordinates demand generation across all channels. Blog Writer produces the primary content output, with SEO Expert optimizing each piece for organic discovery and Content Scheduler managing the publication calendar. Brand Guardian monitors all external content for brand consistency and flags violations. Social Media Strategist and DevRel collaborate on community-facing content - DevRel focuses on technical developer audiences while Social Media Strategist handles broader brand social.

**Communication flow:**
- Blog Writer completes a draft -> finding to SEO Expert for keyword review
- SEO Expert approves -> finding to Content Scheduler for calendar placement
- Content Scheduler publishes -> finding to Social Media Strategist for social distribution
- Brand Guardian detects a brand inconsistency -> alert to the owning bot and Marketing Growth
- Marketing Growth reviews weekly MQL metrics -> briefing to all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `brand_voice_guidelines`, `target_icp`, `content_calendar_cadence`, `seo_target_keywords`, `social_channels`, `developer_community_platforms`
3. Bots begin running on their default schedules automatically
4. Check Marketing Growth's weekly briefing for consolidated demand and content performance
