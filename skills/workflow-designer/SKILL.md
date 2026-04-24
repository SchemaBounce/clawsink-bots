---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: workflow-designer
  displayName: "Workflow Designer"
  version: "1.0.0"
  description: "Create, deploy, and manage multi-step automation workflows with triggers, conditions, and agent actions."
  tags: ["workflows", "automation", "orchestration", "triggers"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_tool_search"]
data:
  producesEntityTypes: ["workflows"]
  consumesEntityTypes: []
---
# Workflow Designer

Enables agents to design and deploy multi-step automation workflows. Workflows are directed graphs of nodes (triggers, conditions, agent actions, delays) connected by edges. Agents create workflows as drafts, then deploy them for execution.

## When to Use

- User asks for recurring automation ("every time X happens, do Y")
- A business process requires multiple steps with branching logic
- Events in the data layer should trigger agent actions automatically
- Scheduled tasks need orchestration across multiple agents

## What You Get

- **8 node types**: data_trigger, schedule_trigger, agent_action, condition, delay, transform, filter, enrich
- **Lifecycle management**: draft, deploy, pause, trigger manually
- **Execution history**: view run results, per-step outputs, errors
- **Human approval gate**: workflows with pipeline sources require human sign-off before deployment
