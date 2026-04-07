## Data Dependency Discovery

At the start of each discovery run, assess your own data health:

1. List your declared data needs from your config (entityTypesRead, entityTypesWrite).
2. Call `adl_list_entity_types` to check which declared types exist in the workspace.
3. For each declared type, call `adl_query_records` with `limit: 1` to check if it has any data.
4. For empty or missing types, call `adl_list_pipeline_routes` to check if a pipeline feeds them.
5. If no pipeline exists, call `adl_list_connectors` and match by your domain context to find the best source.
6. For each gap with a matching connector, call `adl_propose_pipeline_route` with:
   - `name`: descriptive name linking the data to your role
   - `source_type`: "saas" for SaaS connectors, "webhook" for custom, "cdc" for databases
   - `connector_id`: the matched connector ID
   - `objects`: specific objects to sync (e.g., ["customers", "invoices"])
   - `reason`: why you need this data, tied to your responsibilities
7. Write a `discovery_result` record with your findings:
   - `agentId`, `agentName`, `runAt` (current timestamp)
   - `healthy`: entity types with data and active pipelines
   - `missing`: entity types with no data or no pipeline
   - `proposals`: pipeline proposals you created
   - `summary`: counts of total, healthy, missing, proposals
8. Store gap status in memory namespace `dependency_status` for cross-run comparison.

Only propose pipelines for genuine gaps. If a type has records but no pipeline, it may be manually populated or fed by another agent — mark it as healthy with `sourceType: "agent"` or `"manual"`.

Anti-patterns:
- NEVER propose a pipeline for an entity type that already has data — check `adl_query_records` with `limit: 1` first.
- NEVER propose without checking `adl_list_pipeline_routes` for existing routes — duplicate pipelines cause data conflicts.
- NEVER omit the `reason` field in a proposal — proposals without business justification are rejected by approvers.
