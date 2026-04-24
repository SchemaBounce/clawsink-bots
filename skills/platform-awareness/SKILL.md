---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: platform-awareness
  displayName: "Platform Awareness"
  version: "1.0.0"
  description: "Foundational skill, tool discovery, inter-agent comms via A2A pattern, proactive behavior. All agents should have this."
  tags: ["platform", "foundational", "meta", "a2a", "discovery"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_tool_search", "adl_send_message", "adl_read_messages", "adl_list_agents"]
data:
  producesEntityTypes: []
  consumesEntityTypes: []
---
# Platform Awareness

Foundational skill that teaches every agent how to use the platform's 62+ tools, communicate with other agents via the A2A pattern, and act proactively within their authorized zones.

## When to Use

This skill is always active, it's baked into every agent's system prompt at activation time. It teaches the meta-pattern: discover tools, read messages, communicate with peers, act decisively.

## What You Get

- **Tool discovery**: Use `adl_tool_search` to find any of 62+ tools by keyword
- **Inter-agent messaging**: Send requests, alerts, findings, and handoffs to other agents
- **A2A communication**: Async messages with typed Parts (DataPart, TextPart, FilePart)
- **Proactive behavior**: Act first, report after, don't ask for permission on obvious fixes
- **Zone awareness**: Understand Zone 1 (read-only North Star), Zone 2 (shared domains), Zone 3 (private state)
