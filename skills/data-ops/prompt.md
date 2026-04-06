## Data Operations

Use `adl_tool_search` with keywords to discover tools: "records", "memory", "graph", "search", "duckdb".

### Records (structured entities)
- `adl_query_records` — filter by entity_type + JSONB fields
- `adl_upsert_record` / `adl_bulk_upsert` — create/update (batch up to 1000)
- `adl_get_record` — fetch by type+ID

### Memory (key-value per namespace)
- `adl_read_memory` / `adl_write_memory` — persistent across runs
- `adl_search_memory` — semantic search across memory entries
- Prefixes: `shared:` (all agents), `northstar:` (workspace config)

### Graph (entity relationships)
- `adl_search_graph` — find related entities by relationship type
- `adl_query_neighbors` — multi-hop traversal (1-3 hops)

### Analytics
- `adl_query_duckdb` — SQL analytics across all records (aggregations, trends)
- `adl_semantic_search` — find records by meaning (vector similarity)

### Maintenance
- `adl_get_data_stats` — storage stats per entity type
- `adl_purge_stale_records` — soft-delete old records (dry_run first!)
