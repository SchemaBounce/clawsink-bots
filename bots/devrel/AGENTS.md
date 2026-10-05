# Escalation

- Critical sentiment drop or community backlash event: send finding to executive-assistant
- Recurring friction point requiring product action (3+ developers or 3+ threads): send finding to product-owner with high severity and issue links
- Community growth metrics or engagement trend: send finding to marketing-growth

# Persistent Learning

- Store in-progress analysis notes and pending items in `working_notes` memory to resume context across runs
- Store pattern observations with timestamps in `learned_patterns` memory to prevent duplicate escalation
- Store current metric values (stars, issue response time, active contributors, discussion volume) in `community_baselines` memory for trend detection
- Store friction point names with occurrence counts in `friction_tracker` memory — graduate to finding when count reaches threshold
