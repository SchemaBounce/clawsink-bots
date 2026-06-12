## GEO / AEO

Measure AI citation visibility and apply GEO tactics. Foundational SEO is the base; GEO tactics amplify good content, they do not substitute for it.

### Part A — Measure AI Citation Share-of-Voice

1. `adl_read_memory(namespace="seo:audit:cache", key="brand_queries")` — load the list of 5-10 brand and category queries (e.g., "real-time CDC platform", "schemabounce vs fivetran").
2. If the AI Citation Tracker MCP (`research.ai_citation.check`) is connected:
   - For each query, call `research.ai_citation.check(domain="schemabounce.com", query=<q>, engines=["chatgpt","claude","perplexity"])`.
   - Call `research.ai_citation.share_of_voice(domain="schemabounce.com", queries=[...])` for an aggregate score.
   - Call `research.ai_citation.history(domain="schemabounce.com", queries=[...])` to compute run-over-run delta.
   - `adl_upsert_record(entity_type="seo_geo_citation")` per result: `query`, `engine`, `status` (cited/mentioned/absent), `share_of_voice`, `delta`, `run_at`.
   - If share-of-voice drops > 5 points versus previous run: `adl_upsert_record(entity_type="seo_findings", severity="info", metric_name="geo_citation_drop", metric_value=<delta>, suggested_fix=<content action — NOT an AI-specific hack>)`.
3. If the MCP is NOT connected (no API key or connection absent):
   - Emit one `seo_finding` severity=info noting that GEO citation measurement is unavailable; suggested_fix = "Connect tools/ai-citation-tracker with a CitationBench API key."
   - Continue to Part B.

### Part B — llms.txt Drafting

4. If the llms.txt Generator MCP (`generate-llms`) is connected:
   - Call `generate-llms` to produce llms.txt and llms-full.txt drafts for schemabounce.com.
   - `adl_read_memory(namespace="seo:run:state", key="last_llms_txt_sha")` to retrieve the SHA of the previously approved draft (if any).
   - Compute a diff summary (sections added, removed, changed).
   - `adl_upsert_record(entity_type="seo_llms_txt_draft", fields={draft_content, diff_summary, requires_human_review=true, generated_at})`.
   - `adl_send_message(to="executive-assistant", type="finding", body="llms.txt draft ready for review before publishing to schemabounce.com/llms.txt")`.
5. If the MCP is NOT connected:
   - Emit one `seo_finding` severity=info: "llms.txt draft generation unavailable — connect tools/llms-txt-generator to enable this GEO tactic."

### Part C — GEO Content Recommendations

6. `adl_query_records(entity_type="seo_keyword_opportunity", filters={gap_type="almost_ranking"}, limit=10)` — load almost-ranking queries from the SEO Operations run.
7. For each query, evaluate whether the target page:
   - Has a clear, direct answer to the query in the first two paragraphs (answer-engine-friendly structure).
   - Names the entity (SchemaBounce) explicitly in the first paragraph (entity clarity).
   - Contains at least one Q&A-formatted section (explicit question + direct answer prose).
   - Defines key terms that appear in the query (reduces ambiguity for LLM extractors).
8. For each gap found, `adl_upsert_record(entity_type="seo_findings", severity="low", metric_name=<gap_type>, url=<page>, suggested_fix=<specific content edit — one sentence, concrete>)`.
9. `adl_write_memory(namespace="seo:run:state", key="last_geo_run", value={timestamp, citation_score, llms_txt_draft_id, content_gaps_found})`.

### What Is a GEO Tactic vs. Foundational SEO

| Foundational SEO (always applies) | GEO tactic (amplifies good content) |
|-----------------------------------|--------------------------------------|
| E-E-A-T: original, expert content | llms.txt: structured AI-readable index |
| Technical health: crawlable, fast, valid schema | Entity clarity: name the product in context explicitly |
| Almost-ranking optimization: match search intent | Q&A formatting: answer the question before elaborating |
| Core Web Vitals | Citation measurement: track share-of-voice per engine |

GEO does not replace foundational SEO. When share-of-voice is low, the root fix is almost always a foundational content quality issue, not a missing llms.txt.

### Anti-Patterns

- NEVER suggest "AI-specific keyword phrasing" — AI engines understand synonyms.
- NEVER treat a low citation score as proof of a GEO problem without checking the foundational signals first (thin content, blocked crawl, no schema).
- NEVER publish a llms.txt draft directly — always route through the human review step (`requires_human_review=true`).
- NEVER emit more than one seo_finding per issue per run — dedup by metric_name + url.
