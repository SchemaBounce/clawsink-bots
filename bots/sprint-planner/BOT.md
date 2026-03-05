---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: sprint-planner
  displayName: "Sprint Planner"
  version: "1.0.0"
  description: "Sprint planning, backlog prioritization, and velocity tracking."
  category: project-management
  tags: ["sprints", "backlog", "velocity", "prioritization", "agile", "RICE"]
agent:
  capabilities: ["project-management", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "management"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
cost:
  estimatedTokensPerRun: 25000
  estimatedCostTier: "medium"
schedule:
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@weekly"
    intensive: "@every 3d"
messaging:
  listensTo:
    - { type: "request", from: ["product-owner", "executive-assistant"] }
    - { type: "finding", from: ["product-owner"] }
  sendsTo:
    - { type: "finding", to: ["product-owner", "executive-assistant"], when: "sprint plan ready or velocity trend change detected" }
    - { type: "alert", to: ["product-owner"], when: "sprint at risk of overcommitment or blocked dependency" }
data:
  entityTypesRead: ["tasks", "stories", "bugs", "velocity_metrics"]
  entityTypesWrite: ["sprint_plans", "priority_recommendations"]
  memoryNamespaces: ["sprint_history", "velocity_trends", "team_capacity"]
zones:
  zone1Read: ["mission", "team_size", "sprint_cadence"]
  zone2Domains: ["management"]
skills:
  - ref: "skills/sprint-planning@1.0.0"
automations:
  triggers:
    - name: "Assess new task priority"
      entityType: "tasks"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "A new task was recorded. Assess priority and add to backlog with RICE score."
requirements:
  minTier: "starter"
---

# Sprint Planner

Plans sprints by analyzing team velocity, prioritizing the backlog using RICE scoring, and ensuring achievable commitments. Runs weekly to prepare upcoming sprint plans.

## What It Does

- Prioritizes backlog items using the RICE framework (Reach, Impact, Confidence, Effort)
- Tracks team velocity across sprints and identifies trends
- Plans sprint capacity based on historical velocity and team availability
- Flags dependency risks and blocked items before sprint commitment
- Generates sprint plans with recommended story point allocation

## Escalation Behavior

- **Critical**: Sprint at risk of failure due to blocked dependencies -> alerts product-owner
- **High**: Velocity declining over 3+ sprints -> finding to executive-assistant
- **Medium**: Task priority conflict or unclear requirements -> logged as priority_recommendations
- **Low**: Routine backlog grooming -> memory update only

## Recommended Setup

Set these North Star keys:
- `team_size` -- Number of team members for capacity planning
- `sprint_cadence` -- Sprint length in weeks (e.g., "2 weeks")
