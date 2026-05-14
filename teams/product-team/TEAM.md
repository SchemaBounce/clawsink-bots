---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: product-team
  displayName: "Product"
  version: "1.0.0"
  description: "Agile product team running sprints, experiments, and user research to ship a focused roadmap"
  domain: product
  category: product
  tags: ["product", "agile", "experimentation", "user-research", "sprints", "roadmap"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/product-owner@1.0.0"
  - ref: "bots/sprint-planner@1.0.0"
  - ref: "bots/experiment-tracker@1.0.0"
  - ref: "bots/ux-researcher@1.0.0"
dataKits:
  - ref: "data-kits/product@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Product Management"
  context: "Product team running agile sprints, experiments, and user research to ship a focused roadmap"
  requiredKeys:
    - product_vision
    - okrs
    - sprint_cadence
    - experiment_framework
    - user_segments
    - target_users
orgChart:
  lead: product-owner
  domains:
    - name: "Product"
      description: "Roadmap, backlog, release strategy, and prioritization"
      head: product-owner
      children:
        - name: "Engineering Delivery"
          description: "Sprint planning, velocity tracking, and technical sequencing"
          head: sprint-planner
        - name: "Research"
          description: "Experiments, user interviews, and insight synthesis"
          head: experiment-tracker
          children:
            - name: "User Insights"
              description: "Qualitative research, usability testing, and persona development"
              head: ux-researcher
  roles:
    - bot: product-owner
      role: lead
      reportsTo: null
      domain: product
    - bot: sprint-planner
      role: specialist
      reportsTo: product-owner
      domain: engineering
    - bot: experiment-tracker
      role: specialist
      reportsTo: product-owner
      domain: research
    - bot: ux-researcher
      role: support
      reportsTo: experiment-tracker
      domain: research
  escalation:
    critical: product-owner
    unhandled: product-owner
    paths:
      - name: "Sprint Risk"
        trigger: "sprint_risk"
        chain: [sprint-planner, product-owner]
      - name: "Experiment Significance"
        trigger: "experiment_significant"
        chain: [experiment-tracker, product-owner]
      - name: "User Research Finding"
        trigger: "research_critical"
        chain: [ux-researcher, experiment-tracker, product-owner]
---
# Product

Four bots forming a complete product management team: backlog ownership, sprint execution, experimentation analysis, and user research. The Product Owner leads the team and owns the roadmap, coordinating inputs from sprints, experiments, and research.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Product Owner | Backlog grooming, roadmap management, prioritization | @daily |
| Sprint Planner | Sprint planning, RICE prioritization, velocity tracking | @weekly |
| Experiment Tracker | A/B test monitoring, statistical analysis, result synthesis | @daily |
| UX Researcher | User interviews, usability findings, persona maintenance | @weekly |

## How They Work Together

The Product Owner maintains the backlog and drives roadmap decisions. Sprint Planner tracks velocity, manages sprint commitments, and flags capacity risks. Experiment Tracker monitors running A/B tests and delivers significant findings to the Product Owner for roadmap input. UX Researcher synthesizes qualitative signals from interviews and usability sessions into structured insights that feed both the Experiment Tracker and the Product Owner directly.

**Communication flow:**
- Sprint Planner detects capacity risk -> alert to Product Owner
- Sprint Planner flags sprint risk -> alert to Product Owner
- Experiment Tracker reports significant test result -> finding to Product Owner
- UX Researcher surfaces critical user insight -> finding to Experiment Tracker
- UX Researcher identifies usability blocker -> alert to Product Owner
- Product Owner pushes priority changes -> request to Sprint Planner
- Product Owner requests experiment design -> request to Experiment Tracker

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `product_vision`, `okrs`, `sprint_cadence`, `experiment_framework`, `user_segments`, `target_users`
3. Bots begin running on their default schedules automatically
4. Check the Product Owner's briefings for a consolidated product team view
