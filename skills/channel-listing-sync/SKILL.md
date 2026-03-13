---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: channel-listing-sync
  displayName: "Channel Listing Sync"
  version: "1.0.0"
  description: "Synchronize property listings across Airbnb, VRBO, Lodgify, and Facebook Marketplace."
  tags: ["airbnb", "vrbo", "lodgify", "channel-management", "sync"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_write_memory"]
data:
  producesEntityTypes: ["str_channel_listings"]
  consumesEntityTypes: ["str_properties", "str_bookings", "str_pricing_calendar"]
---
# Channel Listing Sync

Detects conflicts across channels, updates availability calendars, and maintains listing health scores for multi-platform property distribution.
