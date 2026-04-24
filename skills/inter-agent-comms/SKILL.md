---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: inter-agent-comms
  displayName: "Inter-Agent Communication"
  version: "1.0.0"
  description: "Detailed inter-agent messaging, 5 message types, A2A Parts, threading, delegation patterns"
  tags: ["platform", "messaging", "multi-agent", "a2a", "delegation"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_send_message", "adl_read_messages", "adl_run_agent", "adl_run_agents", "adl_list_agents"]
data:
  producesEntityTypes: []
  consumesEntityTypes: []
---
# Inter-Agent Communication

Detailed instructions for inter-agent communication using the A2A pattern, 5 message types, typed Parts for data exchange, async/sync delegation, and task lifecycle management.

## When to Use

Invoke this skill when you need to coordinate with other agents. Send requests, delegate tasks, hand off work, or broadcast findings across a domain.

## What You Get

- **5 message types**: request, alert, finding, handoff, text
- **A2A data exchange**: Messages with typed Parts (TextPart, DataPart, FilePart)
- **Delegation patterns**: Async messaging (preferred), sync delegation (urgent), parallel fan-out
- **Task lifecycle**: 7-state lifecycle tracking for delegated work
- **Rate limits and rules**: Message caps, domain boundaries, threading
