---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: tool-packs-awareness
  displayName: "Tool Packs Awareness"
  version: "1.0.0"
  description: "Discover and use deterministic tool pack functions instead of manual computation"
  tags: ["tools", "packs", "deterministic", "computation", "discovery"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_tool_search"]
  optional: []
data:
  producesEntityTypes: []
  consumesEntityTypes: []
---
# Tool Packs Awareness

Teaches agents to discover and use deterministic tool pack functions — Go functions that execute in <10ms with zero LLM tokens, giving exact reproducible results. Agents should always search for an existing tool before implementing manual logic.

## When to Use

This skill is always active for agents that perform computation, data processing, or domain-specific calculations. Before writing manual logic for any calculation, transformation, or validation, agents should search for an existing tool pack function.

## What You Get

- **Tool discovery**: Use `adl_tool_search` with domain keywords to find deterministic functions
- **Zero-token computation**: Tool pack functions run as Go code — no LLM tokens consumed
- **Exact results**: Deterministic functions give precise, reproducible answers every time
- **15 tool pack categories**: Finance, Math, Text, Documents, Web, Security, E-commerce, HR, Marketing, DevOps, Healthcare, Legal, Geospatial, Data Processing, Date/Time
