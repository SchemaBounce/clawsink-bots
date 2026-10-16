## Workflow Operations

Use `adl_tool_search("workflow")` to see all workflow tools.

### When a Workflow Fails — DO THIS IMMEDIATELY
Don't ask what happened. Don't request logs. Call these tools in order:
1. `adl_get_workflow(workflow_id)` — get the full definition
2. `adl_list_workflow_runs(workflow_id)` — find the failed run
3. `adl_get_workflow_run(workflow_id, run_id)` — each failed step carries `failure` with `class`, `code`, `message` and `fix`; the raw `error` string is the fallback
4. Diagnose from `failure.code` first, the config second
5. `adl_update_workflow(workflow_id, nodes=corrected_nodes)` — fix it
6. `adl_deploy_workflow(workflow_id)` — push the fix live (it may wait for a person's approval; say so)

### Model and provider failures (most failed runs today)
- `model_not_priced` ("model has no active pricing"): the agent's model has no price on file. Set `modelOverride` on the agent_action node (`{provider, preferred, thinkLevel, maxTokensPerCall, maxTokenBudget}`, blank fields inherit) or change the agent with `adl_propose_agent_model` (needs a person's approval).
- `provider_out_of_credits` (429, "spending cap"): the workspace's key for that provider is capped this month. `modelOverride` to a provider the workspace holds another key for.
- `provider_error` (a 400 from the provider): retry once; if it repeats, `modelOverride` the step to another model and report it.
- `unresolved_tool_error`: read which tool failed in the step result and fix the prompt's arguments against that tool's schema.
- Read the agent first: `adl_get_agent_model(agent_id)` returns its provider, model, think level and last failure.

### Constraints
- A deployed workflow can be updated in place: the edit is saved as a draft version and the deployed version keeps running until `adl_deploy_workflow` runs again (the result says `has_undeployed_changes`). Never pause just to edit; pausing removes the schedule.
- Provide full `nodes` and `edges` arrays (not diffs)
- This skill manages EXISTING workflows. Use `workflow-designer` to create NEW ones.

### Common Failures (fix without asking)
- nodeType mismatch (type says "upsert_record" but config says "delay") → fix the nodeType
- Missing required fields (entityType, entity_id) → add them with reasonable defaults
- Wrong variable references (_current vs _upstream.nodeId) → fix the reference path

Anti-patterns:
- NEVER pause a deployed workflow just to edit it — pausing removes its schedule; update in place and redeploy.
- NEVER leave an edit undeployed — after `adl_update_workflow`, call `adl_deploy_workflow`; nothing runs the edit until you do.
- NEVER send partial node/edge arrays in an update — the API replaces the full definition; missing nodes are deleted.
- NEVER diagnose a workflow failure by asking the user for logs — call `adl_get_workflow_run` immediately to read the per-step error.
