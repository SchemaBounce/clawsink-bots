---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: finance-team
  displayName: "Finance"
  version: "1.0.0"
  description: "Finance automation covering accounting, reporting, revenue analysis, and fraud detection for data-driven financial operations"
  domain: finance
  category: finance
  tags: ["finance", "accounting", "revenue", "fraud-detection", "reporting", "budgeting"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/accountant@1.0.0"
  - ref: "bots/executive-reporter@1.0.0"
  - ref: "bots/revenue-analyst@1.0.0"
  - ref: "bots/fraud-detector@1.0.0"
dataKits:
  - ref: "data-kits/finance@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Finance"
  context: "Finance team automating accounting, executive reporting, revenue analysis, and fraud detection for a growing business"
  requiredKeys:
    - fiscal_year_start
    - reporting_currency
    - chart_of_accounts
    - budget_owner
    - fraud_thresholds
    - reporting_cadence
orgChart:
  lead: accountant
  domains:
    - name: "Accounting"
      description: "Bookkeeping, reconciliation, and period close"
      head: accountant
    - name: "Revenue"
      description: "Revenue tracking, forecasting, and trend analysis"
      head: revenue-analyst
    - name: "Risk"
      description: "Fraud detection and financial risk monitoring"
      head: fraud-detector
    - name: "Reporting"
      description: "Executive dashboards and financial summaries"
      head: executive-reporter
  roles:
    - bot: accountant
      role: lead
      reportsTo: null
      domain: accounting
    - bot: executive-reporter
      role: specialist
      reportsTo: accountant
      domain: reporting
    - bot: revenue-analyst
      role: specialist
      reportsTo: accountant
      domain: revenue
    - bot: fraud-detector
      role: specialist
      reportsTo: accountant
      domain: risk
  escalation:
    critical: accountant
    unhandled: accountant
    paths:
      - name: "Fraud Alert"
        trigger: "fraud_detected"
        chain: [fraud-detector, accountant]
      - name: "Budget Overrun"
        trigger: "budget_exceeded"
        chain: [accountant]
      - name: "Revenue Anomaly"
        trigger: "revenue_anomaly"
        chain: [revenue-analyst, accountant]
      - name: "Reporting Deadline"
        trigger: "report_overdue"
        chain: [executive-reporter, accountant]
---
# Finance

Four bots covering core financial operations: bookkeeping and reconciliation, executive financial reporting, revenue trend analysis, and fraud detection. Built for finance teams that need accurate data without manual spreadsheet work.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Accountant | Bookkeeping, reconciliation, period close coordination | @daily |
| Executive Reporter | Board and executive financial summaries and dashboards | @weekly |
| Revenue Analyst | Revenue trends, cohort analysis, and forecasting | @daily |
| Fraud Detector | Transaction anomaly detection and fraud alerting | @every 1h |

## How They Work Together

The Accountant leads all financial operations, maintaining the books and coordinating period close. The Revenue Analyst monitors revenue trends and surfaces anomalies, feeding data to the Accountant for reconciliation and to the Executive Reporter for board-ready summaries. The Fraud Detector runs continuous scans on transactions, escalating suspicious patterns immediately. The Executive Reporter synthesizes signals from all three bots into weekly and monthly financial packages for leadership.

**Communication flow:**
- Revenue Analyst detects anomaly -> alert to Accountant
- Revenue Analyst publishes monthly analysis -> finding to Executive Reporter
- Fraud Detector flags suspicious transaction -> alert to Accountant
- Accountant closes period -> finding to Executive Reporter
- Executive Reporter needs revenue data -> request to Revenue Analyst
- Accountant detects budget overrun -> alert to Executive Reporter

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `fiscal_year_start`, `reporting_currency`, `chart_of_accounts`, `budget_owner`, `fraud_thresholds`, `reporting_cadence`
3. Bots begin running on their default schedules automatically
4. Check the Accountant's daily briefings for consolidated financial health
