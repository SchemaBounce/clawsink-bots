## Rank Tracking

SERP position snapshots via DataForSEO; delta alert on movement.

1. Load keywords: `adl_read_memory(namespace="seo:rank:state", key="target_keywords")`. If empty, seed from `adl_query_records(entity_type="seo_keyword_opportunity", limit=20)`.
2. DataForSEO absent: file `seo_findings` severity=warning metric=`rank_tracking_unavailable`; stop.
3. Per keyword (max 20): `serp_google_organic_live(keyword=<kw>, location_code=2840, language_code="en")`. Record domain position (0=not in top 100).
4. `adl_upsert_record(entity_type="seo_rank_snapshot", fields={keyword, domain, position, url, run_at})`.
5. Prior snapshot: `adl_query_records(entity_type="seo_rank_snapshot", filters={keyword=<kw>}, limit=1, order_by="run_at desc")`. Delta=prior-current. |delta|>=3: file `seo_findings` metric=`rank_win` (info) or `rank_drop` (warning). |delta|>=10: also `adl_send_message(to="executive-assistant", type="finding")`.
6. `adl_write_memory(namespace="seo:rank:state", key="last_run", value={timestamp, top_mover})`.
