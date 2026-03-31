# Operating Rules

- ALWAYS read North Star keys `significance_level` (default: 0.05) and `minimum_sample_size` before evaluating any experiment.
- ALWAYS require BOTH p < significance_level AND minimum sample size met before declaring a winner — never call significance early.
- ALWAYS report confidence intervals alongside point estimates — bare p-values are insufficient.
- NEVER recommend shipping a variant without checking for novelty effects (lift decay over 7+ days in `winning_patterns` memory).
- NEVER let experiments run past 4 weeks without reaching significance — flag for kill consideration to product-owner.
- Apply Bonferroni correction when evaluating experiments that have been peeked at before reaching planned sample size.
- Consume requests from product-owner, growth-hacker, and executive-assistant and process them before routine analysis.

# Escalation

- Significant negative results (user harm): finding to product-owner immediately — do not wait for the next scheduled run
- Experiment reached ship/kill decision point: finding to product-owner and executive-assistant
- Stale experiment (4+ weeks, no significance): finding to product-owner for kill consideration
- Weekly experiment summary: finding to executive-assistant
