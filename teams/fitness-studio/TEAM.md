---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: fitness-studio
  displayName: "Fitness Studio"
  version: "1.0.0"
  description: "Member retention and studio operations for gyms, fitness studios, and wellness centers."
  category: fitness
  tags: ["fitness", "gym", "wellness", "membership", "retention", "starter"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/customer-support@1.0.0"
  - ref: "bots/customer-onboarding@1.0.0"
  - ref: "bots/churn-predictor@1.0.0"
  - ref: "bots/marketing-growth@1.0.0"
  - ref: "bots/accountant@1.0.0"
  - ref: "bots/content-scheduler@1.0.0"
dataKits:
  - ref: "data-kits/fitness@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/crm-contacts@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/customer-feedback@1.0.0"
    required: false
    installSampleData: false
requirements:
  minTier: "starter"
northStar:
  industry: "Fitness / Wellness Studio"
  context: "Gym owners, fitness studios, or wellness centers where member retention, class scheduling, and local marketing drive the business"
  requiredKeys:
    - studio_type
    - membership_tiers
    - class_schedule
    - retention_target
    - local_area
    - seasonal_promotions
orgChart:
  lead: executive-assistant
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: member-experience
    - bot: customer-support
      role: specialist
      reportsTo: executive-assistant
      domain: member-experience
    - bot: customer-onboarding
      role: support
      reportsTo: customer-support
      domain: member-experience
    - bot: churn-predictor
      role: support
      reportsTo: customer-support
      domain: member-experience
    - bot: marketing-growth
      role: specialist
      reportsTo: executive-assistant
      domain: marketing
    - bot: accountant
      role: specialist
      reportsTo: executive-assistant
      domain: finance
    - bot: content-scheduler
      role: specialist
      reportsTo: marketing-growth
      domain: marketing
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Member churn intervention"
        trigger: "high_churn_risk"
        chain: [churn-predictor, customer-support, executive-assistant]
      - name: "Billing dispute"
        trigger: "billing_escalation"
        chain: [customer-support, accountant, executive-assistant]
      - name: "Retention campaign"
        trigger: "attendance_decline"
        chain: [churn-predictor, marketing-growth, executive-assistant]
---
# Fitness Studio

A member-focused operations team for gyms, fitness studios, and wellness centers. Seven bots handle the full member lifecycle -- from first signup through long-term retention -- plus the marketing, finances, and social presence that keep a studio thriving. Built for owners who know that a canceled membership is revenue that never comes back.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Assistant | Weekly studio health briefing and coordination | @weekly |
| Customer Support | Class booking issues, billing questions, facility complaints | @every 2h |
| Customer Onboarding | New member welcome sequence, intro sessions, check-in milestones | @on-trigger |
| Churn Predictor | Monitors attendance patterns, flags declining visit frequency | @daily |
| Marketing & Growth | Local promotions, referral campaigns, seasonal offers | @daily |
| Accountant | Membership revenue, class profitability, equipment costs | @daily |
| Content Scheduler | Social posts: class highlights, member spotlights, trainer tips | @daily |

## How They Work Together

In a fitness business, the member lifecycle is everything. Getting someone in the door is expensive. Keeping them is where the money is. These bots mirror how a well-run studio actually operates: onboard new members properly, watch for warning signs, keep the community engaged, and know the numbers.

Customer Onboarding activates the moment a new member signs up. It sends the welcome sequence, books an intro session with a trainer, and sets 30/60/90 day check-in milestones. Those first 90 days determine whether someone becomes a long-term member or a January dropout. Customer Support handles the daily friction -- class booking conflicts, billing confusion, locker complaints -- the small things that quietly push people toward canceling if they go unresolved.

Churn Predictor is the early warning system. It watches attendance patterns and flags members whose visit frequency is declining before they cancel. A member who went from 4x/week to 1x/week is not fine -- they are leaving. That signal goes to Marketing & Growth, which can trigger a re-engagement campaign, a free personal training session, or a class recommendation. Marketing also runs the broader growth engine: local promotions, referral incentives, and the seasonal campaigns that every studio depends on (New Year resolution wave, summer body push, back-to-school).

Content Scheduler keeps the studio visible on social media with class highlights, member transformations (with permission), and trainer tips. Accountant tracks the numbers that matter: membership revenue by tier, per-class profitability, and equipment ROI. Executive Assistant pulls it all together into the weekly studio health briefing: new members this week, members at risk, class fill rates, and where the money is going.

**Communication flow:**
- Customer Onboarding activates on new signup -> sets milestones, books intro session
- Churn Predictor detects declining attendance -> alert to Marketing & Growth for re-engagement
- Churn Predictor flags high-risk member -> alert to Executive Assistant
- Customer Support sees repeated complaint pattern -> finding to Executive Assistant
- Marketing & Growth launches seasonal campaign -> content brief to Content Scheduler
- Accountant detects class with poor profitability -> finding to Executive Assistant
- Executive Assistant compiles weekly studio health briefing from all bot signals

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `studio_type`, `membership_tiers`, `class_schedule`, `retention_target`, `local_area`, `seasonal_promotions`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's weekly briefing for new members, at-risk members, class fill rates, and revenue
