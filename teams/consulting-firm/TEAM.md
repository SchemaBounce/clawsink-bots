---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: consulting-firm
  displayName: "Consulting Firm"
  version: "1.0.0"
  description: "AI team for consulting and advisory firms. Manages billable utilization, client engagements, knowledge capture, and team development."
  category: professional-services
  tags: ["consulting", "professional-services", "advisory", "analytics", "starter"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
requirements:
  minTier: "starter"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/meeting-summarizer@1.0.0"
  - ref: "bots/business-analyst@1.0.0"
  - ref: "bots/accountant@1.0.0"
  - ref: "bots/revenue-analyst@1.0.0"
  - ref: "bots/mentor-coach@1.0.0"
dataKits:
  - ref: "data-kits/consulting@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/crm-contacts@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/financial-ops@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/project-management@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "Consulting / Professional Services"
  context: "Consulting firms or advisory practices where billable hours, client deliverables, knowledge management, and team development are the core operations"
  requiredKeys:
    - practice_areas
    - billing_rates
    - utilization_target
    - client_portfolio
    - engagement_types
orgChart:
  lead: executive-assistant
  domains:
    - name: "Client Delivery"
      description: "Engagements, meetings, and client-facing artifacts"
      head: executive-assistant
      children:
        - name: "Meetings"
          description: "Call transcripts, action items, follow-up briefs"
          head: meeting-summarizer
    - name: "Analytics"
      description: "Business analysis and findings for client and internal ops"
      head: business-analyst
    - name: "Finance"
      description: "Project P&L, billing, revenue trends"
      head: accountant
      children:
        - name: "Revenue"
          description: "Fee-mix, realization, utilization"
          head: revenue-analyst
    - name: "Talent"
      description: "Team coaching, career paths, mentorship"
      head: mentor-coach
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: client-delivery
    - bot: meeting-summarizer
      role: support
      reportsTo: business-analyst
      domain: client-delivery
    - bot: business-analyst
      role: specialist
      reportsTo: executive-assistant
      domain: analytics
    - bot: accountant
      role: specialist
      reportsTo: executive-assistant
      domain: finance
    - bot: revenue-analyst
      role: support
      reportsTo: accountant
      domain: finance
    - bot: mentor-coach
      role: specialist
      reportsTo: executive-assistant
      domain: talent
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Utilization drop or margin erosion"
        trigger: "utilization_alert"
        chain: [revenue-analyst, accountant, executive-assistant]
      - name: "Consultant burnout risk"
        trigger: "burnout_escalation"
        chain: [mentor-coach, executive-assistant]
---
# Consulting Firm

An AI team designed for the economics of consulting — where the product is expertise, the currency is billable hours, and the biggest risks are underutilization, knowledge loss, and team burnout. Every consulting firm runs on the same fundamental tension: maximize billable hours while retaining the people who generate them. This team keeps both sides visible.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Assistant | Weekly utilization reviews, engagement health checks, resource allocation | @daily |
| Meeting Summarizer | Captures client calls, strategy sessions, and stakeholder meetings into structured action items | @cdc |
| Business Analyst | Cross-engagement analysis, trend identification, and reusable insight extraction | @weekly |
| Accountant | Invoicing, expense tracking, project budgets, and engagement-level P&L | @daily |
| Revenue Analyst | Billable utilization tracking, pipeline forecasting, and engagement profitability | @daily |
| Mentor Coach | Team workload monitoring, burnout risk detection, and professional development support | @weekly |

## How They Work Together

Consulting firms generate enormous volumes of unstructured knowledge — client calls, workshop outputs, strategy sessions, stakeholder interviews — and most of it evaporates after the meeting ends. Meeting Summarizer is the knowledge capture engine. Every meeting gets structured into decisions made, action items assigned, open questions, and key insights. This structured output feeds Business Analyst and becomes searchable institutional knowledge.

Revenue Analyst tracks the metric that determines whether a consulting firm is healthy: billable utilization. It monitors hours logged against your target utilization rate across the team, forecasts pipeline based on signed and probable engagements, and calculates profitability per engagement. When a consultant's utilization drops below target, it surfaces the gap before it becomes a financial problem. When an engagement is running over scope, it flags the margin erosion.

Business Analyst works at a different altitude — looking across engagements to identify patterns and reusable frameworks. If three different clients in the same industry are facing the same challenge, Business Analyst connects the dots and surfaces the insight as a potential methodology or offering. This is how consulting firms build intellectual property instead of just selling hours.

Accountant handles the transactional financial layer — invoicing based on logged hours and agreed rates, tracking expenses against engagement budgets, managing project-level P&L, and reconciling payments. It integrates with Revenue Analyst to ensure invoiced amounts match utilization data.

Mentor Coach watches the human side. Consulting is demanding work, and firms that ignore team health lose their best people. This bot monitors workload distribution, flags when someone has been consistently over-allocated, tracks professional development goals, and identifies coaching opportunities. When Revenue Analyst shows a consultant at 110% utilization for three consecutive weeks, Mentor Coach raises the burnout flag.

Executive Assistant orchestrates the weekly rhythm: utilization dashboards from Revenue Analyst, engagement status from Accountant, cross-engagement insights from Business Analyst, team health from Mentor Coach, and outstanding action items from Meeting Summarizer.

**Communication flow:**
- Meeting Summarizer captures client call -> structured action items to Executive Assistant, insights to Business Analyst
- Revenue Analyst detects utilization drop or engagement margin erosion -> alert to Executive Assistant
- Business Analyst identifies cross-engagement pattern -> insight to Executive Assistant
- Accountant flags overdue invoice or budget overrun -> alert to Executive Assistant and Revenue Analyst
- Mentor Coach detects sustained over-allocation or burnout risk -> alert to Executive Assistant
- Executive Assistant compiles weekly utilization and engagement review from all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `practice_areas`, `billing_rates`, `utilization_target`, `client_portfolio`, `engagement_types`
3. Bots begin running on their default schedules automatically
4. Check Executive Assistant's weekly briefings for a consolidated utilization and engagement view
