---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: short-term-rental
  displayName: "Short-Term Rental Operations"
  version: "1.0.0"
  description: "Full-stack AI operations for vacation rental portfolios. Multi-channel management, guest communication, dynamic pricing, and property marketing across Airbnb, VRBO, Lodgify, and Facebook Marketplace."
  category: hospitality
  tags: ["airbnb", "vrbo", "lodgify", "vacation-rental", "str", "property-management", "hospitality", "flagship"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
requirements:
  minTier: "starter"
bots:
  - ref: "bots/str-property-manager@1.0.0"
  - ref: "bots/str-channel-manager@1.0.0"
  - ref: "bots/str-guest-communicator@1.0.0"
  - ref: "bots/str-pricing-optimizer@1.0.0"
  - ref: "bots/str-property-marketer@1.0.0"
  - ref: "bots/str-turnover-coordinator@1.0.0"
  - ref: "bots/str-review-manager@1.0.0"
dataKits:
  - ref: "data-kits/short-term-rental@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/crm-contacts@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/financial-ops@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/content-marketing@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "Short-Term Rental / Vacation Property"
  context: "Property managers and hosts managing vacation rentals across multiple platforms, from single-property Airbnb hosts to 50+ property portfolio managers"
  requiredKeys:
    - property_count
    - primary_channel
    - target_occupancy_rate
    - market_type
    - average_nightly_rate
    - check_in_method
    - cleaning_service
    - booking_channels
orgChart:
  lead: str-property-manager
  domains:
    - name: "Portfolio Management"
      description: "Oversight across all properties in the portfolio"
      head: str-property-manager
    - name: "Channel Ops"
      description: "Airbnb / VRBO / Booking.com listing sync + calendar"
      head: str-channel-manager
    - name: "Guest Relations"
      description: "Pre-arrival, in-stay, and post-stay guest comms"
      head: str-guest-communicator
      children:
        - name: "Reviews"
          description: "Review request, response, and sentiment mining"
          head: str-review-manager
    - name: "Revenue"
      description: "Dynamic pricing and ADR/occupancy optimization"
      head: str-pricing-optimizer
    - name: "Marketing"
      description: "Listing copy, photography, and direct-booking promo"
      head: str-property-marketer
    - name: "Operations"
      description: "Cleaning, turnover, maintenance coordination"
      head: str-turnover-coordinator
  roles:
    - bot: str-property-manager
      role: lead
      reportsTo: null
      domain: portfolio-management
    - bot: str-channel-manager
      role: specialist
      reportsTo: str-property-manager
      domain: channel-ops
    - bot: str-guest-communicator
      role: specialist
      reportsTo: str-property-manager
      domain: guest-relations
    - bot: str-pricing-optimizer
      role: specialist
      reportsTo: str-property-manager
      domain: revenue
    - bot: str-property-marketer
      role: specialist
      reportsTo: str-property-manager
      domain: marketing
    - bot: str-turnover-coordinator
      role: specialist
      reportsTo: str-property-manager
      domain: operations
    - bot: str-review-manager
      role: support
      reportsTo: str-guest-communicator
      domain: guest-relations
  escalation:
    critical: str-property-manager
    unhandled: str-property-manager
    paths:
      - name: "Guest emergency"
        trigger: "guest_emergency"
        chain: [str-guest-communicator, str-property-manager]
      - name: "Channel sync failure"
        trigger: "channel_sync_error"
        chain: [str-channel-manager, str-property-manager]
      - name: "Pricing anomaly"
        trigger: "pricing_anomaly"
        chain: [str-pricing-optimizer, str-property-manager]
      - name: "Negative review"
        trigger: "negative_review"
        chain: [str-review-manager, str-guest-communicator, str-property-manager]
      - name: "Turnover issue"
        trigger: "turnover_problem"
        chain: [str-turnover-coordinator, str-property-manager]
---

# Short-Term Rental Operations

The flagship AI operations team for vacation rental businesses. Whether you manage a single Airbnb listing or a portfolio of 50+ properties across multiple channels, this team handles the operational complexity that comes with short-term rental management — calendar synchronization, guest communication at Superhost speed, dynamic pricing, turnover logistics, review management, and property marketing.

## Included Bots

| Bot | Role | Schedule | What It Does |
|-----|------|----------|--------------|
| Property Manager | Lead | @daily | Consolidates all specialist outputs, manages portfolio dashboard, coordinates team, delivers owner briefings |
| Channel Manager | Specialist | @every 2h | Syncs listings across Airbnb, VRBO, Lodgify, Facebook Marketplace — detects calendar conflicts, monitors listing health |
| Guest Communicator | Specialist | @every 15m | Auto-responds to guest messages across all channels — pre-booking questions, check-in instructions, during-stay requests |
| Dynamic Pricing | Specialist | @daily | Analyzes market conditions, competitor rates, demand patterns, and local events to optimize nightly rates |
| Property Marketer | Specialist | @weekly | Creates listing descriptions, manages social media, generates seasonal promotions, handles Facebook Marketplace engagement |
| Turnover Coordinator | Specialist | @every 4h | Manages cleaning schedules, tracks turnover status, ensures properties are guest-ready, flags maintenance issues |
| Review Manager | Support | @daily | Monitors reviews across platforms, drafts host responses, identifies feedback patterns, tracks rating trends |

## How They Work Together

In short-term rental, response time is everything. A guest inquiry that sits unanswered for 2 hours means a lost booking — and platforms punish slow responders in search rankings. Guest Communicator runs every 15 minutes, handling the time-sensitive front line: answering pre-booking questions with property-specific details, sending check-in instructions at the right moment, fielding during-stay requests ("Where's the thermostat?"), and queuing post-stay follow-ups.

Behind the scenes, Channel Manager keeps the multi-platform operation from falling apart. When you list the same property on Airbnb, VRBO, and Lodgify, calendar conflicts are a constant threat. Channel Manager syncs availability every 2 hours, catches double-booking risks before they become cancellations, and monitors listing health scores across platforms — flagging when a listing drops in search ranking or has stale photos.

Dynamic Pricing watches the numbers that determine profitability. It analyzes comparable listings in your market, tracks demand patterns (weekends vs. weekdays, festivals, school holidays), and adjusts nightly rates to maximize revenue per available night. When it detects an anomaly — a competitor suddenly dropping rates 40%, or a local event that should spike demand — it flags the situation to Property Manager with a recommendation.

Turnover Coordinator handles the operational chaos between guests. With back-to-back bookings, the window between checkout and check-in can be as tight as 4 hours. The coordinator manages cleaning assignments, tracks completion status, ensures quality checklists are followed, and raises immediate alerts when a turnover is running late — giving you time to push back a check-in time or call a backup cleaner.

Review Manager operates in the guest-relations domain alongside Guest Communicator. It monitors reviews across all platforms, drafts professional host responses (matching platform tone — casual on Airbnb, formal on VRBO), identifies patterns in negative feedback ("Three guests mentioned the mattress"), and tracks rating trends per property. Negative reviews escalate through Guest Communicator to Property Manager.

Property Marketer handles the growth side — optimizing listing descriptions with SEO best practices per platform, generating seasonal promotions, managing social media presence for the portfolio, and handling Facebook Marketplace listings. It pulls from review data to know which property features guests love most, and from pricing data to understand which promotions drive profitable bookings.

Property Manager ties everything together. The daily briefing covers: occupancy for the next 30 days, any calendar conflicts flagged by Channel Manager, response time metrics from Guest Communicator, pricing recommendations from Dynamic Pricing, pending turnovers from Turnover Coordinator, review sentiment trends from Review Manager, and active promotions from Property Marketer.

**Communication flow:**
- Guest Communicator detects emergency or escalation-worthy request -> alert to Property Manager
- Channel Manager detects calendar conflict or sync failure -> alert to Property Manager
- Dynamic Pricing identifies anomaly or rate change opportunity -> finding to Property Manager
- Turnover Coordinator flags late cleaning or maintenance issue -> alert to Property Manager
- Review Manager spots negative review -> alert to Guest Communicator and Property Manager
- Property Marketer produces new content draft -> finding to Property Manager for approval
- Property Manager compiles daily portfolio briefing from all specialists

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `property_count`, `primary_channel`, `target_occupancy_rate`, `market_type`, `average_nightly_rate`, `check_in_method`, `cleaning_service`, `booking_channels`
3. Bots begin running on their default schedules automatically
4. Check Property Manager's daily briefings for a consolidated portfolio view
5. Guest Communicator starts handling guest messages within 15 minutes of activation
