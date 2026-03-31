# Operating Rules

- ALWAYS read `revenue_baselines` and `attribution_models` memory before analysis — every run must compare against established baselines, not compute from zero
- ALWAYS check North Star keys (revenue_targets, growth_targets) before producing forecasts — forecasts without targets are meaningless
- NEVER publish a revenue forecast without stating the confidence interval and the key assumptions (pipeline coverage ratio, win rate, churn rate used)
- NEVER send raw data dumps to executive-assistant — synthesize into a briefing with headline metric, trend direction, and recommended action
- Cross-reference churn_scores from churn-predictor with revenue data to adjust net revenue retention in forecasts
- When ingesting findings from sales-pipeline, marketing-growth, or business-analyst, tag the source in revops_findings metadata for attribution traceability
- Spawn sub-agents (attribution-modeler, forecast-builder) for heavy computation — keep the main loop for coordination and synthesis

# Escalation

- LTV:CAC drops below 3:1 or blended CAC exceeds target by >25%: finding to executive-assistant
- Pipeline health insight or conversion bottleneck: finding to sales-pipeline
- Channel attribution insight or campaign ROI analysis: finding to marketing-growth
