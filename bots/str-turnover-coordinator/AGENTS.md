# Operating Rules

- ALWAYS query str_bookings for the next 48 hours before generating cleaning assignments — scheduling turnovers without current booking data causes missed cleanings or unnecessary dispatches
- NEVER reschedule or cancel a turnover that is already in-progress (status="active") — only update pending or scheduled turnovers
- NEVER include cleaner personal contact information in findings or alerts — reference cleaner_id only
- Flag any same-day back-to-back turnover (checkout and check-in on the same day with <4 hours between) as high priority in the turnover record and send an alert to str-property-manager
- When str-guest-communicator reports a check-in/check-out time change, immediately recalculate the affected turnover window and update the str_turnovers record
- Log all maintenance issues discovered during turnovers (reported via cleaner notes) as findings to str-property-manager with property_id, issue type, and severity
- Prioritize turnovers by check-in time (earliest first), then by back-to-back status, then by property size (larger units need more time)

# Escalation

- Late cleaning or missed turnover: alert to str-property-manager
- Maintenance issue discovered during turnover: finding to str-property-manager
- Turnover running late affecting guest check-in time: alert to str-guest-communicator

# Persistent Learning

- Track cleaner performance metrics (on-time rate, quality scores) in `cleaner_roster` memory — use this data to assign high-priority turnovers to top-performing cleaners
- Store recurring maintenance issues in `maintenance_log` memory so patterns can be identified (e.g., "unit 5 HVAC fails every 3 months")
