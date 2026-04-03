---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: release-manager
  displayName: "Release Manager"
  version: "1.0.2"
  description: "Release planning, changelog generation, and version management."
  category: engineering
  tags: ["releases", "changelog", "versioning", "release-notes", "planning"]
agent:
  capabilities: ["release_management", "changelog_generation"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS check North Star keys `versioning_strategy` and `release_cadence` before recommending version bumps — follow the workspace's semver policy.
    - ALWAYS aggregate ALL merged PRs since the last release before generating release notes — never produce partial changelogs.
    - ALWAYS classify changes as features, fixes, breaking changes, or internal — breaking changes MUST be flagged prominently.
    - NEVER deploy or trigger a release pipeline without first verifying that all linked review_findings are resolved.
    - Route release notes generation requests to release-notes-writer with the version range and PR list.
    - Route deployment promotion and pipeline triggers to devops-automator — release-manager coordinates but does not execute deployments.
    - Route documentation update needs to documentation-writer when a release includes API changes or new features.
    - Escalate to executive-assistant when a release contains breaking changes without a migration path or when a release delay is needed.
    - When receiving findings from tech-debt-tracker, evaluate whether debt items should block the next release or be deferred.
    - When receiving findings from documentation-writer confirming doc PR readiness, include the doc PR link in the release plan.
    - Update `versioning_decisions` memory with each version bump decision and its rationale for future reference.
  toolInstructions: |
    ## Tool Usage — Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 2: `adl_read_messages` — check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}` — ONE query for all new records
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
    intensive: "@daily"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "product-owner"] }
    - { type: "finding", from: ["software-architect", "tech-debt-tracker", "documentation-writer"] }
    - { type: "finding", from: ["release-notes-writer"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "release plan ready or version bump decision needed" }
    - { type: "request", to: ["release-notes-writer"], when: "release notes generation needed for upcoming release" }
    - { type: "request", to: ["devops-automator"], when: "deployment promotion or release pipeline trigger needed" }
    - { type: "finding", to: ["documentation-writer"], when: "release requires documentation updates" }
data:
  entityTypesRead: ["releases", "changelogs", "pull_requests", "review_findings"]
  entityTypesWrite: ["release_notes", "release_plans"]
  memoryNamespaces: ["release_history", "versioning_decisions"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
presence:
  web:
    search: true
    browsing: true
egress:
  mode: "none"
skills:
  - ref: "skills/report-generation@1.0.0"
  - ref: "skills/pr-creation@1.0.0"
  - ref: "skills/notification-dispatch@1.0.0"
automations:
  triggers:
    - name: "Generate release notes"
      entityType: "releases"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "Generate release notes from merged PRs and changelog entries."
plugins:
  - ref: "n8n-workflow@latest"
    required: true
    reason: "Triggers release pipelines, version tagging, and deployment promotion workflows"
mcpServers:
  - ref: "tools/github"
    required: false
    reason: "Creates release branches, merges PRs, creates releases and tags"
  - ref: "tools/slack"
    required: false
    reason: "Announces releases to engineering channels"
  - ref: "tools/exa"
    required: true
    reason: "Search for dependency advisories, security bulletins, and release best practices"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse CI/CD dashboards and deployment status pages to verify release readiness"
  - ref: "tools/composio"
    required: false
    reason: "Connect to CI/CD platforms, project management tools, and deployment services"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-github
      name: "Connect GitHub"
      description: "Links your repositories so the bot can track PRs, releases, and tags"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "Primary data source for merged PRs, release branches, and version tags"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
        helpUrl: "https://docs.schemabounce.com/integrations/github"
    - id: set-versioning-strategy
      name: "Define versioning strategy"
      description: "Set your semantic versioning policy so the bot recommends correct version bumps"
      type: north_star
      key: versioning_strategy
      group: configuration
      priority: required
      reason: "Cannot recommend version bumps without knowing the workspace semver policy"
      ui:
        inputType: select
        options:
          - { value: semver_strict, label: "Strict SemVer (breaking=major, feature=minor, fix=patch)" }
          - { value: semver_0x, label: "0.x SemVer (breaking=minor, feature=minor, fix=patch)" }
          - { value: calver, label: "Calendar Versioning (YYYY.MM.patch)" }
          - { value: custom, label: "Custom (define in release_cadence)" }
        default: semver_strict
    - id: set-release-cadence
      name: "Set release cadence"
      description: "Define your target release frequency for scheduling and readiness checks"
      type: north_star
      key: release_cadence
      group: configuration
      priority: required
      reason: "Release cadence drives schedule planning and readiness evaluation"
      ui:
        inputType: select
        options:
          - { value: weekly, label: "Weekly releases" }
          - { value: biweekly, label: "Biweekly releases" }
          - { value: monthly, label: "Monthly releases" }
          - { value: on_demand, label: "On-demand (manual trigger)" }
        default: biweekly
    - id: connect-exa
      name: "Connect Exa for advisories"
      description: "Search for dependency advisories, security bulletins, and release best practices"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "Security advisory awareness is critical before cutting a release"
      ui:
        icon: exa
        actionLabel: "Connect Exa"
    - id: connect-slack
      name: "Connect Slack for announcements"
      description: "Posts release announcements and readiness updates to engineering channels"
      type: mcp_connection
      ref: tools/slack
      group: connections
      priority: recommended
      reason: "Team-wide release communication and deployment coordination"
      ui:
        icon: slack
        actionLabel: "Connect Slack"
    - id: import-releases
      name: "Import release history"
      description: "Previous releases provide version history context for bump recommendations"
      type: data_presence
      entityType: releases
      minCount: 1
      group: data
      priority: recommended
      reason: "Release history establishes baseline for version sequencing and changelog generation"
      ui:
        actionLabel: "Import Releases"
        emptyState: "No release history found. Import previous releases or start fresh with the next version."
goals:
  - name: generate_release_plans
    description: "Produce complete release plans with categorized changes and version recommendations"
    category: primary
    metric:
      type: count
      entity: release_plans
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "when merged PRs exist since last release"
  - name: changelog_completeness
    description: "Every release plan includes all merged PRs categorized as features, fixes, or breaking"
    category: primary
    metric:
      type: rate
      numerator: { entity: release_notes, filter: { pr_coverage: "complete" } }
      denominator: { entity: release_notes }
    target:
      operator: ">="
      value: 1.0
      period: per_run
  - name: versioning_consistency
    description: "Track version bump decisions to maintain consistent versioning over time"
    category: health
    metric:
      type: count
      source: memory
      namespace: versioning_decisions
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: breaking_change_detection
    description: "All breaking changes flagged prominently before release approval"
    category: secondary
    metric:
      type: boolean
      check: breaking_changes_flagged_in_plan
    target:
      operator: "=="
      value: true
      period: per_run
      condition: "when breaking changes exist"
---

# Release Manager

Organized release management agent that tracks merged pull requests, generates release notes, plans version bumps, and coordinates release schedules with the team.

## What It Does

- Aggregates merged PRs into categorized release notes (features, fixes, breaking changes)
- Generates human-readable changelogs from commit history
- Recommends semantic version bumps (major, minor, patch) based on changes
- Plans release schedules and tracks release readiness
- Identifies missing documentation or untested changes before release
- Coordinates release timing with stakeholders

## Escalation Behavior

- **Critical**: Breaking change without migration path -> finding to executive-assistant
- **High**: Release blocker identified, release delay needed -> finding to executive-assistant
- **Medium**: Version bump decision needed, changelog ready for review -> logged as release_plans
- **Low**: Minor changelog update, documentation gap -> logged as release_notes

## Recommended Setup

Set these North Star keys for best results:
- `versioning_strategy` -- Your semantic versioning policy
- `release_cadence` -- Target release frequency
