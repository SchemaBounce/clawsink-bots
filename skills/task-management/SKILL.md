---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: task-management
  displayName: "Task Management"
  version: "2.0.0"
  description: "Create, assign, and track tasks on the workspace kanban board. Assigned tasks auto-wake the target agent."
  tags: ["tasks", "kanban", "project-management", "coordination", "delegation"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_upsert_record", "adl_query_records", "adl_list_agents"]
data:
  producesEntityTypes: ["tasks"]
  consumesEntityTypes: ["tasks"]
---
# Task Management

Enables agents to create, assign, and track tasks on the workspace kanban board. Tasks are stored as ADL records and visible to both agents and humans. Setting `assignee_agent_id` on a task auto-wakes the assigned agent — no cron or manual trigger needed.
