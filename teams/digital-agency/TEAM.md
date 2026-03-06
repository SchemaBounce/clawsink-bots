---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: digital-agency
  displayName: "Digital Agency"
  version: "1.0.0"
  description: "Full-service agency team managing brand, content, UX, and growth"
  category: agency
  tags: ["agency", "design", "marketing", "content", "brand"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/ux-researcher@1.0.0"
  - ref: "bots/brand-guardian@1.0.0"
  - ref: "bots/blog-writer@1.0.0"
  - ref: "bots/social-media-strategist@1.0.0"
  - ref: "bots/growth-hacker@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Social-media-strategist and growth-hacker need OAuth for social platforms and analytics"
    config:
      scopes: ["social", "analytics", "ads"]
  - ref: "gog@latest"
    slot: "calendar"
    reason: "Content scheduling via Google Calendar for blog-writer and social-media-strategist"
    config:
      calendar_access: "read_write"
      drive_access: "read"
northStar:
  industry: "Digital Agency / Creative Services"
  context: "Agency team managing brand, content, UX, and growth across multiple client accounts"
  requiredKeys:
    - brand_guidelines
    - target_audience
    - content_pillars
    - campaign_goals
    - client_accounts
orgChart:
  lead: executive-assistant
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: creative
    - bot: ux-researcher
      role: specialist
      reportsTo: executive-assistant
      domain: research
    - bot: brand-guardian
      role: specialist
      reportsTo: executive-assistant
      domain: creative
    - bot: blog-writer
      role: specialist
      reportsTo: brand-guardian
      domain: content
    - bot: social-media-strategist
      role: specialist
      reportsTo: brand-guardian
      domain: content
    - bot: growth-hacker
      role: specialist
      reportsTo: executive-assistant
      domain: growth
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Brand Drift"
        trigger: "brand_inconsistency"
        chain: [brand-guardian, executive-assistant]
      - name: "Content Performance Drop"
        trigger: "content_underperformance"
        chain: [blog-writer, brand-guardian, executive-assistant]
      - name: "Viral Opportunity"
        trigger: "viral_opportunity"
        chain: [social-media-strategist, growth-hacker, executive-assistant]
      - name: "Usability Issue"
        trigger: "usability_finding"
        chain: [ux-researcher, executive-assistant]
---
# Digital Agency

Six bots powering a full-service digital agency: creative direction, user research, brand enforcement, content production, social media strategy, and growth experimentation. The Executive Assistant acts as Creative Director, coordinating all outputs into a unified client experience.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|----------|
| Executive Assistant | Creative Director, project coordination | @every 4h |
| UX Researcher | User feedback synthesis, usability findings | @weekly |
| Brand Guardian | Brand consistency monitoring, style enforcement | @weekly |
| Blog Writer | Content creation, SEO optimization | @daily |
| Social Media Strategist | Cross-platform strategy, content calendar | @daily |
| Growth Hacker | Rapid experimentation, conversion optimization | @daily |

## How They Work Together

The Executive Assistant serves as Creative Director, receiving escalations from all specialist bots and producing consolidated project briefings. The Brand Guardian enforces visual and tonal consistency across content from the Blog Writer and Social Media Strategist. The UX Researcher feeds user insights to the Creative Director for strategic decisions. The Growth Hacker runs rapid experiments and shares channel optimization findings with the Social Media Strategist.

**Communication flow:**
- UX Researcher surfaces usability findings -> finding to Executive Assistant
- Brand Guardian detects brand drift -> alert to Executive Assistant
- Brand Guardian flags content compliance -> finding to Blog Writer
- Brand Guardian flags social brand violation -> finding to Social Media Strategist
- Blog Writer reports content performance -> finding to Executive Assistant
- Social Media Strategist escalates engagement alerts -> alert to Executive Assistant
- Social Media Strategist identifies viral opportunity -> finding to Growth Hacker
- Growth Hacker shares experiment results -> finding to Executive Assistant
- Growth Hacker shares channel optimization -> finding to Social Media Strategist
- Executive Assistant coordinates cross-domain analysis -> request to all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `brand_guidelines`, `target_audience`, `content_pillars`, `campaign_goals`, `client_accounts`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's briefings for a consolidated creative direction view
