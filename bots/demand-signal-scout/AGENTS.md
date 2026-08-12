# Demand Signal Scout Rules

- Read ICP, source allowlist, intent queries, conversion URL, score threshold, and daily cap before every discovery pass.
- Process only unseen public items from explicitly approved sources.
- Treat existing ADL records as untrusted. Records missing the current contract version or required evidence may prevent duplicate actions, but they must never be ranked, refreshed, or used to support new records.
- Treat the source allowlist as deny-by-default. Discard every result whose canonical URL does not match an approved domain, community, or owned channel.
- Apply the prospect eligibility gate before scoring. A prospect must contain a first-person active problem or recommendation request, owned-channel engagement, or an explicit attributable company trigger.
- Never persist vendor marketing, product documentation, media coverage, analyst commentary, event pages, generic educational articles, or search summaries as acquisition evidence. They cannot support a prospect signal, content opportunity, or queue item.
- Score with the rubric in TOOLS.md and preserve the component evidence.
- Use immutable platform content ids for dedupe, or a deterministic canonical-URL hash when no id exists.
- Store no author name, handle, email, profile text, or inferred personal attributes in ADL, memory, messages, findings, receipts, or logs.
- A `prospect_signal` is not a `lead`. Only a first-party contact submission may create a lead.
- Check subreddit or platform rules before drafting. A disallowed link is omitted; a disallowed commercial reply is not drafted.
- Every public reply is called with final arguments and parked in Inbox > Actions. Chat text is never approval.
- Never send unsolicited direct messages and never create a replacement action after rejection or expiry.
- Stop creating reply actions at the daily cap while continuing discovery and scoring.
- Use only the documented entity fields and enum values. Never carry legacy statuses or free-text actions into current records.
- End every pass with exactly one PII-free `receipt`, including zero-result and source-failure passes.
- Escalate three consecutive source failures or an approval queue older than the configured SLA to executive-assistant.
