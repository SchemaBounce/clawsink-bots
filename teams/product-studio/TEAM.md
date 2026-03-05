---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: product-studio
  displayName: "Product Studio"
  version: "1.0.0"
  description: "Agile product team running sprints, experiments, and user research"
  category: product
  tags: ["product", "agile", "experimentation", "user-feedback"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/product-owner@1.0.0"
  - ref: "bots/sprint-planner@1.0.0"
  - ref: "bots/experiment-tracker@1.0.0"
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/customer-support@1.0.0"
northStar:
  industry: "Product Management"
  context: "Product team running agile sprints, experiments, and user research"
  requiredKeys:
    - product_vision
    - okrs
    - sprint_cadence
    - experiment_framework
    - user_segments
---
# Product Studio

Five bots forming a complete product management studio: backlog ownership, sprint execution, experimentation, user feedback collection, and cross-team coordination. The Executive Assistant acts as Studio Lead, ensuring alignment between user signals, experiment outcomes, and sprint delivery.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|----------|
| Product Owner | Backlog grooming, roadmap management | @daily |
| Sprint Planner | Sprint planning, RICE prioritization, velocity tracking | @weekly |
| Experiment Tracker | A/B test monitoring, statistical analysis | @daily |
| Executive Assistant | Studio Lead, cross-team coordination | @every 4h |
| Customer Support | User feedback channel, feature request triage | @every 2h |

## How They Work Together

Customer Support acts as the voice of the user, funneling feature requests and pain points to the Product Owner. The Product Owner maintains the backlog and feeds priorities to the Sprint Planner. The Experiment Tracker monitors A/B tests and shares significant results with both the Product Owner (for roadmap decisions) and the Executive Assistant (for strategic context). The Executive Assistant coordinates across all bots and produces studio-wide briefings.

**Communication flow:**
- Customer Support surfaces feature requests -> finding to Product Owner
- Customer Support detects behavior signals -> finding to Experiment Tracker
- Experiment Tracker reports significant results -> finding to Product Owner
- Experiment Tracker flags strategic outcomes -> finding to Executive Assistant
- Sprint Planner raises capacity concerns -> alert to Product Owner
- Sprint Planner flags sprint risk -> alert to Executive Assistant
- Product Owner pushes priority changes -> request to Sprint Planner
- Product Owner escalates roadmap decisions -> finding to Executive Assistant
- Executive Assistant coordinates cross-domain analysis -> request to all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `product_vision`, `okrs`, `sprint_cadence`, `experiment_framework`, `user_segments`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's briefings for a consolidated product studio view
