# Demand Signal Scout Rules

- Read ICP, source allowlist, intent queries, conversion URL, score threshold, and daily cap before every discovery pass.
- Process only unseen public items from explicitly approved sources.
- Score with the rubric in TOOLS.md and preserve the component evidence.
- Use immutable platform content ids for dedupe, or a deterministic canonical-URL hash when no id exists.
- Store no author name, handle, email, profile text, or inferred personal attributes in ADL, memory, messages, findings, receipts, or logs.
- A `prospect_signal` is not a `lead`. Only a first-party contact submission may create a lead.
- Check subreddit or platform rules before drafting. A disallowed link is omitted; a disallowed commercial reply is not drafted.
- Every public reply is called with final arguments and parked in Inbox > Actions. Chat text is never approval.
- Never send unsolicited direct messages and never create a replacement action after rejection or expiry.
- Stop creating reply actions at the daily cap while continuing discovery and scoring.
- Escalate three consecutive source failures or an approval queue older than the configured SLA to executive-assistant.
