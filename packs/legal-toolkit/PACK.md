---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: legal-toolkit
  displayName: Legal Toolkit
  version: 1.0.0
  description: SLA tracking, contract deadlines, regulatory checks, and compliance scoring
  category: Legal
  tags: [sla, contract, gdpr, compliance, retention, regulatory]
  icon: legal
tools:
  - name: sla_calculator
    description: Calculate SLA compliance from response times and uptime against target thresholds
    category: compliance
  - name: contract_deadline
    description: Track contract milestones, renewal dates, and notice periods
    category: tracking
  - name: regulatory_check
    description: Validate data handling practices against regulatory framework requirements
    category: compliance
  - name: gdpr_data_map
    description: Map data fields to GDPR categories (personal, sensitive, special) with legal basis
    category: privacy
  - name: retention_policy
    description: Apply data retention rules and flag records past their retention period
    category: governance
  - name: compliance_score
    description: Calculate a compliance readiness score from a checklist of control requirements
    category: scoring
---

# Legal Toolkit

SLA tracking, contract deadlines, regulatory checks, and compliance scoring. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent managing contracts, regulatory compliance, or data governance.

## Use Cases

- Monitor SLA compliance across service agreements
- Track contract renewal dates and notice deadlines
- Map data fields to GDPR categories for privacy audits
- Flag records that exceed their data retention period
- Score organizational readiness against compliance frameworks

## Tools

### sla_calculator
Evaluate SLA compliance by comparing actual response times and uptime against contractual targets. Returns compliance percentage and breach details.

### contract_deadline
Track key contract dates -- start, renewal, expiration, and notice periods. Flag upcoming deadlines within a configurable window.

### regulatory_check
Validate data handling configurations against regulatory requirements (GDPR, HIPAA, PCI DSS, SOX) and report gaps.

### gdpr_data_map
Classify data fields into GDPR categories (personal data, special category, sensitive) and associate legal basis for processing.

### retention_policy
Apply retention rules to records based on data type and creation date. Flag records past their retention period for review or deletion.

### compliance_score
Calculate a weighted compliance score from a checklist of control requirements. Returns overall score, passing controls, and gaps.
