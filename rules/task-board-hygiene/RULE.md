---
apiVersion: clawsink.schemabounce.com/v1
kind: Rule
metadata:
  name: task-board-hygiene
  displayName: "Task Board Hygiene"
  version: "1.0.0"
  description: "Truthful task state: no unverified Done, no deletions, no silent reassignment of human-owned tasks."
  tags: ["tasks", "coordination", "hygiene"]
  author: "schemabounce"
  license: "MIT"
severity: guardrail
appliesTo:
  - skills/schemabounce
---

# Task Board Hygiene

Guardrails for agents that manage tasks. The task board is the coordination surface humans trust to reflect reality; the moment an agent marks unfinished work Done or deletes a task with its history, that trust is gone and every status on the board becomes suspect.

This rule attaches automatically wherever the `skills/schemabounce` skill is composed (its `references/agents-and-tasks.md` covers the task board).

## What it enforces

- Done means verified done: a merged PR, a shipped artifact, or explicit human confirmation.
- Tasks are cancelled with a reason, never deleted; the trail survives.
- Human-owned tasks are not reassigned without messaging the owner first.
- Stalled work moves back a column with a stated blocker instead of sitting in a stale "In Progress".
