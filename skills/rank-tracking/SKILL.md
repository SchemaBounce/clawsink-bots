---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: rank-tracking
  displayName: "Rank Tracking"
  version: "1.0.0"
  description: "Snapshots Google SERP positions for target keywords via the DataForSEO MCP, persists them as seo_rank_snapshot records, computes position deltas against prior snapshots, and files seo_findings on significant movements (wins and drops)."
  tags: ["seo", "rank-tracking", "serp", "dataforseo", "keyword-positions", "position-monitoring"]
  author: "schemabounce"
  license: "MIT"
# Implementation approach: rank tracking is SERP position snapshots + delta analysis.
# No dedicated rank-tracking MCP is used because:
#   1. The DataForSEO MCP we already have exposes serp_google_organic_live and
#      serp_google_organic_task_post — sufficient for live SERP snapshots.
#   2. Purpose-built rank-tracking SaaS tools (SE Ranking, Semrush, Ahrefs) offer
#      hosted remote MCP endpoints but are customer-supplied BYO-remote connections,
#      not subprocess-hosted catalog entries (same pattern as Ahrefs/Semrush in the
#      dataforseo SERVER.md). Customers who already have SE Ranking can add it as a
#      BYO-remote custom MCP in their workspace settings.
#   3. DataForSEO serp_google_organic_live returns real-time SERP data sufficient
#      for daily/weekly position snapshots at the keyword level.
# Required: tools/dataforseo MCP must be connected for the DataForSEO tools to work.
# Graceful fallback: if DataForSEO is absent the skill emits a seo_finding and stops.
tools:
  required: ["adl_query_records", "adl_upsert_record", "adl_read_memory", "adl_write_memory", "adl_send_message"]
data:
  producesEntityTypes: ["seo_rank_snapshot", "seo_findings"]
  consumesEntityTypes: ["seo_keyword_opportunity"]
---
# Rank Tracking

Tracks keyword SERP positions over time using DataForSEO SERP snapshots. Computes position deltas, flags significant wins and drops, and alerts the executive-assistant on major movements.

## Why DataForSEO, Not a Dedicated Rank-Tracking MCP

Dedicated rank-tracking platforms (SE Ranking, Semrush Position Tracking, Ahrefs Rank Tracker) are SaaS dashboards that expose MCP endpoints as customer-supplied remote servers — identical in pattern to Ahrefs and Semrush in the dataforseo manifest's BYO-Remote Alternatives section. They are not subprocess-hosted catalog entries and require a separate paid subscription.

The DataForSEO MCP already connected to the seo-expert bot exposes `serp_google_organic_live`, which returns real-time SERP data for any keyword. Running it on a schedule and persisting the position to `seo_rank_snapshot` records produces a rank-tracking timeline at zero additional cost. This is the honest, real path.

Customers who have an existing SE Ranking account can add `https://api.seranking.com/mcp` as a BYO-remote custom MCP connection in workspace settings — it exposes 160+ rank-tracking and SEO tools including historical position data and project-based keyword tracking.

## Data Schema

`seo_rank_snapshot` entity fields:

| Field | Type | Description |
|-------|------|-------------|
| `keyword` | string | The tracked keyword |
| `domain` | string | The workspace domain (e.g., schemabounce.com) |
| `position` | int | SERP position (1–100; 0 = not found in top 100) |
| `url` | string | The ranking URL for the domain |
| `title` | string | The page title as seen in the SERP |
| `run_at` | timestamp | When the snapshot was taken |
| `location_code` | int | DataForSEO location code (2840 = US) |

## Movement Thresholds

| Delta | Direction | Action |
|-------|-----------|--------|
| +3 or more positions | Win (improved) | `seo_findings` severity=`info`, metric=`rank_win` |
| -3 or more positions | Drop | `seo_findings` severity=`warning`, metric=`rank_drop` |
| +10 or more positions | Major win | Also `adl_send_message` to executive-assistant |
| -10 or more positions | Major drop | Also `adl_send_message` to executive-assistant |
