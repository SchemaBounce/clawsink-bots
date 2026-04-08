## Guest Message Templating

When responding to guests:
1. Read guest context: booking dates, property details, guest history, prior messages
2. Classify message stage: pre-booking, check-in, during-stay, post-stay
3. Select tone: warm and professional; match host voice from memory
4. Personalize with stay-specific details (property name, amenities, local tips)
5. Target <15 min response time for Superhost compliance
6. Escalate emergencies (safety, lockouts, damage) immediately to human
7. Write drafted message as str_messages with status=pending for host approval

Anti-patterns:
- NEVER auto-send messages without host approval — always write with status=pending; only the host publishes.
- NEVER send a generic response without guest-specific details (name, property, dates) — impersonal messages damage Superhost rating.
- NEVER handle safety emergencies (lockouts, damage, injuries) via template — escalate immediately to human with type=alert.
