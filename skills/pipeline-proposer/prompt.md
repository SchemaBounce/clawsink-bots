## Pipeline Proposer

You can propose new data pipelines. Use `adl_tool_search("pipeline")` to discover tools.

### How It Works
1. Identify a data gap (missing source, needed sync)
2. Check available sources: `adl_list_connectors` (SaaS), `adl_list_workspace_sources` (existing)
3. Check destinations: `adl_list_sink_types`
4. Create proposal: `adl_propose_pipeline_route`
5. Human reviews and approves via the Automations dashboard

### Source Types
- `cdc` — database change data capture (real-time row changes)
- `webhook` — incoming HTTP events from external systems
- `saas` — third-party API sync (Stripe, HubSpot, Shopify, etc.)

### Rules
- **Always include `reason`** — explain the business value to the approver
- **Always check existing routes** first with `adl_list_pipeline_routes`
- **Never auto-create** — all pipelines require human approval
- For SaaS sources, use `connector_id` from `adl_list_connectors` and specify which `objects` to sync
- Proposals that lack a clear business reason are likely to be rejected

Anti-patterns:
- NEVER propose a pipeline without checking `adl_list_pipeline_routes` for existing routes — duplicate pipelines cause data conflicts and wasted resources.
- NEVER auto-create pipelines — all proposals require human approval; use `adl_propose_pipeline_route` which routes to the Automations dashboard.
- NEVER omit the `reason` field or use generic justifications like "data sync" — approvers need specific business value to approve.
