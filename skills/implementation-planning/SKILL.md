---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: implementation-planning
  displayName: "Implementation Planning"
  version: "1.0.0"
  description: "Breaks tasks into file-level implementation plans with risk assessment and test strategy."
  tags: ["planning", "implementation", "risk-assessment", "engineering"]
tools:
  required: ["adl_query_records", "adl_read_memory", "adl_graph_query"]
data:
  consumesEntityTypes: ["gh_issues", "architecture_decisions"]
  producesEntityTypes: ["implementation_plans"]
---

# Implementation Planning

Breaks a task or issue into a concrete, file-level implementation plan. The skill reads the task description, queries architecture decisions and codebase patterns from memory, identifies affected files, classifies risk, and defines a test strategy.

## When to Use

Use this skill in bots that need to produce structured implementation plans before writing code. Pairs well with the `test-generation` and `pr-creation` skills for end-to-end engineering workflows.

## Typical Bots

Software architects, tech lead bots, and any bot that plans work before delegating implementation to a code session or sub-agent.
