# Data Access

- Query `tasks`: `adl_query_records`. One call per open status (`pending`, `assigned`, `in_progress`, `blocked`), sorted by `updated_at`, to find unowned and stalled work.
- Write `tasks`: `adl_upsert_record`. Task writes merge: send only `assignee_agent_id`, `status` and `note`. Never send `status: "completed"` or `"cancelled"` for another agent's task.
- Create `tasks`: `adl_create_tasks`, up to 25 per call, each with `assignee`, `priority`, and `goal_id` when it serves a goal.
- Write `cos_scorecards`: `adl_upsert_record`. ID format `cos_{YYYY-MM-DD}_{HHMM}`, required: completed_since_last_run, created_since_last_run, open_by_status, stalled_found, stalled_without_action, actions, person_list.

# What Needs Attention

- Load it first: `adl_tool_search` query `workspace attention`. It is search-only (most agents never need it), so it joins your tool list on the turn after the search.
- `adl_workspace_attention` (window `24h`, `7d` or `30d`): failed runs grouped by failure class (budget stops, tool failures, setup, platform), approvals waiting on a person, schedules the runtime paused, agents blocked in setup, connections that need attention. Each item has a severity, a count, the subject id (run, agent or connection) and the console link the person needs. Read-only.
- Use it for the person list and to pick owners: a paused or disabled agent gets no new work; an agent blocked in setup still takes work that does not need the missing connection.

# Waking Agents

- **Assignment wakes the owner.** Setting `assignee_agent_id` with `status: "assigned"` starts that agent on the task within seconds. `status: "pending"` waits for a 30 second poll that starts at most 5 tasks per cycle.
- **A message does not wake anyone.** `adl_send_message` is read on the agent's next run. Use it for a question, not to start work.
- **Direct start.** `adl_run_agent` with the agent_id and a prompt naming the task key and next step. Asks for approval unless the workspace allows it for this agent. Spends credits.

# Memory Usage

- `working_notes`: this run's findings while the run is in progress
- `stall_history`: task key to how many times it was restarted and when, so a second stall moves the task instead of restarting it again
- `learned_patterns`: which agents finish which kinds of work, used to pick owners
