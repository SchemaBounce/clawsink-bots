# Data Access

- Query `design_briefs`: `adl_query_records`, filter by status (open, in_progress) and platform; a brief carries outcome, audience, platform, pages in scope, brand assets
- Query `design_tokens`: `adl_query_records`, filter by brand; reuse the active set before proposing changes
- Query `brand_voice`, `product_catalog`, `mkt_content`: `adl_query_records`, read before writing copy; never write them
- Write `design_tokens`: `adl_upsert_record`, ID format `tokens_{brand}_{version}`, fields brand, mode_light, mode_dark, type_scale, spacing, contrast_report, renders
- Write `design_deliverables`: `adl_upsert_record`, ID format `design_{brief_id}_{page}`, fields page, outcome, sections, copy, forms, variants, tokens_ref, platform_targets, checklist, publish_status, published_url
- Write `design_findings`: `adl_upsert_record`, ID format `finding_{url_hash}_{criterion}`, fields url, criterion, severity, location, measured, fix

# Memory Usage

- `design_state`: `last_run`, `active_tokens`, `pending_approvals`; `adl_read_memory` at start, `adl_write_memory` at the end of every run
- `platform_quirks`: per-platform limits and failed patterns; read before publishing, write after any platform error

# Live page audit

- `adl_proxy_call` GET on the page named in the brief (read-only, bounded); the markup feeds the accessibility and vitals audit. Never POST.

# MCP Server Tools

## wix (tools/wix, Wix's hosted MCP)

- Tools are served by Wix and discovered at session start: sites, pages and sections, site styles, media, stores and bookings content.
- Flow: read the site structure, create the page or section as a draft, apply the token set to site styles, show the result, then the gated publish call. The approval in the Inbox releases it.

## wordpress (tools/wordpress, Automattic's proxy to the site's MCP Adapter)

- Tools come from the site's adapter: posts, pages, media, taxonomies, settings, and whatever abilities its plugins register.
- Flow: upload media, create the page or post with status draft, write theme.json values or the Customizer CSS the theme supports, show the result, then the gated publish (status publish). The approval releases it.
- One dedicated WordPress user per connection, so the site's revision history says which changes the designer made.

## squarespace (no connection: Squarespace has no page or content API)

- The pack is written into the `design_deliverables` record (fields `site_styles`, `custom_css`, `code_blocks`, `placement_guide`) with `adl_upsert_record`. `adl_write_file` may add a downloadable copy to Files; a failed file write never replaces the record.
- The deliverable is a pack: Site Styles values (fonts, colors, spacing) mapped from the tokens, a Custom CSS block, Code Block HTML for sections the editor cannot express, and a numbered placement guide (Design -> Site Styles, Pages -> Section -> Code).
- A person applies it. Afterwards, `adl_proxy_call` the live page and file findings on anything that did not land.

## code-sandbox (tools/code-sandbox, repository sites)

1. `code_session_create`: repo, base branch, the deliverable as the prompt (tokens, layout, copy, checklist), `engine` claude-code
2. `code_session_status`: poll until the session leaves running
3. `code_session_diff`: confirm the change matches the deliverable and the token set
4. `code_session_push`: push to a feature branch; the push escalates to the Inbox and waits for the approval
5. `code_session_result`: record files changed and test output on the deliverable
