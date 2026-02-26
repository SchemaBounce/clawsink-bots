## Daily Briefing

When generating briefings:
1. Query all *_findings and *_alerts entity types since last briefing timestamp
2. Rank items: critical alerts first, then by alignment to quarterly priorities (from zone1)
3. Group by domain: operations, finance, support, growth, compliance
4. Write briefing as ea_findings with structured sections: critical items, key metrics, action items
5. Send briefing summary as type=text to all bots
