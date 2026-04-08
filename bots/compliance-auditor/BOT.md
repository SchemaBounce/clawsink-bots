---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: compliance-auditor
  displayName: "Compliance Auditor"
  version: "1.0.6"
  description: "Checks regulatory compliance on new financial records."
  category: fintech
  tags: ["compliance", "audit", "regulatory", "cdc"]
agent:
  capabilities: ["compliance", "regulatory"]
  hostingMode: "openclaw"
  defaultDomain: "compliance"
  instructions: |
    ## Operating Rules
    - ALWAYS check `regulatory_frameworks` memory at run start for the active compliance rules to audit against
    - ALWAYS audit every new `financial_records` entity — CDC-triggered runs must process the triggering record completely
    - ALWAYS cite the specific compliance rule or regulation violated in every `audit_findings` record
    - NEVER mark a record as compliant without checking against ALL active regulatory frameworks
    - NEVER modify or delete the original `financial_records` — only write `audit_findings` and `compliance_reports` as separate records
    - NEVER skip audit on records that appear routine — systematic coverage is required for audit trail integrity
    - Escalation: critical compliance violations (fraud indicators, regulatory breaches) trigger immediate alert to executive-assistant
    - Send regulatory findings requiring legal interpretation to legal-compliance as type=finding
    - Send financial record compliance issues to accountant as type=finding for remediation tracking
    - Maintain `audit_history` memory to track audit coverage and ensure no records are missed across runs
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
trigger:
  entityType: "financial_records"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical compliance violation detected" }
    - { type: "finding", to: ["legal-compliance"], when: "regulatory finding requiring legal review" }
    - { type: "finding", to: ["accountant"], when: "financial record compliance issue" }
data:
  entityTypesRead: ["financial_records", "compliance_rules"]
  entityTypesWrite: ["audit_findings", "compliance_reports"]
  memoryNamespaces: ["regulatory_frameworks", "audit_history"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["compliance", "finance"]
presence:
  email:
    required: true
    provider: agentmail
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send compliance violation notices and audit reports to regulatory contacts"
  - ref: "tools/composio"
    required: false
    reason: "Connect to compliance management and document signing platforms"
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/cdc-event-analysis@1.0.0"
toolPacks:
  - ref: "packs/legal-toolkit@1.0.0"
    reason: "SLA calculations, regulatory checklists, and compliance scoring"
  - ref: "packs/security-compliance@1.0.0"
    reason: "PII detection, data masking, and audit trail generation"
  - ref: "packs/document-gen@1.0.0"
    reason: "Generate compliance reports and audit documentation"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-mission
      name: "Define compliance mission"
      description: "Regulatory context and compliance objectives for your organization"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Audit scope and severity classification depend on your compliance obligations"
      ui:
        inputType: text
        placeholder: "e.g., Maintain PCI DSS Level 1 compliance for all payment processing"
        prefillFrom: "workspace.mission"
    - id: set-regulatory-frameworks
      name: "Configure regulatory frameworks"
      description: "Active regulations the bot audits against (PCI DSS, SOX, GDPR, AML)"
      type: memory_seed
      namespace: regulatory_frameworks
      group: configuration
      priority: required
      reason: "Cannot audit records without knowing which regulations apply"
      ui:
        inputType: text
        placeholder: '{"frameworks": ["PCI_DSS_v4", "SOX", "AML_BSA"], "jurisdiction": "US"}'
        helpUrl: "https://docs.schemabounce.com/bots/compliance-auditor/frameworks"
    - id: connect-agentmail
      name: "Verify email identity"
      description: "Bot sends compliance violation notices and audit reports"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Compliance violation notices and audit reports must be delivered to regulatory contacts"
      ui:
        icon: email
        actionLabel: "Verify Email"
    - id: import-financial-records
      name: "Verify financial record data"
      description: "Financial records are the primary input for compliance auditing"
      type: data_presence
      entityType: financial_records
      minCount: 1
      group: data
      priority: required
      reason: "The bot audits financial records — needs data to begin auditing"
      ui:
        actionLabel: "Check Financial Records"
        emptyState: "No financial records found. Connect your financial system or import records to begin auditing."
    - id: import-compliance-rules
      name: "Import compliance rules"
      description: "Predefined compliance rules for automated checking"
      type: data_presence
      entityType: compliance_rules
      minCount: 1
      group: data
      priority: recommended
      reason: "Structured compliance rules enable consistent automated auditing"
      ui:
        actionLabel: "Check Compliance Rules"
        emptyState: "No compliance rules found. Import your regulatory rule set for structured auditing."
    - id: connect-composio
      name: "Connect compliance platform"
      description: "Sync audit findings with your GRC or compliance management platform"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: optional
      reason: "Automated sync with compliance management and document signing platforms"
      ui:
        icon: integration
        actionLabel: "Connect Compliance Platform"
goals:
  - name: audit_coverage
    description: "Every new financial record audited against all active frameworks"
    category: primary
    metric:
      type: rate
      numerator: { entity: audit_findings, filter: { status: { "$exists": true } } }
      denominator: { entity: financial_records }
    target:
      operator: ">"
      value: 0.99
      period: daily
      condition: "no financial record remains unaudited"
  - name: violation_detection
    description: "Flag compliance violations with specific regulation citations"
    category: primary
    metric:
      type: count
      entity: audit_findings
      filter: { violation: true }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when violations exist in financial data"
  - name: audit_accuracy
    description: "Audit findings confirmed as valid by compliance team"
    category: secondary
    metric:
      type: rate
      numerator: { entity: audit_findings, filter: { feedback: "confirmed" } }
      denominator: { entity: audit_findings, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.9
      period: monthly
    feedback:
      enabled: true
      entityType: audit_findings
      actions:
        - { value: confirmed, label: "Valid violation" }
        - { value: false_positive, label: "False positive" }
        - { value: severity_wrong, label: "Wrong severity level" }
  - name: audit_trail_integrity
    description: "Maintain complete audit history with no gaps in coverage"
    category: health
    metric:
      type: count
      source: memory
      namespace: audit_history
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Compliance Auditor

Audits new financial records for regulatory compliance. Checks against configured regulatory frameworks and flags violations.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
