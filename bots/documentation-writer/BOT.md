---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: documentation-writer
  displayName: "Documentation Writer"
  version: "1.0.0"
  description: "Automatically updates documentation when code implementations complete, creating doc PRs linked to implementation PRs."
  category: engineering
  tags: ["documentation", "docs", "technical-writing", "engineering"]
agent:
  capabilities: ["writing", "documentation", "code-analysis"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
cost:
  estimatedTokensPerRun: 40000
  estimatedCostTier: "medium"
schedule: null
messaging:
  listensTo:
    - { type: "finding", from: ["software-architect"] }
    - { type: "request", from: ["product-owner", "release-manager"] }
  sendsTo:
    - { type: "finding", to: ["release-manager"], when: "doc PR ready for review" }
    - { type: "request", to: ["software-architect"], when: "need implementation details for docs" }
data:
  entityTypesRead: ["implementation_plans", "gh_issues"]
  entityTypesWrite: ["doc_updates", "doc_findings"]
  memoryNamespaces: ["doc_standards", "working_notes"]
zones:
  zone1Read: ["documentation_standards", "product_catalog"]
  zone2Domains: ["engineering"]
skills:
  - ref: "skills/pr-creation@1.0.0"
mcpServers:
  - ref: "tools/claude-code"
    required: true
    reason: "Spawns code sessions to update documentation files"
  - ref: "tools/github"
    required: true
    reason: "Creates doc PRs linked to implementation PRs"
requirements:
  minTier: "team"
---

# Documentation Writer

Automatically updates documentation when code implementations complete. Listens for findings from software-architect indicating an implementation is done, then spawns code sessions to update relevant documentation files and creates doc PRs linked to the original implementation PRs.

## What It Does

- Receives implementation-complete signals from software-architect
- Identifies which documentation files are affected (README, API docs, guides, changelog)
- Spawns Claude Code sessions to update documentation in the repository
- Creates doc PRs on `docs/[issue-name]` branches, linked to implementation PRs
- Handles doc update requests from product-owner and release-manager
- Only modifies documentation files — never touches application code

## Trigger Flow

1. Software-architect completes an implementation and sends a finding: "docs need updating"
2. Documentation Writer reads the implementation plan and identifies affected docs
3. Spawns a Claude Code session to clone the repo and update doc files
4. Creates a doc PR linked to the implementation PR
5. Notifies release-manager that the doc PR is ready for review

## Recommended North Star Keys

Set these in your workspace's North Star zone for best results:

- `documentation_standards` — Doc structure conventions, style guide, file organization rules
- `product_catalog` — Product features and capabilities referenced in documentation
