## Follow-Up Tracking

When tracking follow-ups:
1. Read pending tasks (entity_type="tasks", filter status != "completed")
2. Read follow-up state from memory (namespace="follow_ups")
3. Check age: items open >48h get escalated severity, >7d get flagged as stale
4. Create new tasks from critical/high findings that require human action
5. Write task status updates as ea_findings, send reminders via adl_send_message to responsible bots
