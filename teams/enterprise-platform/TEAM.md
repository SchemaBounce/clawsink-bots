---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: enterprise-platform
  displayName: "Enterprise Platform"
  version: "1.0.0"
  description: "Platform governance for enterprise software teams: security, compliance, release management, data infrastructure, and business metrics."
  category: enterprise
  tags: ["enterprise", "platform", "security", "governance", "engineering", "enterprise"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-reporter@1.0.0"
  - ref: "bots/security-agent@1.0.0"
  - ref: "bots/compliance-auditor@1.0.0"
  - ref: "bots/sre-devops@1.0.0"
  - ref: "bots/data-engineer@1.0.0"
  - ref: "bots/business-analyst@1.0.0"
  - ref: "bots/release-manager@1.0.0"
  - ref: "bots/code-reviewer@1.0.0"
requirements:
  minTier: "enterprise"
northStar:
  industry: "Enterprise Software Platform"
  context: "Enterprise software companies or platform teams with strict security, compliance, release governance, and data infrastructure requirements"
  requiredKeys:
    - compliance_frameworks
    - security_standards
    - release_cadence
    - data_architecture
    - sla_commitments
    - audit_schedule
    - team_structure
orgChart:
  lead: executive-reporter
  domains:
    - name: "Engineering"
      description: "Platform delivery and release management"
      head: executive-reporter
      children:
        - name: "Releases"
          description: "Release coordination, deployment gates"
          head: release-manager
          children:
            - name: "Code Review"
              description: "Merge gates, style, regression hunting"
              head: code-reviewer
        - name: "Reliability"
          description: "SRE / DevOps / infrastructure uptime"
          head: sre-devops
          children:
            - name: "Data"
              description: "Warehouse, ETL, data platform ops"
              head: data-engineer
    - name: "Security"
      description: "Threat detection, CVE tracking, access review"
      head: security-agent
      children:
        - name: "Compliance"
          description: "SOC 2, HIPAA, PCI, audit controls"
          head: compliance-auditor
    - name: "Business Intelligence"
      description: "Executive analytics and operational reporting"
      head: business-analyst
  roles:
    - bot: executive-reporter
      role: lead
      reportsTo: null
      domain: engineering
    - bot: security-agent
      role: specialist
      reportsTo: executive-reporter
      domain: security
    - bot: compliance-auditor
      role: support
      reportsTo: security-agent
      domain: security
    - bot: sre-devops
      role: specialist
      reportsTo: executive-reporter
      domain: engineering
    - bot: data-engineer
      role: specialist
      reportsTo: sre-devops
      domain: data
    - bot: business-analyst
      role: specialist
      reportsTo: executive-reporter
      domain: business-intelligence
    - bot: release-manager
      role: specialist
      reportsTo: executive-reporter
      domain: engineering
    - bot: code-reviewer
      role: support
      reportsTo: release-manager
      domain: engineering
  escalation:
    critical: executive-reporter
    unhandled: executive-reporter
    paths:
      - name: "Critical vulnerability"
        trigger: "cve_critical"
        chain: [security-agent, sre-devops, executive-reporter]
      - name: "Compliance control gap"
        trigger: "audit_control_failure"
        chain: [compliance-auditor, security-agent, executive-reporter]
      - name: "SLA breach risk"
        trigger: "sla_threshold_exceeded"
        chain: [sre-devops, release-manager, executive-reporter]
      - name: "Data pipeline failure"
        trigger: "pipeline_failure"
        chain: [data-engineer, sre-devops, executive-reporter]
---
# Enterprise Platform

A governance and operations team for enterprise software platforms. Eight bots cover the disciplines that enterprise customers demand and auditors inspect: security posture, compliance evidence, release governance, platform reliability, data integrity, and business metrics. Built for teams where a failed audit costs the contract and an SLA breach costs the relationship.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Reporter | Weekly platform report: releases, security, compliance, health, metrics | @weekly |
| Security Agent | Vulnerability scanning, CVE tracking, policy violation detection | @every 4h |
| Compliance Auditor | SOC2/ISO/GDPR control validation and audit evidence maintenance | @daily |
| SRE & DevOps | Platform health, incident response, SLA compliance monitoring | @every 1h |
| Data Engineer | Data pipelines, schema migrations, data freshness monitoring | @every 4h |
| Business Analyst | Platform adoption, feature usage, customer health scores | @daily |
| Release Manager | Release train coordination, versioning, changelog, go/no-go decisions | @on-trigger |
| Code Reviewer | Automated PR quality gates with security and standards checks | @on-trigger |

## How They Work Together

Enterprise platforms live and die by trust. Customers trust the platform to be secure, compliant, reliable, and improving. That trust is maintained through discipline across every function -- and these bots enforce that discipline continuously, not just when an audit is scheduled.

Code Reviewer is the first gate. Every PR gets automated quality and security checks before a human reviewer sees it. It catches dependency vulnerabilities, coding standard violations, and patterns that have caused incidents before. When code passes review and is ready to ship, Release Manager takes over -- coordinating release trains, managing semantic versioning, generating changelogs, and making the go/no-go call based on test results, security scan status, and compliance sign-off.

Security Agent runs continuously, scanning for new vulnerabilities, tracking CVEs against the dependency tree, and detecting policy violations. When a critical CVE drops that affects the platform, the alert goes to both SRE & DevOps (for mitigation) and Release Manager (to prioritize the patch). Compliance Auditor operates on a different cadence -- validating that SOC2, ISO, or GDPR controls are actually being followed, not just documented. It maintains the audit evidence trail that enterprise customers and their auditors expect to see: access reviews, change management records, incident response documentation.

SRE & DevOps monitors platform health around the clock -- uptime, latency, error rates, and the SLA commitments that are written into customer contracts. When an incident occurs, it coordinates the response and tracks resolution against SLA windows. Data Engineer manages the data infrastructure layer: pipeline health, schema migrations, data freshness, and the integrity of the data that customers and internal analytics depend on. Business Analyst tracks the metrics that the business cares about: platform adoption curves, feature usage patterns, and customer health scores that predict renewal and expansion.

Executive Reporter compiles the weekly platform report that leadership and stakeholders need: release velocity, security posture, compliance status, platform health against SLAs, and the business metrics that determine whether the platform is growing.

**Communication flow:**
- Code Reviewer gates PR -> security findings to Security Agent, quality metrics to Release Manager
- Release Manager coordinates release -> go/no-go inputs from Security Agent and Compliance Auditor
- Security Agent detects critical CVE -> alert to SRE & DevOps for mitigation, flag to Release Manager for patch priority
- Compliance Auditor finds control gap -> finding to Executive Reporter, remediation tracking initiated
- SRE & DevOps detects SLA breach risk -> alert to Executive Reporter, incident to Release Manager (hold releases)
- Data Engineer detects pipeline failure -> alert to SRE & DevOps, data freshness warning to Business Analyst
- Business Analyst identifies adoption drop -> finding to Executive Reporter for stakeholder review
- Executive Reporter compiles weekly platform report from all bot signals

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `compliance_frameworks`, `security_standards`, `release_cadence`, `data_architecture`, `sla_commitments`, `audit_schedule`, `team_structure`
3. Bots begin running on their default schedules automatically
4. Check the Executive Reporter's weekly platform report for a consolidated view of releases, security, compliance, reliability, and business metrics
