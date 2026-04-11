---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: tool-packs-awareness
  displayName: "Built-in Tools Awareness"
  version: "1.0.0"
  description: "Discover and use built-in deterministic tools instead of manual computation"
  tags: ["tools", "built-in", "deterministic", "computation", "discovery"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_tool_search"]
  optional: []
data:
  producesEntityTypes: []
  consumesEntityTypes: []
---
# Built-in Tools Awareness

Teaches agents to discover and use built-in deterministic tools — 133 Go functions across 15 categories that execute in <10ms with zero LLM tokens, giving exact reproducible results. All 133 tools are available to every agent automatically. Agents should always search for an existing tool before implementing manual logic.

## When to Use

This skill is always active for agents that perform computation, data processing, or domain-specific calculations. Before writing manual logic for any calculation, transformation, or validation, agents should search for an existing built-in tool.

## What You Get

- **Tool discovery**: Use `adl_tool_search` with domain keywords to find deterministic functions
- **Zero-token computation**: Built-in tools run as Go code — no LLM tokens consumed
- **Exact results**: Deterministic functions give precise, reproducible answers every time
- **133 tools across 15 categories**: Finance, Math, Text, Documents, Web, Security, E-commerce, HR, Marketing, DevOps, Healthcare, Legal, Geospatial, Data Processing, Date/Time
- **Always available**: Every agent has access to all 133 tools automatically — no opt-in required
