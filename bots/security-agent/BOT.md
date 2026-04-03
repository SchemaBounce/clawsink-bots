---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: security-agent
  displayName: "Security Agent"
  version: "1.0.2"
  description: "Vulnerability scanning, security policy audits, CVE monitoring, pen test posture checks, secret rotation tracking."
  category: operations
  tags: ["security", "pentest", "vulnerabilities", "cve", "policy", "compliance", "secrets"]
agent:
  capabilities: ["security", "dev_devops"]
  hostingMode: "openclaw"
  defaultDomain: "security"
  instructions: |
    ## Operating Rules
    - ALWAYS review `sre_findings` and `de_findings` records for security implications at the start of every run -- these are your primary intake sources
    - ALWAYS check `rotation_schedule` memory namespace for overdue secret rotations and flag any that exceed configured policy thresholds
    - ALWAYS read North Star keys `security_policy` and `compliance_requirements` before evaluating findings -- these define what constitutes a violation
    - NEVER disclose specific vulnerability details, CVE exploit steps, or secret rotation schedules in outbound messages -- send severity + remediation guidance only
    - NEVER downgrade a critical finding -- if active exploit evidence or data exposure is detected, alert executive-assistant immediately (type=alert)
    - Send infrastructure hardening recommendations to sre-devops (type=finding) and compliance gaps to legal-compliance (type=finding)
    - Forward security patterns that should be enforced in code reviews to code-reviewer (type=finding) and CI/CD hardening needs to devops-automator (type=finding)
    - Cross-reference new findings against `vulnerability_database` memory to identify recurring patterns and track remediation status
    - Only access external CVE sources (nvd.nist.gov, cve.org, osv.dev, api.github.com) via allowed egress -- never attempt to reach other domains
    - Maintain a running vulnerability count by severity in `working_notes` memory for trend reporting via the scheduled-report skill
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
schedule:
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo:
    - { type: "finding", from: ["sre-devops", "data-engineer", "code-reviewer"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical vulnerability or active exploit detected" }
    - { type: "finding", to: ["sre-devops"], when: "infrastructure hardening recommendation" }
    - { type: "finding", to: ["legal-compliance"], when: "policy violation or compliance gap" }
    - { type: "finding", to: ["code-reviewer"], when: "security pattern to enforce in code reviews" }
    - { type: "finding", to: ["devops-automator"], when: "CI/CD pipeline security issue or hardening needed" }
data:
  entityTypesRead: ["sre_findings", "de_findings", "pipeline_status", "incidents"]
  entityTypesWrite: ["sec_findings", "sec_alerts", "vulnerability_scans"]
  memoryNamespaces: ["working_notes", "learned_patterns", "vulnerability_database", "rotation_schedule"]
zones:
  zone1Read: ["mission", "tech_stack", "security_policy", "compliance_requirements"]
  zone2Domains: ["security", "operations", "engineering"]
egress:
  mode: "restricted"
  allowedDomains: ["nvd.nist.gov", "cve.org", "osv.dev", "api.github.com"]
skills:
  - ref: "skills/scheduled-report@1.0.0"
mcpServers:
  - ref: "tools/github"
    required: false
    reason: "Scans repository code for security vulnerabilities"
  - ref: "tools/exa"
    required: true
    reason: "Search CVE databases and security advisories for vulnerability intelligence"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse NVD, OSV, and security advisory pages for detailed vulnerability analysis"
  - ref: "tools/composio"
    required: false
    reason: "Connect to security tools and ticketing systems for vulnerability tracking"
presence:
  web:
    browsing: true
    search: true
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-github
      name: "Connect GitHub"
      description: "Links your code repositories for vulnerability scanning and dependency analysis"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "Repository access is essential for code security scanning and dependency CVE checks"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
        helpUrl: "https://docs.schemabounce.com/integrations/github"
    - id: set-security-policy
      name: "Define security policy"
      description: "Set your organization's security policy baseline for vulnerability assessment"
      type: north_star
      key: security_policy
      group: configuration
      priority: required
      reason: "Cannot evaluate findings without a defined security policy — severity thresholds and acceptable risk vary by org"
      ui:
        inputType: select
        options:
          - { value: strict, label: "Strict (zero tolerance for medium+ CVEs)" }
          - { value: standard, label: "Standard (critical and high only)" }
          - { value: risk_based, label: "Risk-based (weighted by exploitability)" }
        default: standard
    - id: set-tech-stack
      name: "Declare tech stack"
      description: "List your primary languages, frameworks, and infrastructure so CVE monitoring is targeted"
      type: north_star
      key: tech_stack
      group: configuration
      priority: required
      reason: "CVE monitoring without tech stack context produces noise — targeted scanning reduces false positives"
      ui:
        inputType: text
        placeholder: "e.g., Go, Node.js, PostgreSQL, Kubernetes, AWS"
    - id: set-compliance-requirements
      name: "Set compliance requirements"
      description: "Regulatory frameworks that apply to your organization"
      type: north_star
      key: compliance_requirements
      group: configuration
      priority: recommended
      reason: "Compliance context shapes which findings are policy violations vs informational"
      ui:
        inputType: select
        options:
          - { value: soc2, label: "SOC 2 Type II" }
          - { value: pci_dss, label: "PCI DSS" }
          - { value: hipaa, label: "HIPAA" }
          - { value: gdpr, label: "GDPR" }
          - { value: none, label: "No specific framework" }
        default: none
    - id: set-rotation-policy
      name: "Set secret rotation schedule"
      description: "How frequently secrets and credentials should be rotated"
      type: config
      group: configuration
      target: { namespace: rotation_schedule, key: rotation_interval_days }
      priority: recommended
      reason: "Rotation tracking requires knowing the expected interval to flag overdue secrets"
      ui:
        inputType: select
        options:
          - { value: 30, label: "30 days (strict)" }
          - { value: 60, label: "60 days (standard)" }
          - { value: 90, label: "90 days (relaxed)" }
        default: 90
    - id: import-findings
      name: "Import existing security findings"
      description: "Prior scan results establish a vulnerability baseline and track remediation progress"
      type: data_presence
      entityType: sre_findings
      minCount: 10
      group: data
      priority: recommended
      reason: "Baseline findings prevent re-alerting on known issues and enable trend tracking"
      ui:
        actionLabel: "Import Findings"
        emptyState: "No prior security findings found. The bot will establish baselines from its first scan."
        helpUrl: "https://docs.schemabounce.com/data/import"
goals:
  - name: vulnerability_detection
    description: "Identify and classify security vulnerabilities from infrastructure and code findings"
    category: primary
    metric:
      type: count
      entity: sec_findings
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when new findings exist from SRE, data, or code review"
  - name: critical_response_time
    description: "Critical vulnerabilities escalated within the same run they are detected"
    category: primary
    metric:
      type: boolean
      check: critical_escalation_sent
    target:
      operator: "=="
      value: true
      period: per_run
      condition: "when critical findings detected"
  - name: rotation_compliance
    description: "All tracked secrets rotated within policy threshold"
    category: secondary
    metric:
      type: rate
      numerator: { entity: sec_findings, filter: { finding_type: "rotation_overdue" } }
      denominator: { entity: sec_findings, filter: { finding_type: "rotation_tracked" } }
    target:
      operator: "<"
      value: 0.10
      period: monthly
  - name: vulnerability_trend_tracking
    description: "Maintain running vulnerability counts by severity for trend analysis"
    category: health
    metric:
      type: count
      source: memory
      namespace: vulnerability_database
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "updated each run"
---

# Security Agent

Monitors security posture, tracks vulnerabilities, audits policy compliance, and identifies exposure risks. Acts as a continuous pen-test analyst that never sleeps.

## What It Does

- Audits infrastructure findings from SRE for security implications (open ports, misconfigs, weak TLS)
- Tracks CVE exposure based on known tech stack components
- Monitors secret rotation schedules and flags overdue rotations
- Reviews pipeline configurations for data exposure risks (unencrypted sinks, public endpoints)
- Checks access patterns for anomalies (unusual API key usage, privilege escalation signals)
- Maintains a vulnerability database in private memory for trend analysis

## Escalation Behavior

- **Critical**: Active exploit, data exposure, unpatched critical CVE → alerts executive-assistant
- **High**: Policy violation, overdue secret rotation → finding to legal-compliance
- **Medium**: Infrastructure hardening opportunity → finding to sre-devops
- **Low**: Informational CVE tracking, posture improvement notes → memory update only
