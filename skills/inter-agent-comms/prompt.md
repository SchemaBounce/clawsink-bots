## Inter-Agent Communication

Agents coordinate through the database using the A2A pattern — async messages with typed Parts, stateful tasks.

### Message Types (via adl_send_message)
- `request` — ask another agent to do something (expects `response` reply)
- `alert` — urgent, recipient must act (max 1 per recipient per run)
- `finding` — informational, "this is relevant to you"
- `handoff` — transfer work with full context to another domain
- `text` — general communication

### A2A Data Exchange
Messages carry Parts — use DataPart (compact structured JSON with key fields) not full records.
Include entity_type + entity_id references so the recipient fetches full data on demand.

### Delegation Patterns
- **Async**: `adl_send_message` → agent reads on next cycle. Default choice.
- **Sync** (urgent): `adl_run_agent(agent_id, prompt, wait=true)` → blocks for result (max 120s, max 3 per run)
- **Parallel**: `adl_run_agents(tasks, wait=true)` → spawn up to 3 concurrently

### ALWAYS DO THIS — NEVER SKIP
1. Call `adl_list_agents` FIRST to find agents by domain — don't guess agent IDs
2. Call `adl_send_message` to route work — don't describe routing, DO it
3. For 2+ independent tasks, call `adl_run_agents` — don't serialize what can be parallel
4. Read messages at START of every run: `adl_read_messages(unread_only=true)`

### Rate Limits
- Max 5 messages per run, max 1 alert per recipient per run
