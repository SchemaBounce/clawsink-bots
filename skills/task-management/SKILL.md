---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: task-management
  displayName: "Task Management"
  version: "1.0.0"
  description: "Create, update, query, and manage tasks on the workspace kanban board via ADL records."
  tags: ["tasks", "kanban", "project-management", "coordination"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_upsert_record", "adl_query"]
data:
  producesEntityTypes: ["tasks"]
  consumesEntityTypes: ["tasks"]
---
# Task Management

Enables agents to create, update, and query tasks stored as ADL records. Tasks appear on the workspace kanban board and can be managed by both agents and users.
