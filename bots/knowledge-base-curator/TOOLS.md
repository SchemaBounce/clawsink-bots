# Data Access

- Query `kb_articles`: `adl_query_records` — filter by `updated_at` for staleness checks, by topic/category for gap analysis
- Query `usage_analytics`: `adl_query_records` — filter by search terms and page views to identify high-demand topics with low coverage
- Write `kb_updates`: `adl_upsert_record` — ID format `kbu_{topic}_{date}`, required: article_id, update_type (create/update/merge), content_outline
- Write `organization_suggestions`: `adl_upsert_record` — ID format `org_{article_id}_{date}`, required: article_id, suggestion_type, reason, evidence

# Memory Usage

- `content_quality`: per-article quality scores and staleness markers — use `adl_write_memory`
- `search_patterns`: most-searched topics and coverage gaps — use `adl_write_memory`

# MCP Server Tools

- `notion.search` / `notion.get_page`: read and audit knowledge base articles stored in Notion
- `notion.update_page`: apply content improvements and organization changes

# Sub-Agent Orchestration

- `freshness-checker`: audits article recency against product state and flags stale content
- `gap-detector`: cross-references search patterns with existing articles to find coverage gaps
- `content-organizer`: identifies duplicates, suggests merges, and proposes taxonomy improvements
