---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: legal-compliance-team
  displayName: "Legal & Compliance"
  version: "1.0.0"
  description: "Legal and compliance automation covering matter management, audit tracking, security controls, and regulatory change monitoring"
  domain: legal-compliance
  category: legal-compliance
  tags: ["legal", "compliance", "audit", "regulatory", "security", "risk-management", "governance"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/legal-compliance@1.0.0"
  - ref: "bots/compliance-auditor@1.0.0"
  - ref: "bots/security-agent@1.0.0"
dataKits:
  - ref: "data-kits/legal-compliance@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Legal & Compliance"
  context: "Legal and compliance team managing matters, controls, audit findings, policies, regulatory changes, and security obligations"
  requiredKeys:
    - regulatory_frameworks
    - compliance_scope
    - audit_schedule
    - legal_matter_types
    - jurisdiction
    - escalation_contacts
orgChart:
  lead: legal-compliance
  domains:
    - name: "Legal"
      description: "Matter management, deadlines, policy drafting"
      head: legal-compliance
    - name: "Compliance"
      description: "Control frameworks, audit findings, regulatory tracking"
      head: compliance-auditor
    - name: "Security"
      description: "Security controls, vulnerability management, access reviews"
      head: security-agent
  roles:
    - bot: legal-compliance
      role: lead
      reportsTo: null
      domain: legal
    - bot: compliance-auditor
      role: specialist
      reportsTo: legal-compliance
      domain: compliance
    - bot: security-agent
      role: specialist
      reportsTo: legal-compliance
      domain: security
  escalation:
    critical: legal-compliance
    unhandled: legal-compliance
    paths:
      - name: "Compliance Violation"
        trigger: "compliance_violation"
        chain: [compliance-auditor, legal-compliance]
      - name: "Security Incident"
        trigger: "security_incident"
        chain: [security-agent, legal-compliance]
      - name: "Regulatory Deadline"
        trigger: "regulatory_deadline_approaching"
        chain: [compliance-auditor, legal-compliance]
      - name: "Audit Finding Critical"
        trigger: "critical_audit_finding"
        chain: [compliance-auditor, legal-compliance]
---
# Legal & Compliance

Three bots covering the legal and compliance lifecycle: matter and policy management, compliance control tracking and audit finding remediation, and security control enforcement. Built for in-house legal and compliance teams that need continuous visibility into obligations and risk.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Legal Compliance | Matter management, policy oversight, regulatory monitoring | @daily |
| Compliance Auditor | Control testing, audit findings, remediation tracking | @daily |
| Security Agent | Security controls, access reviews, vulnerability alerts | @every 4h |

## How They Work Together

The Legal Compliance bot leads the team, tracking active matters, upcoming deadlines, and policy lifecycle. The Compliance Auditor monitors the control framework, tracks open audit findings, and flags regulatory changes that require a response. The Security Agent enforces technical security controls, runs access reviews, and escalates security incidents. All three bots share findings through the legal domain, giving the team a single view of the organization's obligation posture.

**Communication flow:**
- Compliance Auditor detects control failure -> alert to Legal Compliance
- Compliance Auditor identifies new regulatory change -> finding to Legal Compliance
- Security Agent detects security incident -> alert to Legal Compliance
- Security Agent finds access anomaly -> finding to Compliance Auditor
- Legal Compliance identifies upcoming deadline -> request to Compliance Auditor
- Legal Compliance publishes new policy -> notification to Compliance Auditor and Security Agent

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `regulatory_frameworks`, `compliance_scope`, `audit_schedule`, `legal_matter_types`, `jurisdiction`, `escalation_contacts`
3. Bots begin running on their default schedules automatically
4. Check the Legal Compliance bot's daily briefings for consolidated obligation status
