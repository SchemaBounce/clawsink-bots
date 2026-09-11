## Workflow Designer

You can create automation workflows. Use `adl_tool_search("workflow")` to discover tools.

### The graph contract, read this before you build one

A workflow is nodes plus edges. Getting these four things wrong produces a
workflow that stores fine, deploys, fires on schedule, and does nothing.

1. **Give every node an `id` you choose, and make edges reference that `id`.**
   Never reference a node by its `label`. A label-keyed edge does not connect
   anything: the engine builds its adjacency from `edge.source`, then looks the
   trigger up by node id, finds no match, and produces an empty execution plan.
2. **Every `agent_action` needs `prompt_template` in its config.** The `label`
   is not an instruction. A node with no prompt invokes the agent with nothing
   to do.
3. **`source_handle` belongs ONLY on edges leaving a `condition` node**, where
   it is `"true"` or `"false"`. Putting it on an edge out of a trigger is
   meaningless noise.
4. **Give nodes distinct `position` values** or they stack on one point in the
   builder and a human cannot read the graph.

Minimum shape that actually runs:

```json
{
  "nodes": [
    {"id": "trigger", "type": "schedule_trigger", "label": "Monthly on the 1st",
     "position": {"x": 0, "y": 0},
     "config": {"cron": "0 9 1 * *", "timezone": "Asia/Tokyo"}},
    {"id": "write", "type": "agent_action", "label": "Draft the recap",
     "position": {"x": 260, "y": 0},
     "config": {"agent_id": "blog-writer",
                "prompt_template": "Summarise last month's published posts. Return a 200 word recap."}}
  ],
  "edges": [{"id": "e1", "source": "trigger", "target": "write"}]
}
```

Note `source` and `target` are `"trigger"` and `"write"`, the node ids, not the
labels.

### Lifecycle

1. Check existing: `adl_list_workflows` (avoid duplicates)
2. Create draft: `adl_create_workflow` with nodes + edges. It is validated
   before it is stored. If it comes back an error, the message names the exact
   problem: fix it and call again rather than moving on.
3. Request deployment: `adl_deploy_workflow`. **This always requires human
   approval.** The call parks pending that approval and the workflow stays a
   DRAFT until a human approves it.
4. Monitor: `adl_list_workflow_runs`, `adl_get_workflow_run`

### Node Types

- `data_trigger` — fires on entity create/update/delete
- `schedule_trigger` — fires on cron schedule
- `agent_action` — invokes an agent with a prompt
- `condition` — if/else branch, predicate goes in `expression`
- `delay` — wait before continuing
- `transform` — reshape data between steps
- `filter` — drop events that don't match criteria
- `enrich` — add data from ADL records to the event

### Pattern

```
trigger → filter/condition → agent_action → write result
```

### Rules

- Check `adl_list_workflows` before creating. Duplicate workflows fire
  duplicate actions.
- Include a clear `description` explaining the automation.
- Deployment is a human's decision, not yours. Ask for it and report honestly
  that it is pending.

Anti-patterns:

- **NEVER report a workflow as deployed, active, or live because you called
  `adl_deploy_workflow`.** The call requests approval. Until a human approves,
  the workflow is a draft that has never run. Saying otherwise tells your
  operator something untrue about their platform.
- **NEVER reference a node by its label in an edge.** Use the node id.
- **NEVER leave an `agent_action` without a `prompt_template`.** The label is
  a caption for humans, not an instruction for the agent.
- NEVER create a workflow without checking `adl_list_workflows` first.
- NEVER create a workflow without a trigger node. Triggerless workflows never
  execute.
