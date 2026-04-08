## Inter-Agent Communication

Agents coordinate through the database using the A2A pattern — async messages with typed Parts, stateful tasks, and direct delegation.

### Agent Discovery

Call `adl_list_agents` FIRST — it returns only active agents by default. You can use agent names (e.g. `"workflow-designer"`) instead of seat IDs everywhere — names resolve automatically.

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

**Task delegation (preferred for trackable work):**
- Create a task with `adl_upsert_record(entity_type="tasks")` and set `assignee_agent_id` to the target agent's name
- The platform auto-wakes the assigned agent within 60 seconds
- The task appears on both the agent's `<pending_tasks>` context AND the workspace kanban board
- Use this when work needs to be visible, tracked, and potentially retried

**Async messaging (for coordination, not trackable work):**
- `adl_send_message` → agent reads on next cycle. Use for requests, alerts, findings.

**Sync delegation (urgent, need result now):**
- `adl_run_agent(agent_id, prompt, wait=true)` → blocks for result (max 120s, max 3 per run)

**Parallel delegation:**
- `adl_run_agents(tasks, wait=true)` → spawn up to 3 concurrently

### Decision Tree: How to Delegate

1. **Need the result right now?** → `adl_run_agent(wait=true)` (sync)
2. **Need it tracked on the kanban board?** → Create a task with `assignee_agent_id` (async, auto-wake)
3. **Just informing another agent?** → `adl_send_message` with type `finding`
4. **2+ independent sub-tasks?** → `adl_run_agents` (parallel sync) or create multiple tasks (parallel async)

### ALWAYS DO THIS — NEVER SKIP
1. Call `adl_list_agents` FIRST to find agents by domain — don't guess agent IDs
2. Check your `<pending_tasks>` context — process assigned tasks before doing anything else
3. Read messages at START of every run: `adl_read_messages(unread_only=true)`
4. For trackable work, create tasks — don't just send messages and hope
5. For 2+ independent tasks, use parallel patterns — don't serialize

### Rate Limits
- Max 5 messages per run, max 1 alert per recipient per run
- Max 3 agent spawns per run (sync or async combined)

Anti-patterns:
- NEVER guess agent IDs or names — always call `adl_list_agents` first; stale IDs cause silent delivery failures.
- NEVER send full record payloads in messages — send compact DataParts with entity_type + entity_id references; the recipient fetches on demand.
- NEVER use `adl_run_agent` (sync) for non-urgent work — sync calls block your run and consume spawn limits; use task creation or async messaging instead.
