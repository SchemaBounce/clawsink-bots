---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: short-term-rental
  displayName: Short-Term Rental & Vacation Property
  version: "1.0.0"
  description: Full-stack STR data kit covering properties, bookings, guests, reviews, channel listings, pricing, turnovers, and messaging.
  category: industry
  tags:
    - airbnb
    - vrbo
    - lodgify
    - vacation-rental
    - property-management
    - hospitality
    - str
  author: SchemaBounce
compatibility:
  teams:
    - vacation-rental-group
  composableWith:
    - crm-contacts
    - financial-ops
    - customer-feedback
entityPrefix: str_
entityCount: 8
graphEdgeTypes:
  - BOOKED
  - REVIEWED
  - LISTED_ON
  - CLEANED_BY
  - MESSAGED_ABOUT
vectorCollections:
  - str_properties
  - str_reviews
  - str_messages
---

# Short-Term Rental & Vacation Property

The flagship Data Kit for short-term rental and vacation property management. Covers the complete operational lifecycle from property listings and multi-channel distribution through guest communications, turnover scheduling, dynamic pricing, and review management. Built for Airbnb hosts, VRBO managers, Lodgify users, and independent property managers running portfolios of any size.

## What's Included

- **Properties** -- Complete property catalog with amenities, house rules, capacity, and access details
- **Bookings** -- Reservations aggregated across Airbnb, VRBO, Lodgify, direct, and Facebook Marketplace
- **Guests** -- Unified guest profiles with cross-channel identity stitching and lifetime value
- **Reviews** -- Ratings and feedback from all platforms with category breakdowns and host responses
- **Channel Listings** -- Per-channel listing status, sync health, pricing overrides, and instant book settings
- **Pricing Calendar** -- Date-level pricing and availability with demand signals and competitor benchmarks
- **Turnovers** -- Cleaning and maintenance scheduling between guest stays with inspection tracking
- **Messages** -- Guest communications across all channels with response time metrics and sentiment

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Occupancy Rate | 65-80% | Revenue optimization vs. wear-and-tear balance |
| Average Daily Rate (ADR) | Market-dependent | Primary revenue lever per night |
| RevPAN (Revenue Per Available Night) | ADR x Occupancy | True portfolio yield metric |
| Guest Satisfaction | 4.7+/5.0 | Superhost eligibility and search ranking |
| Response Time | <15 min | Airbnb Superhost requirement and booking conversion |
| Review Response Rate | 100% | Platform algorithm boost and guest trust |
| Cleaning Turnaround | <4 hours | Back-to-back booking enablement |
| Cancellation Rate | <5% | Revenue predictability and ranking impact |
| Repeat Guest Rate | >15% | Lower acquisition cost and higher satisfaction |
| Channel Distribution | No channel >60% | Risk diversification against policy changes |

## Graph Relationships

- **BOOKED** links guests to properties through their booking history with channel and revenue data
- **REVIEWED** links guests to properties through reviews with ratings and sentiment
- **LISTED_ON** links properties to their channel listings with sync status and pricing
- **CLEANED_BY** links turnover events to the properties they service with timing and status
- **MESSAGED_ABOUT** links guest messages to their associated bookings for conversation threading

## Composability

Pairs naturally with:
- **crm-contacts** -- Link guest profiles to broader CRM records for repeat marketing
- **financial-ops** -- Connect booking payouts to accounting and tax reporting
- **customer-feedback** -- Aggregate reviews into cross-property feedback workflows

## Industry Context

The short-term rental market operates across fragmented channels (Airbnb, VRBO, Booking.com, direct bookings) with complex pricing dynamics driven by seasonality, local events, and competitor behavior. Successful operators must balance occupancy against rate optimization, maintain Superhost/Premier Host status across platforms, and coordinate rapid turnovers between back-to-back bookings. This kit provides the data foundation for AI agents to automate pricing decisions, guest communication, review management, and operational coordination.
