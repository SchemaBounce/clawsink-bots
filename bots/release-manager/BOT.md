---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: release-manager
  displayName: "Release Manager"
  version: "1.0.0"
  description: "Release planning, changelog generation, and version management."
  category: engineering
  tags: ["releases", "changelog", "versioning", "release-notes", "planning"]
agent:
  capabilities: ["release_management", "changelog_generation"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
schedule:
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@weekly"
    intensive: "@daily"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "product-owner"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "release plan ready or version bump decision needed" }
data:
  entityTypesRead: ["releases", "changelogs", "pull_requests", "review_findings"]
  entityTypesWrite: ["release_notes", "release_plans"]
  memoryNamespaces: ["release_history", "versioning_decisions"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
skills: []
automations:
  triggers:
    - name: "Generate release notes"
      entityType: "releases"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "Generate release notes from merged PRs and changelog entries."
requirements:
  minTier: "starter"
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
