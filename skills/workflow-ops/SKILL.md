---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: workflow-ops
  displayName: "Workflow Operations"
  version: "1.0.0"
  description: "Inspect, troubleshoot, and fix deployed workflows — diagnose failures, update nodes, redeploy"
  tags: ["platform", "workflow", "operations", "troubleshooting"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_list_workflows", "adl_get_workflow", "adl_update_workflow", "adl_deploy_workflow", "adl_list_workflow_runs", "adl_get_workflow_run"]
data:
  producesEntityTypes: []
  consumesEntityTypes: []
---
# Workflow Operations

Inspect, troubleshoot, and fix existing workflows. Complements the `workflow-designer` skill which creates NEW workflows — this skill manages workflows that are already deployed.

## When to Use

Invoke this skill when a workflow is failing, misconfigured, or needs operational attention. Use `workflow-designer` when you need to create a brand new workflow from scratch.

## What You Get

- **Workflow inspection**: List workflows, get full definitions, view run history
- **Failure diagnosis**: Identify node misconfigurations, missing fields, wrong variable references
- **Live fixes**: Update workflow nodes/edges and redeploy
- **Common failure patterns**: nodeType mismatches, missing entityType, wrong _upstream references
