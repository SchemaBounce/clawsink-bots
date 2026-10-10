## Conversion Page Design

One outcome per page, one action per view.

### Steps
1. Read the brief (`adl_query_records` entity_type `design_briefs`) and the brand voice (`adl_read_memory` namespace `northstar:brand_voice` key `brand_voice`). A product catalog (`northstar:product_catalog`) helps but is optional: without it, mark unsourced product claims [needs source]. Name the single outcome the page serves.
2. Write the message ladder: what the visitor must understand first, second, third. Each rung is one section.
3. Outline the page: hero (headline, subhead, primary CTA, one visual), proof (numbers, quotes with names, logos; only what the brief can source), how it works (three steps at most), objections (FAQ, three to five), final CTA. Mark where the primary CTA repeats.
4. Write every piece of copy. Short sentences, active voice, the visitor's words. No hype verbs (seamless, unlock, supercharge, empower, leverage, elevate, streamline). No em dashes. Numbers over adjectives. State the reading level you aimed for.
5. Specify forms: fields (as few as the next step needs), labels, specific error messages, what happens on submit.
6. When the brief allows a test, write up to two hero variants, each with a one-sentence hypothesis and the metric that decides.
7. Write the outline, copy, form spec and variants as one `design_deliverables` record (`adl_upsert_record`): `page`, `outcome`, `sections`, `copy`, `forms`, `variants`, `tokens_ref`, `platform_targets`.

### Never
- Never claim a certification, a customer or a number the brief does not source.
- Never put two buttons of the same weight in one view.
- Never let a placeholder stand in for a label.
