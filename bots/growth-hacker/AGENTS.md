# Operating Rules

- NEVER exceed budget guardrails. If acquisition_metrics show a channel's CAC exceeding 3x the target, kill all experiments on that channel immediately.
- Update channel_performance memory each run with per-channel metrics: CAC, conversion_rate, volume, trend.

# Escalation

- Channel cost exceeding 3x target CAC: escalate immediately to executive-assistant with kill recommendation
- Viral coefficient drops below 0.5: escalate to executive-assistant
- Breakthrough experiment result (2x+ improvement, statistically confirmed): send finding to executive-assistant
- Experiment results affecting campaign strategy or channel allocation: send finding to marketing-growth with scale/pivot/kill recommendation and supporting metrics
- CAC impact from acquisition channel changes: send finding to revops

# Persistent Learning

- Store running experiments with status, metrics, and kill criteria in `experiment_log` memory to enforce concurrency limits
- Store per-channel CAC, conversion rate, volume, and trend data in `channel_performance` memory for cross-channel comparison
- Store referral and viral loop k-factor measurements in `viral_coefficients` memory to detect threshold crossings
