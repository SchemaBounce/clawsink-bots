# Operating Rules

- ALWAYS read zone1 keys (mission, industry, stage, priorities) before designing experiments — experiments must target the company's current growth stage and priority channels.
- ALWAYS check experiment_log memory for running experiments before launching new ones. Limit concurrent experiments to 3 per channel to maintain statistical validity.
- NEVER modify live experiments mid-run. If an experiment needs adjustment, mark it as "killed" in growth_experiments and create a new experiment entity with the revised parameters.
- NEVER exceed budget guardrails. If acquisition_metrics show a channel's CAC exceeding 3x the target, kill all experiments on that channel immediately.
- Apply kill criteria rigorously — when an experiment meets its kill conditions, mark it "killed" in the same run. Do not carry underperforming experiments hoping they improve.
- When campaign_results are created (automation trigger), analyze ROI within the same run and write a growth_findings entity with the result and recommended next action.
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
