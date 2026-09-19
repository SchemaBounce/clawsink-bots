---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: paperclip-worker
  displayName: "Paperclip Worker"
  version: "1.0.0"
  description: "Runs Paperclip assignments with checkout, progress, completion, and conflict-safe handoff discipline."
  tags: ["paperclip", "orchestration", "issues", "hosted-worker"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_list_connectors", "adl_tool_search"]
data:
  producesEntityTypes: []
  consumesEntityTypes: []
---

# Paperclip Worker

Teaches a hosted agent to operate as a reliable Paperclip worker. The skill covers assignment discovery, exclusive checkout, concise progress reporting, honest terminal states, and conflict-safe release behavior.

Use it with the `tools/paperclip` MCP connection. Paperclip remains the source of truth for issue ownership and status; SchemaBounce provides the hosted agent runtime and durable work context.
