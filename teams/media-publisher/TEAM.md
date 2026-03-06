---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: media-publisher
  displayName: "Media Publisher"
  version: "1.0.0"
  description: "Full editorial operations for digital publishers: content production, distribution, audience engagement, and revenue tracking."
  category: media
  tags: ["media", "publishing", "content", "editorial", "social", "starter"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/blog-writer@1.0.0"
  - ref: "bots/content-scheduler@1.0.0"
  - ref: "bots/social-media-strategist@1.0.0"
  - ref: "bots/social-media-monitor@1.0.0"
  - ref: "bots/brand-guardian@1.0.0"
  - ref: "bots/revenue-analyst@1.0.0"
requirements:
  minTier: "starter"
northStar:
  industry: "Media / Digital Publishing"
  context: "Digital publishers, online magazines, or content-first businesses where editorial output, audience engagement, and ad/subscription revenue are the core operations"
  requiredKeys:
    - editorial_voice
    - content_verticals
    - publishing_cadence
    - audience_segments
    - revenue_model
    - distribution_channels
orgChart:
  lead: executive-assistant
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: editorial
    - bot: blog-writer
      role: specialist
      reportsTo: executive-assistant
      domain: editorial
    - bot: content-scheduler
      role: specialist
      reportsTo: executive-assistant
      domain: editorial
    - bot: social-media-strategist
      role: specialist
      reportsTo: executive-assistant
      domain: distribution
    - bot: social-media-monitor
      role: support
      reportsTo: social-media-strategist
      domain: audience
    - bot: brand-guardian
      role: support
      reportsTo: executive-assistant
      domain: editorial
    - bot: revenue-analyst
      role: specialist
      reportsTo: executive-assistant
      domain: revenue
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Content quality gate"
        trigger: "content_review_failed"
        chain: [brand-guardian, executive-assistant]
      - name: "Audience crisis"
        trigger: "negative_sentiment_spike"
        chain: [social-media-monitor, social-media-strategist, executive-assistant]
      - name: "Revenue alert"
        trigger: "revenue_decline"
        chain: [revenue-analyst, executive-assistant]
---
# Media Publisher

A complete editorial operations team for digital publishers. Seven bots cover the full content lifecycle from planning through publication, distribution, audience engagement, and revenue analysis. Built for teams where content is the product and every piece needs to earn its keep.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Assistant | Daily editorial standup and cross-bot coordination | @every 4h |
| Blog Writer | Drafts articles from the editorial calendar and trending topics | @daily |
| Content Scheduler | Manages the editorial calendar across verticals and formats | @daily |
| Social Media Strategist | Plans distribution hooks and channel strategy per piece | @daily |
| Social Media Monitor | Tracks audience reaction, engagement, and trending conversations | @every 2h |
| Brand Guardian | Reviews all content pre-publish for voice and editorial standards | @on-trigger |
| Revenue Analyst | Monitors ad revenue, subscription metrics, and content ROI by vertical | @daily |

## How They Work Together

Publishing is a pipeline, not a collection of tasks. Every piece of content flows through a defined sequence: plan it, write it, review it, distribute it, measure it. These bots mirror how a real editorial team operates, with each one owning a stage.

Content Scheduler manages the editorial calendar -- what gets published when, across which verticals. It balances evergreen content against timely pieces and ensures no vertical goes dark. Blog Writer picks up assignments from the calendar and drafts articles, incorporating trending topics that Social Media Monitor has flagged as relevant to the audience. Before anything goes live, Brand Guardian reviews the draft for voice consistency, editorial standards, and brand alignment.

Once published, Social Media Strategist takes over distribution -- determining which pieces go to which channels, with what hooks and timing. Social Media Monitor then tracks how the audience responds: engagement rates, shares, comment sentiment, and emerging conversations worth covering. Revenue Analyst closes the loop by tying content performance back to money -- which verticals drive ad impressions, which pieces convert subscribers, and where the editorial investment is paying off.

Executive Assistant runs the daily editorial standup, pulling together what is publishing today, what performed well yesterday, what is behind schedule, and what needs the team's attention.

**Communication flow:**
- Content Scheduler publishes editorial calendar -> assignments to Blog Writer
- Blog Writer completes draft -> triggers Brand Guardian review
- Brand Guardian approves content -> signals Social Media Strategist for distribution planning
- Social Media Monitor detects trending topic -> finding to Content Scheduler and Blog Writer
- Social Media Monitor captures engagement data -> metrics to Revenue Analyst
- Revenue Analyst identifies underperforming vertical -> alert to Executive Assistant
- Executive Assistant synthesizes all signals into the daily editorial standup

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `editorial_voice`, `content_verticals`, `publishing_cadence`, `audience_segments`, `revenue_model`, `distribution_channels`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's editorial standup for a consolidated view of what is publishing, performing, and needs attention
