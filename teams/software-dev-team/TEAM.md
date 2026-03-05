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
  - ref: "bots/sre-devops@1.0.0"
  - ref: "bots/code-reviewer@1.0.0"
  - ref: "bots/api-tester@1.0.0"
  - ref: "bots/devops-automator@1.0.0"
  - ref: "bots/release-manager@1.0.0"
  - ref: "bots/bug-triage@1.0.0"
northStar:
  industry: "Software Development"
  context: "Engineering team automating CI/CD, code quality, and release processes"
  requiredKeys:
    - tech_stack
    - deployment_targets
    - release_cadence
    - quality_standards
    - incident_runbooks
---
# Software Development Team

Six bots covering the full software development lifecycle: code quality enforcement, automated testing, CI/CD pipeline monitoring, bug triage, release coordination, and infrastructure reliability.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|----------|
| SRE & DevOps | Infrastructure monitoring, incident response | @every 4h |
| Code Reviewer | PR review, code quality gates | CDC on pull_requests |
| API Tester | API endpoint validation, regression detection | @daily |
| DevOps Automator | CI/CD optimization, pipeline monitoring | @every 4h |
| Release Manager | Release coordination, changelog, version management | @weekly |
| Bug Triage | Bug prioritization, duplicate detection | @every 2h |

## How They Work Together

The Code Reviewer and API Tester form the quality gate layer, catching issues before they reach production. The Bug Triage bot prioritizes incoming issues and routes release-blockers to the Release Manager. The DevOps Automator monitors CI/CD pipeline health and escalates failures to SRE & DevOps. The Release Manager coordinates deployments using quality signals from all other bots.

**Communication flow:**
- Code Reviewer detects quality trends -> finding to Release Manager
- API Tester catches test failures -> alert to Bug Triage
- API Tester detects performance regression -> alert to SRE & DevOps
- DevOps Automator sees pipeline failure -> alert to SRE & DevOps
- Bug Triage flags high-priority bug -> request to Code Reviewer
- Bug Triage identifies release blocker -> alert to Release Manager
- Release Manager coordinates deployment -> request to SRE & DevOps
- SRE & DevOps detects production incident -> alert to Bug Triage

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `tech_stack`, `deployment_targets`, `release_cadence`, `quality_standards`, `incident_runbooks`
3. Bots begin running on their default schedules automatically
4. Check the Release Manager's weekly briefings for a consolidated release readiness view
