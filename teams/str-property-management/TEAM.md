---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: str-property-management
  displayName: "STR Property Management"
  version: "1.0.0"
  description: "End-to-end short-term rental automation covering portfolio management, channel sync, guest communication, dynamic pricing, listing marketing, review management, and cleaning coordination"
  domain: hospitality
  category: operations
  tags: ["str", "airbnb", "vrbo", "lodgify", "property-management", "hospitality", "channel-sync", "dynamic-pricing", "guest-communication"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/str-property-manager@1.0.7"
  - ref: "bots/str-channel-manager@1.0.8"
  - ref: "bots/str-guest-communicator@1.0.7"
  - ref: "bots/str-pricing-optimizer@1.0.7"
  - ref: "bots/str-property-marketer@1.0.8"
  - ref: "bots/str-review-manager@1.0.7"
  - ref: "bots/str-turnover-coordinator@1.0.7"
northStar:
  industry: "Short-Term Rental"
  context: "Property owner or manager running short-term rentals on Airbnb, VRBO, Booking.com, or direct-booking channels via Lodgify"
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
      description: "Daily portfolio briefings, cross-domain coordination, and owner-level escalation"
      head: str-property-manager
    - name: "Channel Operations"
      description: "Multi-platform listing sync, calendar conflict detection, and listing health monitoring"
      head: str-channel-manager
    - name: "Guest Relations"
      description: "Guest messaging across all booking platforms and post-stay review follow-up"
      head: str-guest-communicator
      children:
        - name: "Reviews"
          description: "Review monitoring, host response drafting, and rating trend analysis"
          head: str-review-manager
    - name: "Revenue"
      description: "Dynamic pricing recommendations, gap-night optimization, and market rate analysis"
      head: str-pricing-optimizer
    - name: "Marketing"
      description: "Listing content creation, seasonal promotions, and social media posts"
      head: str-property-marketer
    - name: "Operations"
      description: "Cleaning schedules between guests, turnover status tracking, and maintenance flagging"
      head: str-turnover-coordinator
  roles:
    - bot: str-property-manager
      role: lead
      reportsTo: null
      domain: portfolio-management
    - bot: str-channel-manager
      role: specialist
      reportsTo: str-property-manager
      domain: channel-operations
    - bot: str-guest-communicator
      role: specialist
      reportsTo: str-property-manager
      domain: guest-relations
    - bot: str-review-manager
      role: support
      reportsTo: str-guest-communicator
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
  escalation:
    critical: str-property-manager
    unhandled: str-property-manager
    paths:
      - name: "Calendar Conflict"
        trigger: "calendar_conflict_detected"
        chain: [str-channel-manager, str-property-manager]
      - name: "Guest Emergency"
        trigger: "guest_emergency"
        chain: [str-guest-communicator, str-property-manager]
      - name: "Late Turnover"
        trigger: "turnover_late"
        chain: [str-turnover-coordinator, str-guest-communicator, str-property-manager]
      - name: "Negative Review"
        trigger: "negative_review_detected"
        chain: [str-review-manager, str-guest-communicator, str-property-manager]
      - name: "Revenue Anomaly"
        trigger: "pricing_anomaly_detected"
        chain: [str-pricing-optimizer, str-property-manager]
---
# STR Property Management

Seven bots covering the full short-term rental lifecycle: portfolio coordination, multi-channel listing sync, guest communication, dynamic pricing, property marketing, review management, and turnover scheduling.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Property Manager | Lead coordinator, daily portfolio briefings, owner escalation | @daily |
| Channel Manager | Calendar sync across Airbnb/VRBO/Lodgify, conflict detection, listing health | @every 2h |
| Guest Communicator | Automated guest messaging, check-in instructions, Superhost response metrics | @every 15m |
| Dynamic Pricing | Nightly rate optimization, gap-night pricing, local event demand signals | @daily |
| Property Marketer | Listing descriptions, seasonal promotions, social media content drafts | @weekly |
| Review Manager | Review monitoring, host response drafts, rating trend analysis | @daily |
| Turnover Coordinator | Cleaning assignment scheduling, late-turnover alerts, maintenance flagging | @every 4h |

## How They Work Together

Property Manager is the orchestrator. It reads findings and alerts from all six specialists and produces a daily portfolio briefing covering occupancy, revenue, and active flags.

Channel Manager runs every two hours to keep calendars consistent across Airbnb, VRBO, and Lodgify. When it detects a conflict or sync failure, it alerts Property Manager immediately and notifies Dynamic Pricing to re-evaluate affected dates.

Guest Communicator runs every 15 minutes to protect Superhost response-time metrics. When a stay ends, it signals Review Manager to start the post-stay follow-up sequence. Check-in or checkout time changes are forwarded to Turnover Coordinator so cleaning windows adjust automatically.

Review Manager drafts host responses and sends them to Guest Communicator for approval before posting, keeping the guest-facing voice consistent. Positive review themes are forwarded to Property Marketer for incorporation into listing descriptions.

Dynamic Pricing recommends rate changes to Property Manager and requests Channel Manager to push approved rates to the booking platforms. Extreme deviations (above 30% from the trailing average) always require human approval before distribution.

Property Marketer sends all content drafts to Property Manager for approval. It never publishes directly. Approved listing descriptions are forwarded to Channel Manager for platform distribution.

Turnover Coordinator generates cleaning assignments from checkout and check-in pairs. When a turnover is running late, it alerts both Guest Communicator (who notifies the arriving guest) and Property Manager.

**Communication flow:**
- All specialist bots send findings -> Property Manager for daily briefing
- Channel Manager detects conflict -> alert to Property Manager + finding to Dynamic Pricing
- Guest Communicator stay-complete signal -> finding to Review Manager
- Guest Communicator time-change signal -> finding to Turnover Coordinator
- Review Manager positive themes -> finding to Property Marketer
- Review Manager response draft -> finding to Guest Communicator for approval
- Dynamic Pricing approved rates -> request to Channel Manager for distribution
- Property Marketer content -> finding to Property Manager for approval, then to Channel Manager
- Turnover Coordinator late alert -> alert to Guest Communicator + Property Manager

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `property_count`, `primary_channel`, `target_occupancy_rate`, `market_type`, `average_nightly_rate`, `check_in_method`, `cleaning_service`, `booking_channels`
3. Connect Lodgify (Settings -> Account -> Public API key) to cover calendar, bookings, and rates across Airbnb, VRBO, and Booking.com in one connection
4. Bots begin running on their default schedules automatically
5. Check Property Manager's daily briefing for consolidated portfolio status and pending owner actions
