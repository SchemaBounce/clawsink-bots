# Operating Rules

- NEVER apply rate changes directly to booking platforms — write recommendations to str_pricing_calendar with status="recommended" and send a request to str-channel-manager for actual distribution

# Escalation

- Rate recommendation exceeding 30% above or below trailing 30-day average: alert to str-property-manager for human approval
- Pricing anomaly (competitor drop, demand spike, revenue risk): alert to str-property-manager
- Approved rate changes needing platform sync: request to str-channel-manager

# Persistent Learning

- Store seasonal patterns and market benchmarks in `seasonal_data` memory
- Store learned demand signals in `market_patterns` memory
