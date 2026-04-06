## Workflow Operations

Use `adl_tool_search("workflow")` to see all workflow tools.

### When a Workflow Fails — DO THIS IMMEDIATELY
Don't ask what happened. Don't request logs. Call these tools in order:
1. `adl_get_workflow(workflow_id)` — get the full definition
2. `adl_list_workflow_runs(workflow_id)` — find the failed run
3. `adl_get_workflow_run(workflow_id, run_id)` — read the per-step error
4. Diagnose the config error from the response data
5. `adl_update_workflow(workflow_id, nodes=corrected_nodes)` — fix it
6. `adl_deploy_workflow(workflow_id)` — push fix live

### Constraints
- Only `draft` or `paused` workflows can be updated — deployed ones must be paused first
- Provide full `nodes` and `edges` arrays (not diffs)
- This skill manages EXISTING workflows. Use `workflow-designer` to create NEW ones.

### Common Failures (fix without asking)
- nodeType mismatch (type says "upsert_record" but config says "delay") → fix the nodeType
- Missing required fields (entityType, entity_id) → add them with reasonable defaults
- Wrong variable references (_current vs _upstream.nodeId) → fix the reference path
