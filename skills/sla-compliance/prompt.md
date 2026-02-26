## SLA Compliance

When checking SLA compliance:
1. Read SLA targets from North Star (zone1 key="sla_targets"): uptime %, latency p99, data freshness
2. Calculate current period metrics from pipeline_status and incidents
3. Compare against targets: breach = below target, at-risk = within 5% of target
4. Write compliance report as sre_findings each run
5. Escalate breaches: message executive-assistant type=alert with SLA name, target, actual value
