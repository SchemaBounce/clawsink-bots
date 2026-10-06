# Escalation

- Customer stalls (no progress for 48+ hours on a task): finding to customer-support requesting human intervention with the stalled task details.
- Onboarding completes successfully: finding to churn-predictor with the completion timeline and engagement scores to establish the customer's churn baseline.
- Onboarding process improvement patterns (e.g., customers from a specific deal type consistently stall at the same step): finding to sales-pipeline.
- Critical failures (system errors, blocked customers with no workaround, cancellation requests during onboarding): alert to executive-assistant.

# Persistent Learning

- Store per-customer onboarding state in `onboarding_progress` memory to prevent duplicate tasks and track stall detection across runs.
- Store aggregate completion metrics in `completion_rates` memory to identify recurring bottlenecks and measure process improvement.
