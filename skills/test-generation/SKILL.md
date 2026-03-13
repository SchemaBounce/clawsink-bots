---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: test-generation
  displayName: "Test Generation"
  version: "1.0.0"
  description: "Generates test specifications for code implementations based on acceptance criteria and code patterns."
  tags: ["testing", "test-generation", "quality", "engineering"]
tools:
  required: ["adl_query_records", "adl_read_memory"]
data:
  consumesEntityTypes: ["implementation_plans"]
  producesEntityTypes: ["test_specifications"]
---

# Test Generation

Generates structured test specifications from implementation plans. The skill reads the plan, loads testing conventions from memory, and produces test cases covering happy paths, edge cases, and error scenarios.

## When to Use

Use this skill in bots that need to define test coverage before or after code implementation. Pairs with `implementation-planning` for plan-then-test workflows.

## Typical Bots

Software architects, QA bots, and any bot that validates implementations against acceptance criteria.
