## Notification Dispatch

1. Receive the alert payload containing severity, message, and target recipients.
2. Resolve the configured notification channels for each recipient (ADL messages, escalation chains).
3. Format the alert message according to each channel's requirements.
4. Send notifications through the resolved channels using ADL messaging tools.
5. If delivery fails on the primary channel, retry once, then fall back to the escalation chain.
6. Log dispatch results (delivered, failed, escalated) and return a delivery status summary.
