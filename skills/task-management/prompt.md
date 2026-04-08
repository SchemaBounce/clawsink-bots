## Task Management via ADL Records

Entity type: `tasks`

### How Tasks Work

Tasks are stored as ADL records and visible on the workspace kanban board at `/agent-data-layer/task-board`. Both agents and humans can create, assign, and complete tasks.

**Platform features (automatic, no action needed):**
- When you run, your `<pending_tasks>` context block shows all tasks assigned to you — you don't need to query for them.
- Setting `assignee_agent_id` on a task auto-wakes the assigned agent within 60 seconds.
- Agent names work as IDs — you can assign to `"workflow-designer"` instead of `"seat_5022a23e"`.

### Creating a Task

Use the `adl_upsert_record` tool:

- `entity_type`: `"tasks"`
- `entity_id`: Generate as `task_{short_description}` (readable, unique)
- `data` fields:
  - `title` (required): Short task title
  - `description`: Detailed description of work needed
  - `status` (required): One of `"pending"`, `"in_progress"`, `"completed"`, `"blocked"`
  - `priority`: One of `"low"`, `"medium"`, `"high"`, `"critical"` (default: `"medium"`)
  - `assignee_agent_id`: Agent name or ID to assign to (auto-wakes the agent)
  - `created_by_agent`: Your agent name or ID
  - `acceptance_criteria`: How to know the task is done
  - `due_date`: ISO 8601 date string (e.g. `"2026-03-20"`)

### Updating Task Status

Use `adl_upsert_record` with the existing `entity_id`:

- `entity_type`: `"tasks"`
- `entity_id`: The existing task ID
- `data`: Full task data with the updated `status` field

### Querying Tasks

Use the `adl_query_records` tool:

- `entity_type`: `"tasks"`
- Filter examples:
  - All pending: `filters: { "status": "pending" }`
  - Assigned to you: `filters: { "assignee_agent_id": "<your-agent-id>" }`
  - High priority: `filters: { "priority": "high" }`

### Task Lifecycle

1. **Create** with `status: "pending"` and `assignee_agent_id` — the assigned agent wakes automatically
2. **Start work** — set `status: "in_progress"` before beginning
3. **Complete** — set `status: "completed"` when acceptance criteria are met
4. **Block** — set `status: "blocked"` and `blocked_reason` when waiting on input
5. **Escalate** — if blocked for >24h, use `adl_request_escalation` to notify a human

### Rules

- Check your `<pending_tasks>` context at the start of every run — process tasks by priority
- Always update task status — don't leave tasks in "pending" while you work on them
- Write clear titles and descriptions — other agents and humans read the kanban board
- If a task is beyond your capabilities, set `status: "blocked"` with a clear reason

Anti-patterns:
- NEVER leave a task in "pending" while actively working on it — set status to "in_progress" immediately when you start.
- NEVER assign a task without clear acceptance criteria — vague tasks cannot be verified as complete.
- NEVER create tasks with generic IDs like "task_1" — use descriptive IDs (e.g., "task_fix_billing_sync") so the kanban board is readable.
