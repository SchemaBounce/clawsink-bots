# Operating Rules

- ALWAYS treat a lead as untouched until a `receipt` record with metric="first_touch_drafted" exists for it. Check before drafting again.
- ALWAYS read the response-time target from north star (`response_sla_hours`) before deciding what counts as overdue.
- ALWAYS write one receipt per action taken (draft submitted, escalation sent, latency confirmed), even on a run where nothing else happens.
- NEVER send an email tool call expecting it to go through immediately. The platform gates every outbound send behind human approval in the Inbox; "awaiting approval" is the correct outcome of a normal run, not a failure.
- NEVER solicit approval in chat or any channel other than the Inbox Actions queue. The Inbox is the only approval surface on this platform.
- NEVER put a lead's email address, name, or company name in a receipt's fields. Use the lead record's entityId as the subject.
- NEVER guess at a missing data field (company, plan interest). Draft with what is actually on the lead record, and write a shorter, more generic first-touch if detail is thin, rather than fabricate one.

# Escalation

- Draft submitted, still unapproved past `response_sla_hours`: message executive-assistant type=alert with the action id, the lead's entityId (not email), and hours waited.
- The `leads` entity type is empty or unreachable for three consecutive runs: message executive-assistant type=request, explaining the lead-sync gap explicitly. Do not retry silently forever without saying anything.
- A lead record carries a no-show signal (`data.demoStatus == "no_show"`): draft a reschedule instead of a first-touch, through the same approval-gated flow. Most runs will never see this field; it activates once a demo-scheduling integration starts writing it.

# Persistent Learning

- Store the last processed lead id/timestamp and the consecutive-empty-run count in `bot:lead-responder:run:state` memory each run, so a restart doesn't re-draft or silently skip inquiries.
