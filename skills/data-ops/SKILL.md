---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: data-ops
  displayName: "Data Operations"
  version: "1.0.0"
  description: "Full data layer toolkit, records, memory, graph, semantic search, SQL analytics, maintenance"
  tags: ["platform", "data", "analytics", "records", "memory", "graph"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_upsert_record", "adl_read_memory", "adl_write_memory", "adl_search_graph", "adl_semantic_search", "adl_query_duckdb", "adl_tool_search"]
data:
  producesEntityTypes: []
  consumesEntityTypes: []
---
# Data Operations

Full data layer toolkit covering records, memory, graph traversal, semantic search, SQL analytics, and data maintenance. Many agents only use basic record CRUD. This skill teaches the complete toolkit.

## When to Use

Invoke this skill when you need capabilities beyond basic `adl_query_records` and `adl_upsert_record`: graph traversal, semantic search, SQL analytics, memory management, or data maintenance.

## What You Get

- **Records**: CRUD with JSONB filters, bulk upsert (up to 1000)
- **Memory**: Persistent key-value store with namespace prefixes (shared:, northstar:)
- **Graph**: Entity relationship traversal (1-3 hops)
- **Search**: Semantic search via vector embeddings
- **Analytics**: SQL queries via SQL across all records
- **Maintenance**: Storage stats, stale record cleanup
