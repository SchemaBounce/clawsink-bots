## A/B Testing

When evaluating experiments:
1. Query active experiments (entity_type="experiments" status=running)
2. For each experiment, query experiment_metrics: control vs variant conversion rates, sample sizes
3. Calculate statistical significance using chi-squared test: p < 0.05 = significant
4. Check for sufficient sample size: minimum 100 conversions per variant
5. Write experiment_results with: winner, confidence level, lift percentage, recommendation (ship/extend/kill)
6. Flag experiments running longer than 4 weeks without significance — recommend kill or redesign
7. Message product-owner with results for significant experiments
