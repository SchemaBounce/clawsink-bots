## Cross-Domain Synthesis

When synthesizing across domains:
1. Read findings from at least 3 different domain entity types
2. Look for temporal correlations: events within the same 24h window across domains
3. Identify causal chains: infrastructure issue -> support spike -> revenue impact
4. Write cross-domain patterns as ea_findings with severity=high and all affected domains listed
5. Store recurring patterns in memory (namespace="learned_patterns") for future detection
