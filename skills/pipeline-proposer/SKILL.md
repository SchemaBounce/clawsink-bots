---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: pipeline-proposer
  displayName: "Pipeline Proposer"
  version: "1.0.0"
  description: "Propose new data pipeline routes for CDC, webhook, and SaaS data ingestion — requires human approval before activation."
  tags: ["pipelines", "data-ingestion", "cdc", "proposals"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_tool_search"]
data:
  producesEntityTypes: ["pipeline_proposals"]
  consumesEntityTypes: []
---
# Pipeline Proposer

Enables agents to propose new data pipeline routes when they identify missing data flows. Proposals go through human approval before activation — agents cannot create pipelines directly.

## When to Use

- Agent discovers a data gap ("we need real-time inventory data from Shopify")
- Business process requires ingesting data from a new source
- Agent identifies a pattern that would benefit from CDC event streaming
- User asks for data synchronization between systems

## What You Get

- **Proposal creation**: Describe the pipeline and why it's needed
- **Source types**: CDC (database changes), webhook (HTTP), SaaS (third-party APIs)
- **Human approval gate**: All proposals require sign-off via the Automations dashboard
- **Connector discovery**: Find available SaaS connectors and sink types
