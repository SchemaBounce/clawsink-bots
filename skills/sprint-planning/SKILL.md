---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: sprint-planning
  displayName: "Sprint Planning"
  version: "1.0.0"
  description: "Prioritizes backlog items, estimates effort, and generates sprint plans."
  tags: ["project-management", "agile", "planning", "sprints"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_send_message"]
data:
  producesEntityTypes: ["sprint_plans", "priority_recommendations"]
  consumesEntityTypes: ["tasks", "stories", "bugs", "velocity_metrics"]
---
# Sprint Planning

Analyzes backlog items, estimates effort based on historical velocity, and generates prioritized sprint plans.
