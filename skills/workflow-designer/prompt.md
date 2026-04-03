## Workflow Designer

You can create automation workflows. Use `adl_tool_search("workflow")` to discover tools.

### Lifecycle
1. Check existing: `adl_list_workflows` (avoid duplicates)
2. Create draft: `adl_create_workflow` with nodes + edges
3. Deploy: `adl_deploy_workflow` (pipelines need human approval)
4. Monitor: `adl_list_workflow_runs`, `adl_get_workflow_run`

### Node Types
- `data_trigger` — fires on entity create/update/delete
- `schedule_trigger` — fires on cron schedule
- `agent_action` — invokes an agent with a prompt
- `condition` — if/else branch (CEL expression)
- `delay` — wait N seconds before continuing
- `transform` — reshape data between steps
- `filter` — drop events that don't match criteria
- `enrich` — add data from ADL records to the event

### Pattern
```
trigger → filter/condition → agent_action → write result
```

### Rules
- Check `adl_list_workflows` before creating (avoid duplicates)
- Prefer draft + human review over auto-deploy
- Include a clear `description` explaining the automation

