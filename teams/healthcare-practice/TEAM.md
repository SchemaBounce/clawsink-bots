---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: healthcare-practice
  displayName: "Healthcare Practice"
  version: "1.0.0"
  description: "AI operations team for medical practices and clinics. Manages patient relations, regulatory compliance, billing reconciliation, and staff coordination."
  category: healthcare
  tags: ["healthcare", "medical", "practice", "compliance", "hipaa", "starter"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
requirements:
  minTier: "starter"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/customer-support@1.0.0"
  - ref: "bots/compliance-auditor@1.0.0"
  - ref: "bots/accountant@1.0.0"
  - ref: "bots/meeting-summarizer@1.0.0"
  - ref: "bots/hr-onboarding@1.0.0"
dataKits:
  - ref: "data-kits/healthcare@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/compliance-governance@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/financial-ops@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/hr-people@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "Healthcare / Medical Practice"
  context: "Medical practices, dental offices, or clinics managing patient communications, regulatory compliance, staff scheduling, and billing"
  requiredKeys:
    - practice_type
    - compliance_frameworks
    - billing_codes
    - staff_roles
    - patient_volume
    - ehr_system
orgChart:
  lead: executive-assistant
  domains:
    - name: "Administration"
      description: "Scheduling, meeting notes, staff onboarding"
      head: executive-assistant
      children:
        - name: "Meetings"
          description: "Summaries of staff and physician huddles"
          head: meeting-summarizer
        - name: "HR"
          description: "Clinician onboarding and credentialing"
          head: hr-onboarding
    - name: "Patient Care"
      description: "Triage of patient questions and complaints"
      head: customer-support
    - name: "Compliance"
      description: "HIPAA controls, audit evidence, policy review"
      head: compliance-auditor
    - name: "Billing"
      description: "Claims, collections, revenue tracking"
      head: accountant
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: administration
    - bot: customer-support
      role: specialist
      reportsTo: executive-assistant
      domain: patient-care
    - bot: compliance-auditor
      role: specialist
      reportsTo: executive-assistant
      domain: compliance
    - bot: accountant
      role: specialist
      reportsTo: executive-assistant
      domain: billing
    - bot: meeting-summarizer
      role: support
      reportsTo: executive-assistant
      domain: administration
    - bot: hr-onboarding
      role: specialist
      reportsTo: executive-assistant
      domain: administration
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Regulatory compliance gap"
        trigger: "compliance_gap"
        chain: [compliance-auditor, executive-assistant]
      - name: "Patient complaint pattern"
        trigger: "patient_escalation"
        chain: [customer-support, executive-assistant]
---
# Healthcare Practice

An AI team built for the operational realities of running a medical practice. Between patient flow, insurance billing complexities, regulatory audits, staff credentialing, and the constant pressure to maintain care quality while keeping the lights on, practice managers are buried. This team handles the operational overhead so clinical staff can focus on patients.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Assistant | Daily practice briefing, patient volume, compliance status, billing health, staffing | @daily |
| Customer Support | Patient relations, appointment issues, satisfaction surveys, inquiry triage | @every 2h |
| Compliance Auditor | Continuous regulatory validation, audit readiness checks, policy monitoring | @daily |
| Accountant | Billing reconciliation, insurance claims tracking, practice P&L | @daily |
| Meeting Summarizer | Captures clinical team meetings, staff huddles, and case review action items | @cdc |
| HR Onboarding | Staff credentialing checklists, license renewal tracking, training compliance | @weekly |

## How They Work Together

Healthcare practices operate under a unique combination of pressures: high patient volume, strict regulatory requirements, complex insurance billing, and staffing challenges. Every bot in this team addresses a specific operational pain point that practice managers deal with daily.

Customer Support handles patient-facing communications, but in a healthcare context, this means appointment rescheduling, referral coordination, post-visit follow-up surveys, and complaint triage. A patient frustrated by a billing error or a long wait time gets surfaced quickly before it becomes a formal complaint or negative review. Patterns in patient feedback (repeated complaints about wait times in the afternoon, for example) get flagged for Executive Assistant.

Compliance Auditor is the regulatory backbone. Healthcare practices face overlapping compliance requirements, documentation standards, privacy regulations, clinical protocols, and workplace safety. This bot tracks your compliance posture against your declared frameworks, monitors for regulatory updates that affect your practice type, and maintains continuous audit readiness. When a gap is detected, it generates specific remediation steps rather than generic warnings.

Accountant manages the financial engine that keeps a practice viable: claim submission tracking, denial rates by payer, aging receivables, procedure code profitability, and monthly P&L. It flags claims approaching timely filing deadlines and identifies payer-specific denial patterns so your billing team can address root causes.

Meeting Summarizer captures the clinical team huddles, case conferences, and staff meetings that happen constantly in healthcare settings. Action items get extracted and assigned, a discussed change to intake procedures, a new protocol to implement, a referral pattern to investigate. Nothing from a meeting gets lost.

HR Onboarding tracks the credentialing and compliance requirements for every staff member, license renewals, continuing education requirements, mandatory training completions, and background check expirations. In healthcare, a lapsed credential can shut down a provider's ability to see patients.

Executive Assistant synthesizes everything into the daily practice briefing: today's patient volume versus capacity, any compliance flags from the Auditor, billing health from Accountant, outstanding action items from Meeting Summarizer, and upcoming credential expirations from HR Onboarding.

**Communication flow:**
- Customer Support detects patient complaint pattern -> finding to Executive Assistant
- Compliance Auditor identifies regulatory gap or approaching audit deadline -> alert to Executive Assistant
- Accountant flags claim denial spike or aging receivable threshold -> alert to Executive Assistant
- Meeting Summarizer captures clinical team action items -> structured tasks to relevant bots
- HR Onboarding detects upcoming credential expiration -> alert to Executive Assistant
- Executive Assistant compiles daily practice briefing from all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `practice_type`, `compliance_frameworks`, `billing_codes`, `staff_roles`, `patient_volume`, `ehr_system`
3. Bots begin running on their default schedules automatically
4. Check Executive Assistant's daily briefings for a consolidated practice operations view
