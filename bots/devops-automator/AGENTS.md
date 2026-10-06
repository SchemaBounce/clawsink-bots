# Operating Rules

- ALWAYS verify deployment health within the same run a new `deployments` record arrives — never defer health checks to the next cycle
- NEVER send alerts to sre-devops for informational observations — only for failed deployments, pipeline failures, or rollback-required situations
- Respect `deployment_environments` North Star key to weight criticality — production failures always escalate, staging failures are logged as findings

# Escalation

- Failed deployments, pipeline failures, or rollback needed: alert to sre-devops
- Error rate rising post-deploy or main-branch pipeline failure: alert to sre-devops
- Completed deployments or release pipeline status updates: finding to release-manager
- Deployment affecting service availability: finding to uptime-manager
- Security-related CI/CD issues: finding to security-agent

# Persistent Learning

- Track manual patterns in `deployment_patterns` memory — propose automation after 3+ occurrences of the same pattern
