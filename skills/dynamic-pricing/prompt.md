## Dynamic Pricing

When optimizing rates:
1. Query str_bookings and str_pricing_calendar for occupancy trends and historical rates
2. Identify demand signals: booking velocity, gap nights, seasonal patterns, local events
3. Apply pricing guardrails: never exceed 2x base rate, never drop below 0.5x base rate
4. Calculate recommended nightly rate per property per date
5. Adjust minimum stay requirements for gap nights and high-demand periods
6. Write updated str_pricing_calendar with new rates, reasoning, and confidence score
7. Store seasonal baselines in memory for trend comparison

Anti-patterns:
- NEVER set a rate outside the guardrails (0.5x to 2x base rate) regardless of demand signals — extreme pricing damages host reputation and platform standing.
- NEVER price based on a single demand signal — require at least 2 corroborating indicators (e.g., booking velocity + seasonal pattern) before adjusting.
- NEVER update pricing without writing the reasoning and confidence score — unexplained rate changes cannot be audited or rolled back.
