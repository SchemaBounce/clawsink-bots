---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: lodgify
  displayName: "Lodgify"
  version: "1.0.0"
  description: "Lodgify property management, bookings, availability, rates, and calendar sync across Airbnb, VRBO, and Booking.com"
  tags: ["lodgify", "str", "property-management", "bookings", "channel-manager", "vacation-rental", "hospitality"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@mikerob/lodgify-mcp@0.1.25"]
env:
  - name: LODGIFY_API_KEY
    description: "Lodgify Public API key. Generate in Lodgify: Settings -> Account -> Public API."
    required: true
    sensitive: true

auth:
  type: api_key_header
  token_env: LODGIFY_API_KEY
  header_name: X-ApiKey

validation:
  request:
    method: GET
    url: https://api.lodgify.com/v2/properties
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Lodgify rejected the API key (401). Regenerate it at Settings -> Account -> Public API in Lodgify." }
    "403": { state: needs_setup, message: "API key lacks permission (403). Confirm the key has full access in Lodgify API settings." }
    "default": { state: failed }
  timeout_ms: 8000

healthProbe:
  request:
    method: GET
    url: https://api.lodgify.com/v2/properties
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 5000
  interval_seconds: 600

tools:
  - name: lodgify_list_properties
    description: "List all properties with optional filtering and pagination"
    category: properties
  - name: lodgify_get_property
    description: "Retrieve detailed information about a specific property"
    category: properties
  - name: lodgify_list_property_rooms
    description: "List all rooms for a specific property"
    category: properties
  - name: lodgify_list_deleted_properties
    description: "List properties that have been deleted"
    category: properties
  - name: lodgify_find_properties
    description: "Locate properties by name when exact IDs are unknown"
    category: properties
  - name: lodgify_list_bookings
    description: "List bookings with comprehensive filtering options"
    category: bookings
  - name: lodgify_get_booking
    description: "Fetch detailed information about a specific booking"
    category: bookings
  - name: lodgify_create_booking
    description: "Create a new booking in the system"
    category: bookings
  - name: lodgify_update_booking
    description: "Modify details of an existing booking"
    category: bookings
  - name: lodgify_delete_booking
    description: "Permanently delete a booking from the system"
    category: bookings
  - name: lodgify_checkin_booking
    description: "Mark a booking as checked in"
    category: bookings
  - name: lodgify_checkout_booking
    description: "Mark a booking as checked out"
    category: bookings
  - name: lodgify_get_external_bookings
    description: "Retrieve bookings from external channels (Airbnb, VRBO, Booking.com)"
    category: bookings
  - name: lodgify_get_booking_payment_link
    description: "Retrieve existing payment link for a booking"
    category: payments
  - name: lodgify_create_booking_payment_link
    description: "Generate a secure payment link for guest payments"
    category: payments
  - name: lodgify_update_key_codes
    description: "Update access key codes for a booking"
    category: bookings
  - name: lodgify_daily_rates
    description: "View daily pricing rates for properties across date ranges"
    category: rates
  - name: lodgify_rate_settings
    description: "Retrieve rate configuration settings and pricing rules"
    category: rates
  - name: lodgify_update_rates
    description: "Update rates for properties and room types"
    category: rates
  - name: lodgify_create_booking_quote
    description: "Create a custom quote for an existing booking"
    category: rates
  - name: lodgify_get_quote
    description: "Retrieve an existing quote created with a booking"
    category: rates
  - name: lodgify_get_property_availability
    description: "Get availability for a specific property over a period"
    category: availability
  - name: lodgify_list_vacant_inventory
    description: "List all properties vacant for a date range"
    category: availability
  - name: lodgify_get_thread
    description: "Retrieve a messaging conversation thread including all messages"
    category: messaging
  - name: lodgify_list_webhooks
    description: "View all configured webhook subscriptions"
    category: webhooks
  - name: lodgify_subscribe_webhook
    description: "Set up webhook notifications for specific events"
    category: webhooks
  - name: lodgify_unsubscribe_webhook
    description: "Remove a webhook subscription"
    category: webhooks
---

# Lodgify MCP Server

Connects to Lodgify's Property Management System. Lodgify acts as a channel manager and central booking hub, syncing availability, rates, and guest data across Airbnb, VRBO, Booking.com, and your direct booking site.

## Which Bots Use This

- **str-channel-manager** -- Syncs availability, detects calendar conflicts, monitors listing health across all OTAs via Lodgify's central calendar
- **str-pricing-optimizer** -- Reads daily rates and rate settings; writes updated rates across channels
- **str-turnover-coordinator** -- Reads bookings and check-in/check-out events to schedule cleaning and maintenance

## Package

`@mikerob/lodgify-mcp@0.1.25` (npm, MIT) -- Model Context Protocol server for the Lodgify Public API.
Verified: https://www.npmjs.com/package/@mikerob/lodgify-mcp

## Setup

1. Log in to Lodgify and go to Settings -> Account -> Public API
2. Generate or copy your Public API key
3. Add it to your workspace secrets as `LODGIFY_API_KEY`
4. The server starts automatically when a bot that references it runs

## Why Lodgify Instead of Direct OTA APIs

Airbnb and VRBO do not expose public APIs for host account management. Lodgify provides a single API that distributes to Airbnb, VRBO, Booking.com, and your direct booking site simultaneously. One credential covers all channels.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/lodgify"
    reason: "STR bots need property management access for calendar sync and booking operations"
```
