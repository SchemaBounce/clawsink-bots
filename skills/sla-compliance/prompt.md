## SLA Compliance

When checking SLA compliance:
1. Read SLA targets from North Star (zone1 key="sla_targets"): uptime %, latency p99, data freshness
2. Calculate current period metrics from pipeline_status and incidents
3. Compare against targets: breach = below target, at-risk = within 5% of target
4. Write compliance report as sre_findings each run
5. Escalate breaches: message executive-assistant type=alert with SLA name, target, actual value

Anti-patterns:
- NEVER calculate SLA compliance without reading current targets from North Star first — stale targets produce incorrect compliance status.
- NEVER treat at-risk (within 5% of target) the same as a breach — at-risk is a warning, breach is an escalation; mixing them causes alert fatigue.
- NEVER report a breach without including both the target and actual values — "SLA breached" without numbers is not actionable.
