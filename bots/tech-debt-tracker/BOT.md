---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: tech-debt-tracker
  displayName: "Tech Debt Tracker"
  version: "1.0.0"
  description: "Analyzes code review findings and quality metrics to identify technical debt patterns, track debt over time, and suggest refactoring priorities."
  category: engineering
  tags: ["tech-debt", "code-quality", "refactoring", "engineering"]
agent:
  capabilities: ["analysis", "pattern-detection", "reporting"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
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
    light: "@monthly"
    standard: "@weekly"
    intensive: "@every 3d"
  cronExpression: "0 6 * * 1"
messaging:
  listensTo:
    - { type: "finding", from: ["code-reviewer", "api-tester"] }
  sendsTo:
    - { type: "finding", to: ["software-architect"], when: "refactoring opportunity identified" }
    - { type: "finding", to: ["sprint-planner"], when: "backlog items suggested from debt analysis" }
    - { type: "finding", to: ["release-manager"], when: "debt trend report ready" }
data:
  entityTypesRead: ["review_findings", "code_quality_metrics", "gh_issues"]
  entityTypesWrite: ["tech_debt_items", "quality_trends"]
  memoryNamespaces: ["debt_patterns", "working_notes"]
zones:
  zone1Read: ["quality_standards", "tech_stack"]
  zone2Domains: ["engineering"]
requirements:
  minTier: "starter"
---

# Tech Debt Tracker

Analyzes code review findings and quality metrics to identify technical debt patterns, categorize and prioritize debt items, and track quality trends over time. Helps engineering teams make data-driven refactoring decisions.

## What It Does

- Consumes findings from code-reviewer and api-tester to identify recurring quality issues
- Classifies debt items by severity, area, and estimated remediation effort
- Tracks quality trends per module and per time period (coverage, complexity, duplication)
- Sends refactoring recommendations to software-architect when patterns emerge
- Suggests backlog items to sprint-planner when debt warrants scheduled work
- Reports trend summaries to release-manager for visibility into codebase health

## How It Works with Other Bots

Tech Debt Tracker sits downstream of code-reviewer and api-tester, consuming their findings as input. It synthesizes these into structured debt items and trend data, then routes actionable recommendations to software-architect (for refactoring), sprint-planner (for backlog prioritization), and release-manager (for reporting).

## Recommended North Star Keys

Set these in your workspace's North Star zone for best results:

- `quality_standards` — Code coverage thresholds, complexity limits, acceptable duplication levels
- `tech_stack` — Languages, frameworks, and tools in use for contextualizing debt analysis
