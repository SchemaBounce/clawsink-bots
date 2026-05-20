---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: lodgify
  displayName: "Lodgify"
  version: "0.1.25"
  description: "Lodgify vacation-rental PMS: properties, bookings, availability, rates, quotes, payment links, webhooks"
  tags: ["short-term-rental", "vacation-rental", "property-management", "hospitality", "bookings"]
  author: "MikeRobGIT (community)"
  license: "MIT"
  category: integration
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@mikerob/lodgify-mcp@0.1.25"]
env:
  - name: LODGIFY_API_KEY
    description: "Lodgify Public API key (Account > Settings > Public API)"
    required: true
    sensitive: true
  - name: LODGIFY_READ_ONLY
    description: "Set to 1 to block all write operations (bookings, rates, key codes)"
    required: false
    sensitive: false
tools:
  - name: lodgify_list_properties
    description: "List properties with filtering and pagination"
    category: properties
  - name: lodgify_get_property
    description: "Get a property's details"
    category: properties
  - name: lodgify_list_property_rooms
    description: "List room types for a property"
    category: properties
  - name: lodgify_list_deleted_properties
    description: "List removed properties"
    category: properties
  - name: lodgify_find_properties
    description: "Search properties by name"
    category: properties
  - name: lodgify_list_bookings
    description: "Query bookings by date and status"
    category: bookings
  - name: lodgify_get_booking
    description: "Get a booking's full details"
    category: bookings
  - name: lodgify_create_booking
    description: "Create a booking"
    category: bookings
  - name: lodgify_update_booking
    description: "Update a booking"
    category: bookings
  - name: lodgify_delete_booking
    description: "Delete a booking"
    category: bookings
  - name: lodgify_checkin_booking
    description: "Record guest check-in"
    category: bookings
  - name: lodgify_checkout_booking
    description: "Record guest check-out"
    category: bookings
  - name: lodgify_get_external_bookings
    description: "List OTA and channel bookings (VRBO, Airbnb, Booking.com)"
    category: bookings
  - name: lodgify_update_key_codes
    description: "Set guest access and key codes"
    category: bookings
  - name: lodgify_get_booking_payment_link
    description: "Get an existing payment link for a booking"
    category: payments
  - name: lodgify_create_booking_payment_link
    description: "Generate a payment link for an outstanding balance"
    category: payments
  - name: lodgify_get_property_availability
    description: "Check availability over a date range"
    category: availability
  - name: lodgify_list_vacant_inventory
    description: "List all vacant units across properties"
    category: availability
  - name: lodgify_daily_rates
    description: "Nightly rates for dates and room types"
    category: rates
  - name: lodgify_rate_settings
    description: "Rate configuration and rules"
    category: rates
  - name: lodgify_update_rates
    description: "Update pricing across date periods"
    category: rates
  - name: lodgify_create_booking_quote
    description: "Generate a custom pricing quote"
    category: rates
  - name: lodgify_get_quote
    description: "Retrieve an existing quote"
    category: rates
  - name: lodgify_get_thread
    description: "Get a guest messaging thread"
    category: messaging
  - name: lodgify_list_webhooks
    description: "List webhook subscriptions"
    category: webhooks
  - name: lodgify_subscribe_webhook
    description: "Subscribe to an event webhook"
    category: webhooks
  - name: lodgify_unsubscribe_webhook
    description: "Unsubscribe a webhook"
    category: webhooks
---

# Lodgify MCP Server

Full Lodgify Public API access for short-term-rental operations. Lodgify is the host-side PMS; bookings made on VRBO, Airbnb, and Booking.com surface here via channel sync (`lodgify_get_external_bookings`). Set `LODGIFY_READ_ONLY=1` to run an agent in a safe read-only mode.

## Which Bots Use This

- **str-property-manager** -- Portfolio operations: property status, bookings, availability, rates, and owner reporting
- **str-channel-manager** -- Channel listings and OTA booking reconciliation
- **str-pricing-optimizer** -- Reads daily rates and updates pricing across date periods

## Setup

1. In Lodgify, go to Account > Settings > Public API and generate an API key.
2. Add it to your workspace secrets as `LODGIFY_API_KEY`.
3. Optionally set `LODGIFY_READ_ONLY=1` to disable all write operations.
4. The server starts automatically when a bot that references it runs.
