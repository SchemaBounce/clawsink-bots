# Data Access

- Query `blog_topics`: `adl_query_records` — filter by status or section (schemabounce/openclaw) to find pending topics
- Query `product_docs`: `adl_query_records` — filter by feature area for research source material
- Write `blog_drafts`: `adl_upsert_record` — ID format `draft_{section}_{date}`, required fields: title, body, section, status="draft", target_publish_date
- Write `editorial_notes`: `adl_upsert_record` — ID format `note_{topic_slug}`, attach research gaps or revision feedback

# Memory Usage

- `editorial_calendar`: scheduled topics, in-progress markers, last section written — use `adl_write_memory` to update after each run
- `writing_notes`: research outlines, draft state, revision history — use `adl_write_memory` to save progress
- `topic_research`: validated source material from researcher sub-agent — use `adl_add_memory` to append findings

# MCP Server Tools

## tools/blog (required connection)

The bot publishes via the dedicated blog connector. A workspace service account with the `blog:write` scope must be connected at activation time (see `connect-blog` setup step).

- `blog_create_draft`: create a new blog post draft — params: `title`, `description`, `content`, `section` (schemabounce|openclaw), `category`, `tags[]`. Returns `{ post_id, slug, status, section }`.
- `blog_submit_review`: move a draft to `status=review` for human approval — params: `post_id`. Never call any approve tool; there is none.
- `blog_list`: list existing posts for the workspace — useful for duplicate-topic checks before drafting.

## tools/github (recommended connection)

- `github.create_pull_request`: publish blog post drafts as PRs to the content repository
- `github.get_file_contents`: read existing blog posts to check for topic overlap

# Sub-Agent Orchestration

1. **researcher** (haiku) — validate topic feasibility, gather source material from docs and knowledge graph
2. **writer** (inherit) — draft full blog post from research brief, following editorial guidelines
3. **editor** (sonnet) — review draft for voice, accuracy, style guide adherence; return pass/fail verdict

Spawn in strict sequence: researcher -> writer -> editor. If editor fails the draft, re-spawn writer with editor feedback (max 2 revision cycles).
