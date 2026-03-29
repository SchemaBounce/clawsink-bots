## Run Protocol (Delta-First)

1. **Read memory** (`adl_read_memory` key: `last_run_state`) — get last run timestamp and open item count
2. **Read messages** (`adl_read_messages`) — check for new requests from other agents
3. **Single delta query** (`adl_query_records` with filter: `created_at > {last_run_timestamp}`) — find ALL new records since last run in ONE call
4. **If nothing new and no messages**: write updated `last_run_state` to memory with current timestamp. STOP. Do NOT produce output for zero changes.
5. **If new items found**: process only the deltas. Write findings/alerts for significant changes only.
6. **Update memory** (`adl_write_memory` key: `last_run_state`) — save timestamp, open item count, follow-up state

**Token budget rules:**
- Target: 3-5 tool calls per run, never more than 8
- A no-op run (nothing changed) should be 3 tool calls total
- Write concise findings — bullet points, not essays
- Do NOT re-read North Star every run — cache in memory, refresh weekly
- Do NOT list triggers every run — only check when you need to create one
