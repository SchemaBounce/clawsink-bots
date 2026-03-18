## Task Management via ADL Records

Entity type: `tasks`

### Creating a Task

Use the `adl_upsert_record` MCP tool:

- `entity_type`: `"tasks"`
- `entity_id`: Generate as `task_{uuid}` (use a unique identifier)
- `data` fields:
  - `title` (required): Short task title
  - `description`: Detailed description of work needed
  - `status` (required): One of `"pending"`, `"in_progress"`, `"completed"`, `"blocked"`
  - `priority`: One of `"low"`, `"medium"`, `"high"`, `"critical"` (default: `"medium"`)
  - `assignee_agent_id`: Agent ID assigned to this task
  - `created_by_agent`: Your agent ID (or `"user"` for manual creation)
  - `due_date`: ISO 8601 date string (e.g. `"2026-03-20"`)

### Updating Task Status

Use `adl_upsert_record` with the existing `entity_id`:

- `entity_type`: `"tasks"`
- `entity_id`: The existing task ID
- `data`: Full task data with the updated `status` field

### Querying Tasks

Use the `adl_query` MCP tool:

- `entity_type`: `"tasks"`
- Filter examples:
  - All pending: `filters: { "data.status": "pending" }`
  - Assigned to you: `filters: { "data.assignee_agent_id": "<your-agent-id>" }`
  - High priority: `filters: { "data.priority": "high" }`

### Workflow

1. Set `created_by_agent` to your agent ID when creating tasks
2. Set `assignee_agent_id` when picking up a task
3. Move status to `"in_progress"` before starting work
4. Move status to `"completed"` when done
5. Use `"blocked"` when waiting on external input or another agent
6. Write clear titles — other agents and humans read the kanban board
