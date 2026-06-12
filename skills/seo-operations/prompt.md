## SEO Operations

Run the foundational SEO audit: keyword performance, Core Web Vitals, and on-page meta checks.

### Steps

1. `adl_read_memory(namespace="seo:audit:cache", key="sitemap_xml")` — load the sitemap URL list.
2. `adl_read_memory(namespace="seo:audit:cache", key="site_url")` — load the GSC property URL.
3. **Keyword performance (Google Search Console MCP):**
   - `query_search_analytics(site_url, dimensions=["query","page"], date_range="last_28_days")` — pull clicks, impressions, CTR, position.
   - Identify almost-ranking queries: impressions >= 100 AND position between 5 and 20 AND CTR below the run's median CTR.
   - `adl_upsert_record(entity_type="seo_keyword_opportunity")` for each: `query`, `page`, `impressions`, `ctr`, `position`, `gap_type="almost_ranking"`.
4. **Core Web Vitals (PageSpeed MCP):**
   - Run `analyze_page_speed` + `crux_summary` for the home page and up to 3 top-traffic URLs.
   - Thresholds: LCP > 2.5s (mobile) = finding; CLS > 0.1 = finding; INP > 200ms = finding; Lighthouse SEO score < 90 = finding.
   - `adl_upsert_record(entity_type="seo_findings")` for each breach: `severity`, `metric_name`, `metric_value`, `threshold`, `provider="pagespeed"`, `url`.
5. **On-page meta audit (adl_proxy_call):**
   - For up to 10 URLs from the sitemap, `adl_proxy_call(method="GET", url=<page_url>, max_response_bytes=32768)`.
   - Check: og:title present and non-empty; og:description present; twitter:card present; exactly one H1; meta description present (< 160 chars); JSON-LD block present; canonical tag present.
   - `adl_upsert_record(entity_type="seo_findings")` for each failure: `metric_name`, `url`, `severity`.
6. `adl_write_memory(namespace="seo:run:state", key="last_seo_ops_run", value={timestamp, finding_count, opportunity_count})`.

### Thresholds Reference

| Metric | Pass | File Finding |
|--------|------|-------------|
| LCP (mobile) | <= 2.5s | > 2.5s |
| CLS | <= 0.1 | > 0.1 |
| INP | <= 200ms | > 200ms |
| Lighthouse SEO | >= 90 | < 90 |
| Almost-ranking position | 5-20 AND impressions >= 100 | — |

### Anti-Patterns

- NEVER skip the GSC pull and report "no data" — if the MCP is connected, there is data. If the MCP is absent, emit a finding of severity=warning for missing GSC connection.
- NEVER report a Core Web Vitals finding without the actual metric value and threshold — vague "performance issue" findings are not actionable.
- NEVER audit meta tags by guessing — always fetch via adl_proxy_call; do not infer from memory.
