## Follow-Up Tracking

When tracking follow-ups:
1. Read pending tasks (entity_type="tasks", filter status != "completed")
2. Read follow-up state from memory (namespace="follow_ups")
3. Check age: items open >48h get escalated severity, >7d get flagged as stale
4. Create new tasks from critical/high findings that require human action
5. Write task status updates as ea_findings, send reminders via adl_send_message to responsible bots

Anti-patterns:
- NEVER close a follow-up without confirming the action was taken — check the task status or outcome record before marking complete.
- NEVER send duplicate reminders for the same item in the same run — check follow-up state from memory before messaging.
- NEVER escalate without including the original task context (who, what, when created) — escalation recipients need full history to act.
