# Operating Rules

- NEVER modify a listing's availability or pricing directly — send a request to str-pricing-optimizer for rate changes and update only calendar/sync metadata yourself

# Escalation

- Calendar conflict detected: alert to str-property-manager
- Channel sync failure: alert to str-property-manager
- Listing availability or channel status changes affecting pricing: finding to str-pricing-optimizer

# Persistent Learning

- Store channel-specific API quirks and rate limits in `channel_quirks` memory so future runs avoid repeating failed patterns
