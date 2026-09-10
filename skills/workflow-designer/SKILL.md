---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: workflow-designer
  displayName: "Workflow Designer"
  version: "1.1.0"
  description: "Create, deploy, and manage multi-step automation workflows with triggers, conditions, and agent actions."
  tags: ["workflows", "automation", "orchestration", "triggers"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_tool_search"]
data:
  producesEntityTypes: ["workflow"]
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
- **Human approval gate**: EVERY deployment requires human sign-off. `adl_deploy_workflow` parks pending approval and the workflow stays a draft until a human approves it. Never report a workflow as deployed because you called that tool.
- **Validated on create**: a graph whose edges do not resolve, or whose agent nodes have no prompt, is rejected with a message naming the problem. Fix and retry rather than storing it.
