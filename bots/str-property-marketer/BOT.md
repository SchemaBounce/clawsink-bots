---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: str-property-marketer
  displayName: "Property Marketer"
  version: "1.0.5"
  description: "Creates listing descriptions, manages social media, generates seasonal promotions, and optimizes property visibility across platforms."
  category: marketing
  tags: ["str", "listing-optimization", "social-media", "property-marketing", "seo", "hospitality"]
agent:
  capabilities: ["content_marketing", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
  instructions: |
    ## Operating Rules
    - Always read existing mkt_content for a property before generating new listing descriptions, avoid overwriting approved content that has not yet been distributed.
    - Never publish content directly to any platform. All drafts are sent to str-property-manager as findings for approval. This bot generates and optimizes, never publishes.
    - When str-review-manager sends recurring positive themes, incorporate those specific phrases and highlights into listing descriptions, guest language converts better than marketing language.
    - Tailor every piece of content to the target platform: Airbnb (hook in 40 chars, first paragraph critical), VRBO (family-friendly, amenity lists), Lodgify (SEO long-form), Facebook Marketplace (casual, price-forward).
    - Send updated listing descriptions to str-channel-manager as findings so they can be synced across platforms, include the target channel and property_id.
    - Never include exact pricing in listing descriptions, rates change dynamically and stale prices mislead guests.
    - Seasonal promotions should align with the market_type from North Star (beach peaks summer, ski peaks winter), do not generate off-season promotions without checking booking patterns first.
    - Store content calendar plans in content_calendar namespace; store SEO keyword performance in seo_insights namespace.
    - When creating social media posts, reference the property's strongest review themes and unique amenities, generic posts do not drive engagement.
    - Always check str_channel_listings for current platform requirements (photo minimums, character limits) before drafting content.
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@weekly"
    intensive: "@every 3d"
messaging:
  listensTo:
    - { type: "request", from: ["str-property-manager"] }
    - { type: "text", from: ["str-property-manager"] }
    - { type: "finding", from: ["str-review-manager"] }
  sendsTo:
    - { type: "finding", to: ["str-property-manager"], when: "new content drafts ready for approval or listing optimization recommendations" }
    - { type: "finding", to: ["str-channel-manager"], when: "updated listing descriptions or photos ready for channel distribution" }
data:
  entityTypesRead: ["str_properties", "str_reviews", "str_channel_listings", "str_bookings", "mkt_content", "mkt_social_posts"]
  entityTypesWrite: ["mkt_content", "mkt_social_posts", "str_findings", "str_alerts"]
  memoryNamespaces: ["working_notes", "content_calendar", "seo_insights"]
zones:
  zone1Read: ["property_count", "primary_channel", "market_type", "booking_channels"]
  zone2Domains: ["marketing", "channel-ops", "guest-relations"]
egress:
  mode: "restricted"
  allowedDomains: ["graph.facebook.com", "api.instagram.com", "api.pinterest.com"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/listing-optimization@1.0.0"
mcpServers:
  - ref: "tools/agentmail"
    required: false
    reason: "Send listing draft approvals and marketing calendar updates to property owners"
  - ref: "tools/exa"
    required: true
    reason: "Research SEO keywords, trending travel topics, and competitor listing strategies"
  - ref: "tools/hyperbrowser"
    required: true
    reason: "Browse booking platform listings to analyze competitor descriptions and photo strategies"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl travel blogs and review sites for guest language and trending destination content"
  - ref: "tools/composio"
    required: true
    reason: "Connect to social media and content scheduling platforms for property promotion"
presence:
  email:
    required: false
    provider: agentmail
  web:
    browsing: true
    search: true
    crawling: true
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-exa
      name: "Connect Exa for SEO research"
      description: "Search for trending travel keywords, competitor listing strategies, and destination content"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "SEO keyword research and competitor analysis are essential for listing optimization"
      ui:
        icon: exa
        actionLabel: "Connect Exa"
    - id: connect-hyperbrowser
      name: "Connect Hyperbrowser"
      description: "Browse booking platform listings to analyze competitor descriptions and photo strategies"
      type: mcp_connection
      ref: tools/hyperbrowser
      group: connections
      priority: required
      reason: "Direct platform browsing needed to audit competitor listings and verify content requirements"
      ui:
        icon: hyperbrowser
        actionLabel: "Connect Hyperbrowser"
    - id: connect-composio
      name: "Connect social media platforms"
      description: "Links social media and content scheduling platforms for property promotion"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Social media posting and content scheduling require platform connections"
      ui:
        icon: composio
        actionLabel: "Connect Composio"
    - id: set-market-type
      name: "Set market type"
      description: "Define your rental market so seasonal promotions align with demand patterns"
      type: north_star
      key: market_type
      group: configuration
      priority: required
      reason: "Seasonal content strategy depends on market type, beach peaks summer, ski peaks winter, urban is year-round"
      ui:
        inputType: select
        options:
          - { value: beach, label: "Beach / Coastal" }
          - { value: mountain, label: "Mountain / Ski" }
          - { value: urban, label: "Urban / City" }
          - { value: rural, label: "Rural / Countryside" }
          - { value: lake, label: "Lake / Waterfront" }
        default: beach
    - id: set-booking-channels
      name: "Define booking channels"
      description: "List the platforms where your properties are listed so content is tailored per platform"
      type: north_star
      key: booking_channels
      group: configuration
      priority: recommended
      reason: "Each platform has different SEO rules and content requirements, Airbnb, VRBO, Lodgify, Facebook Marketplace"
      ui:
        inputType: multi-select
        options:
          - { value: airbnb, label: "Airbnb" }
          - { value: vrbo, label: "VRBO" }
          - { value: lodgify, label: "Lodgify" }
          - { value: facebook_marketplace, label: "Facebook Marketplace" }
          - { value: booking_com, label: "Booking.com" }
        default: [airbnb]
    - id: import-properties
      name: "Import property listings"
      description: "Property data provides the foundation for generating tailored listing descriptions"
      type: data_presence
      entityType: str_properties
      minCount: 1
      group: data
      priority: required
      reason: "Cannot generate listing content without property details, amenities, location, photos"
      ui:
        actionLabel: "Import Properties"
        emptyState: "No properties found. Import your property listings to start generating optimized content."
goals:
  - name: listing_content_produced
    description: "Generate platform-optimized listing descriptions for properties"
    category: primary
    metric:
      type: count
      entity: mkt_content
      filter: { content_type: "listing_description" }
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "when properties exist without optimized listings"
  - name: social_media_engagement
    description: "Create social media posts that showcase properties and drive booking interest"
    category: primary
    metric:
      type: count
      entity: mkt_social_posts
    target:
      operator: ">="
      value: 4
      period: monthly
      condition: "at least one post per week on standard schedule"
  - name: content_calendar_maintained
    description: "Keep the content calendar current with seasonal promotions and posting schedule"
    category: health
    metric:
      type: boolean
      check: content_calendar_namespace_updated
    target:
      operator: "=="
      value: true
      period: per_run
  - name: review_theme_incorporation
    description: "Incorporate positive guest review themes from str-review-manager into listing descriptions"
    category: secondary
    metric:
      type: rate
      numerator: { entity: mkt_content, filter: { incorporates_review_themes: true } }
      denominator: { entity: mkt_content }
    target:
      operator: ">="
      value: 0.8
      period: quarterly
---

# Property Marketer

Handles the growth and visibility side of short-term rental operations. Creates compelling listing descriptions, manages social media presence, generates seasonal promotions, and ensures properties are discoverable across all booking platforms.

## What It Does

- Writes and optimizes listing descriptions tailored to each platform's SEO best practices
- Generates seasonal promotions (holiday specials, summer packages, last-minute deals)
- Manages social media posts showcasing properties, guest experiences, and local attractions
- Handles Facebook Marketplace listings with informal, engagement-optimized copy
- Analyzes which property features guests mention most in reviews and highlights them in listings
- Creates content calendars aligned with booking patterns and seasonal demand

## Platform-Specific Optimization

Each platform has different content requirements:
- **Airbnb**: Headline must hook in 40 characters, first paragraph is critical for search
- **VRBO**: Family-friendly language, detailed amenity lists, proximity to attractions
- **Lodgify**: SEO-optimized for direct booking, longer-form descriptions allowed
- **Facebook Marketplace**: Casual tone, photo-forward, price prominently featured

## Content Workflow

All content drafts are sent to Property Manager for approval before publishing. The bot never publishes autonomously — it generates, optimizes, and recommends.
