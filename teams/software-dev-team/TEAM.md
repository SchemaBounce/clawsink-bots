---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: software-dev-team
  displayName: "Software Development Team"
  version: "1.0.0"
  description: "End-to-end engineering automation from code review to production deployment"
  category: engineering
  tags: ["engineering", "devops", "ci-cd", "code-quality"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/software-architect@1.0.0"
  - ref: "bots/sre-devops@1.0.0"
  - ref: "bots/code-reviewer@1.0.0"
  - ref: "bots/api-tester@1.0.0"
  - ref: "bots/devops-automator@1.0.0"
  - ref: "bots/release-manager@1.0.0"
  - ref: "bots/bug-triage@1.0.0"
  - ref: "bots/tech-debt-tracker@1.0.0"
  - ref: "bots/documentation-writer@1.0.0"
plugins:
  - ref: "n8n-workflow@latest"
    slot: "workflow"
    reason: "CI/CD and release automation for devops-automator, release-manager, and sre-devops"
    config:
      webhook_triggers: true
      workflow_templates: ["ci-cd", "release", "incident"]
  - ref: "microsoft-teams@latest"
    slot: "notifications"
    reason: "Team notifications for build failures, release status, and incident alerts"
    config:
      channel_mapping:
        alerts: "engineering-alerts"
        releases: "release-updates"
mcpServers:
  - ref: "tools/codex"
    reason: "Shared default coding agent for implementation and documentation bots — managed OpenAI Codex sessions, billed via workspace credits"
    config:
      default_branch: "development"
      max_concurrent_sessions: 2
  - ref: "tools/github"
    reason: "Shared GitHub access for all engineering bots"
dataKits:
  - ref: "data-kits/it-operations@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/project-management@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "Software Development"
  context: "Engineering team automating CI/CD, code quality, and release processes"
  requiredKeys:
    - tech_stack
    - deployment_targets
    - release_cadence
    - quality_standards
    - incident_runbooks
    - repository_config
    - architecture_principles
orgChart:
  lead: software-architect
  roles:
    - bot: software-architect
      role: lead
      reportsTo: null
      domain: engineering
    - bot: code-reviewer
      role: specialist
      reportsTo: software-architect
      domain: quality
    - bot: api-tester
      role: support
      reportsTo: code-reviewer
      domain: quality
    - bot: release-manager
      role: specialist
      reportsTo: software-architect
      domain: project-management
    - bot: sre-devops
      role: specialist
      reportsTo: release-manager
      domain: devops
    - bot: devops-automator
      role: support
      reportsTo: sre-devops
      domain: devops
    - bot: tech-debt-tracker
      role: specialist
      reportsTo: software-architect
      domain: quality
    - bot: documentation-writer
      role: specialist
      reportsTo: software-architect
      domain: engineering
    - bot: bug-triage
      role: specialist
      reportsTo: software-architect
      domain: engineering
  escalation:
    critical: software-architect
    unhandled: software-architect
    paths:
      - name: "Production Incident"
        trigger: "production_incident"
        chain: [sre-devops, software-architect]
      - name: "Pipeline Failure"
        trigger: "pipeline_failure"
        chain: [devops-automator, sre-devops, software-architect]
      - name: "Release Blocker"
        trigger: "release_blocker"
        chain: [bug-triage, software-architect]
      - name: "Quality Gate Failure"
        trigger: "quality_gate_failure"
        chain: [code-reviewer, software-architect]
      - name: "Implementation Failure"
        trigger: "implementation_failure"
        chain: [software-architect]
      - name: "Code Quality Regression"
        trigger: "quality_regression"
        chain: [tech-debt-tracker, software-architect]
      - name: "Documentation Gap"
        trigger: "documentation_gap"
        chain: [documentation-writer, software-architect]
---
# Software Development Team

Nine bots covering the full software development lifecycle: architecture oversight, code quality enforcement, automated testing, CI/CD pipeline monitoring, bug triage, release coordination, infrastructure reliability, tech debt management, and documentation automation.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Software Architect | Implementation orchestration | Event-triggered |
| SRE & DevOps | Infrastructure monitoring, incident response | @every 4h |
| Code Reviewer | PR review, code quality gates | CDC on pull_requests |
| API Tester | API endpoint validation, regression detection | @daily |
| DevOps Automator | CI/CD optimization, pipeline monitoring | @every 4h |
| Release Manager | Release coordination, changelog, version management | @weekly |
| Bug Triage | Bug prioritization, duplicate detection | @every 2h |
| Tech Debt Tracker | Debt analysis and refactoring prioritization | @weekly |
| Documentation Writer | Automated doc updates | Event-triggered |

## How They Work Together

The Software Architect leads the team, orchestrating implementation decisions and coordinating across all engineering functions. The Code Reviewer and API Tester form the quality gate layer, catching issues before they reach production. The Tech Debt Tracker monitors codebase health and prioritizes refactoring work through the Software Architect. The Bug Triage bot prioritizes incoming issues and routes release-blockers to the Software Architect. The DevOps Automator monitors CI/CD pipeline health and escalates failures to SRE & DevOps. The Release Manager coordinates deployments using quality signals from all other bots. The Documentation Writer keeps technical documentation in sync with code changes, triggered by implementation events.

**Communication flow:**
- Software Architect delegates implementation tasks -> request to Code Reviewer, Documentation Writer
- Code Reviewer detects quality trends -> finding to Software Architect
- API Tester catches test failures -> alert to Bug Triage
- API Tester detects performance regression -> alert to SRE & DevOps
- DevOps Automator sees pipeline failure -> alert to SRE & DevOps
- Bug Triage flags high-priority bug -> request to Code Reviewer
- Bug Triage identifies release blocker -> alert to Software Architect
- Release Manager coordinates deployment -> request to SRE & DevOps
- SRE & DevOps detects production incident -> alert to Bug Triage
- Tech Debt Tracker identifies regression -> alert to Software Architect
- Documentation Writer detects doc gap -> alert to Software Architect

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `tech_stack`, `deployment_targets`, `release_cadence`, `quality_standards`, `incident_runbooks`, `repository_config`, `architecture_principles`
3. Bots begin running on their default schedules automatically
4. Check the Software Architect's briefings for a consolidated engineering readiness view
