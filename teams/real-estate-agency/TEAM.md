---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: real-estate-agency
  displayName: "Real Estate Agency"
  version: "1.0.0"
  description: "AI team for real estate agencies — manages listing pipelines, buyer/seller relationships, contract deadlines, and property marketing"
  category: real-estate
  tags: ["real-estate", "property", "sales", "listings", "starter"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
requirements:
  minTier: "starter"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/sales-pipeline@1.0.0"
  - ref: "bots/customer-onboarding@1.0.0"
  - ref: "bots/content-scheduler@1.0.0"
  - ref: "bots/accountant@1.0.0"
  - ref: "bots/legal-compliance@1.0.0"
dataKits:
  - ref: "data-kits/real-estate@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/crm-contacts@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/financial-ops@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "Real Estate / Property"
  context: "Real estate agencies managing listings, buyer/seller pipelines, closings, and marketing of properties"
  requiredKeys:
    - market_area
    - listing_platforms
    - commission_structure
    - compliance_requirements
    - property_types
orgChart:
  lead: executive-assistant
  domains:
    - name: "Operations"
      description: "Office coordination, calendar, daily briefs"
      head: executive-assistant
    - name: "Sales"
      description: "Buyer and seller pipelines, showings, offers"
      head: sales-pipeline
      children:
        - name: "Onboarding"
          description: "New-client intake and listing kickoff"
          head: customer-onboarding
    - name: "Marketing"
      description: "Listing campaigns, social, open-house promos"
      head: content-scheduler
    - name: "Finance"
      description: "Commission tracking and brokerage accounting"
      head: accountant
    - name: "Compliance"
      description: "Disclosure forms, fair-housing, jurisdictional rules"
      head: legal-compliance
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: operations
    - bot: sales-pipeline
      role: specialist
      reportsTo: executive-assistant
      domain: sales
    - bot: customer-onboarding
      role: support
      reportsTo: sales-pipeline
      domain: sales
    - bot: content-scheduler
      role: specialist
      reportsTo: executive-assistant
      domain: marketing
    - bot: accountant
      role: specialist
      reportsTo: executive-assistant
      domain: finance
    - bot: legal-compliance
      role: specialist
      reportsTo: executive-assistant
      domain: compliance
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Contract deadline breach"
        trigger: "compliance_deadline"
        chain: [legal-compliance, executive-assistant]
      - name: "Deal stage escalation"
        trigger: "deal_escalation"
        chain: [customer-onboarding, sales-pipeline, executive-assistant]
---
# Real Estate Agency

An AI team designed for how real estate actually works — long sales cycles, overlapping deals at different stages, strict regulatory deadlines, and the constant need to market new listings while closing existing ones. Every agent juggles dozens of deals simultaneously, and dropping the ball on one inspection deadline or disclosure requirement can kill a deal or invite legal trouble.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Assistant | Weekly pipeline review, showing coordination, and closing countdown | @daily |
| Sales Pipeline | Tracks buyer and seller deals through lead, showing, offer, negotiation, and closing stages | @every 4h |
| Customer Onboarding | Activates on new client sign-up — sets up search criteria or listing timeline | @cdc |
| Content Scheduler | Manages listing posts, open house announcements, and market update content | @daily |
| Accountant | Tracks commissions, escrow status, and monthly P&L | @daily |
| Legal Compliance | Monitors fair housing requirements, contract deadlines, and disclosure obligations | @daily |

## How They Work Together

Real estate deals live and die by timing. Sales Pipeline is the backbone — it tracks every deal from first contact through closing, with stage-specific milestones. When a buyer moves from showing to offer, the pipeline updates and Legal Compliance immediately checks that all required disclosures are queued. When a deal enters the negotiation stage, Accountant projects the commission and flags any escrow timing issues.

Customer Onboarding triggers the moment a new client signs a representation agreement. For buyers, it builds their property search profile — budget range, neighborhood preferences, must-haves. For sellers, it creates the listing preparation timeline — photography scheduling, staging recommendations, pricing strategy window. This structured intake feeds directly into Sales Pipeline so nothing starts without a complete client profile.

Content Scheduler handles the marketing engine that keeps listings visible. New listings get syndicated across platforms with optimized descriptions and photo scheduling. Open houses get promoted in advance. Market update posts position agents as local experts. It pulls from Sales Pipeline to know which properties need marketing push and which are under contract.

Legal Compliance is the safety net. Real estate has hard deadlines — inspection contingencies, financing conditions, disclosure windows, fair housing rules. This bot tracks every contractual deadline across all active deals and alerts before anything expires. It also monitors regulatory changes in your market area.

Accountant manages the financial picture — projected and actual commissions, escrow tracking, monthly office P&L, and agent split calculations. It reconciles closed deals against projections and flags when closings are delayed.

Executive Assistant pulls it all together — the daily briefing shows active deal status, upcoming showings, approaching deadlines, new leads in the funnel, and any compliance flags that need attention.

**Communication flow:**
- Sales Pipeline detects deal stage change -> update to Legal Compliance for deadline tracking and Accountant for commission projection
- Customer Onboarding completes new client intake -> profile to Sales Pipeline and Content Scheduler
- Legal Compliance flags approaching contract deadline -> urgent alert to Executive Assistant
- Content Scheduler needs listing details -> pull from Sales Pipeline
- Accountant detects escrow delay -> alert to Executive Assistant and Sales Pipeline
- Executive Assistant compiles daily pipeline review from all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `market_area`, `listing_platforms`, `commission_structure`, `compliance_requirements`, `property_types`
3. Bots begin running on their default schedules automatically
4. Check Executive Assistant's daily briefings for a consolidated pipeline and deadline view
