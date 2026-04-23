---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: sprint-planner
  displayName: "Sprint Planner"
  version: "1.0.5"
  description: "Sprint planning, backlog prioritization, and velocity tracking."
  category: project-management
  tags: ["sprints", "backlog", "velocity", "prioritization", "agile", "RICE"]
agent:
  capabilities: ["project-management", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "management"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star keys `team_size` and `sprint_cadence` before generating any sprint plan -- these are required inputs
    - ALWAYS compute a RICE score (Reach x Impact x Confidence / Effort) for every backlog item before it enters a sprint
    - ALWAYS cap planned story points at 90% of trailing 3-sprint average velocity from `velocity_trends` memory -- never overcommit
    - NEVER declare a sprint plan ready without checking for blocked dependencies across all included stories and tasks
    - NEVER adjust historical velocity numbers to appear favorable -- track honestly in `velocity_trends` memory
    - Escalate to product-owner (type=alert) when a sprint is at risk due to blocked dependencies or overcommitment
    - Send sprint plan summaries and velocity trend changes to product-owner and executive-assistant (type=finding)
    - Send implementation task assignments to software-architect (type=request) when tasks enter the current sprint
    - Consume findings from product-owner and tech-debt-tracker to update backlog priorities before planning
    - Flag dependency risks at least 2 days before sprint start by checking task dependency fields in `stories` and `tasks` records
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@weekly"
    intensive: "@every 3d"
messaging:
  listensTo:
    - { type: "request", from: ["product-owner", "executive-assistant"] }
    - { type: "finding", from: ["product-owner", "tech-debt-tracker"] }
  sendsTo:
    - { type: "finding", to: ["product-owner", "executive-assistant"], when: "sprint plan ready or velocity trend change detected" }
    - { type: "request", to: ["software-architect"], when: "implementation task assigned for current sprint" }
    - { type: "alert", to: ["product-owner"], when: "sprint at risk of overcommitment or blocked dependency" }
data:
  entityTypesRead: ["tasks", "stories", "bugs", "velocity_metrics"]
  entityTypesWrite: ["sprint_plans", "priority_recommendations"]
  memoryNamespaces: ["sprint_history", "velocity_trends", "team_capacity"]
zones:
  zone1Read: ["mission", "team_size", "sprint_cadence"]
  zone2Domains: ["management", "engineering"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/sprint-planning@1.0.0"
automations:
  triggers:
    - name: "Assess new task priority"
      entityType: "tasks"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "A new task was recorded. Assess priority and add to backlog with RICE score."
plugins:
  - ref: "microsoft-teams@latest"
    slot: "channel"
    required: false
    reason: "Sends sprint plan summaries, velocity alerts, and overcommitment warnings to team channels"
mcpServers:
  - ref: "tools/jira"
    required: false
    reason: "Manages sprints, creates and assigns issues, tracks velocity"
  - ref: "tools/linear"
    required: false
    reason: "Manages cycles, creates and assigns issues in Linear"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-team-size
      name: "Set team size"
      description: "Number of team members for capacity planning"
      type: north_star
      key: team_size
      group: configuration
      priority: required
      reason: "Cannot calculate sprint capacity without knowing how many people are on the team"
      ui:
        inputType: number
        min: 1
        max: 50
        default: 5
    - id: set-sprint-cadence
      name: "Set sprint cadence"
      description: "Sprint length in weeks, controls planning cycle and velocity window"
      type: north_star
      key: sprint_cadence
      group: configuration
      priority: required
      reason: "Velocity tracking and sprint planning require a defined iteration length"
      ui:
        inputType: select
        options:
          - { value: "1 week", label: "1 week" }
          - { value: "2 weeks", label: "2 weeks (default)" }
          - { value: "3 weeks", label: "3 weeks" }
          - { value: "4 weeks", label: "4 weeks" }
        default: "2 weeks"
    - id: import-backlog
      name: "Import backlog items"
      description: "Seed the backlog with existing stories and tasks so prioritization starts immediately"
      type: data_presence
      entityType: tasks
      minCount: 5
      group: data
      priority: required
      reason: "RICE scoring and sprint planning require backlog items to prioritize"
      ui:
        actionLabel: "Import Backlog"
        emptyState: "No backlog items found. Import via CSV or connect your project management tool."
    - id: connect-project-tracker
      name: "Connect project tracker"
      description: "Syncs stories, tasks, and sprint data with Jira or Linear"
      type: mcp_connection
      ref: tools/jira
      group: connections
      priority: recommended
      reason: "Two-way sync keeps sprint plans current with the team's actual work tracker"
      ui:
        icon: jira
        actionLabel: "Connect Project Tracker"
    - id: connect-teams
      name: "Connect Microsoft Teams"
      description: "Posts sprint plans and velocity alerts to your team channel"
      type: mcp_connection
      ref: tools/microsoft-teams
      group: connections
      priority: optional
      reason: "Team notifications for sprint plans, overcommitment warnings, and velocity trends"
      ui:
        icon: teams
        actionLabel: "Connect Teams"
goals:
  - name: sprint_plans_delivered
    description: "Generate actionable sprint plans on each planning cycle"
    category: primary
    metric:
      type: count
      entity: sprint_plans
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when scheduled run fires"
    feedback:
      enabled: true
      entityType: sprint_plans
      actions:
        - { value: adopted, label: "Plan adopted as-is" }
        - { value: modified, label: "Plan adopted with changes" }
        - { value: rejected, label: "Plan not useful" }
  - name: velocity_accuracy
    description: "Planned story points should match actual completion within 20%"
    category: primary
    metric:
      type: rate
      numerator: { entity: sprint_plans, filter: { velocity_variance_pct: { "$lte": 20 } } }
      denominator: { entity: sprint_plans, filter: { status: "completed" } }
    target:
      operator: ">"
      value: 0.75
      period: monthly
  - name: velocity_trend_tracking
    description: "Maintain up-to-date velocity trends across sprints"
    category: health
    metric:
      type: count
      source: memory
      namespace: velocity_trends
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: dependency_risk_detection
    description: "Flag blocked dependencies before sprint commitment"
    category: secondary
    metric:
      type: count
      entity: priority_recommendations
      filter: { type: "blocked_dependency" }
    target:
      operator: ">="
      value: 0
      period: per_run
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
