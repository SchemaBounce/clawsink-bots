## CDC Event Analysis

1. Read the specific CDC event that triggered this run. Do not scan all events.
2. Load baseline patterns and thresholds from memory.
3. Compare the event's field values, operation type, and timing against the baseline.
4. Classify severity: critical (immediate action), high (investigate soon), medium (note for trends), low (informational).
5. Write an event_findings record with the classification, reasoning, and affected entity.
6. If severity is critical, write an event_alerts record so downstream bots can act immediately.
7. Update baseline statistics in memory if this event shifts known patterns.

Anti-patterns:
- NEVER scan all events when triggered by a specific CDC event — read only the triggering event to avoid unbounded queries.
- NEVER classify severity without comparing against the loaded baseline — raw values without context produce false positives.
- NEVER update baselines from a single outlier event — require 3+ consistent shifts before adjusting thresholds.
