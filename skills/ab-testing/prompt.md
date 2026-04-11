## A/B Testing

When evaluating experiments:
1. Query active experiments (entity_type="experiments" status=running)
2. Use `adl_tool_search` with keyword "significance" to find the A/B test significance tool. Use it instead of manual chi-squared computation.
3. For each experiment, query experiment_metrics: control vs variant conversion rates, sample sizes
4. Calculate statistical significance using chi-squared test: p < 0.05 = significant
5. Check for sufficient sample size: minimum 100 conversions per variant
6. Write experiment_results with: winner, confidence level, lift percentage, recommendation (ship/extend/kill)
7. Flag experiments running longer than 4 weeks without significance — recommend kill or redesign
8. Message product-owner with results for significant experiments

Anti-patterns:
- NEVER declare a winner before reaching statistical significance (p < 0.05, 100+ conversions per variant) — extend the experiment or kill it.
- NEVER let an experiment run longer than 4 weeks without a decision — if significance isn't reached, the effect size is too small to matter.
- NEVER change experiment parameters mid-run (variants, audience, metrics) — start a new experiment instead.
