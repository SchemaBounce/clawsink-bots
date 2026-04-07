## Turnover Scheduling

When managing turnovers:
1. Query str_bookings to identify checkout/checkin pairs within next 7 days
2. Create str_turnovers records: property, checkout time, checkin time, cleaning window
3. Flag tight turnarounds (<4 hrs) as urgent; notify via message
4. Assign cleaners based on property zone and availability from memory
5. Track turnover status: scheduled, in-progress, completed, issue-reported
6. Escalate maintenance issues (broken items, deep clean needed) to property manager
7. Confirm guest-ready status before next check-in

Anti-patterns:
- NEVER schedule a turnover without verifying the cleaning window (checkout to checkin gap) — overlapping assignments cause guest-facing failures.
- NEVER auto-assign cleaners without checking availability from memory — double-bookings lead to missed turnovers.
- NEVER mark a property as guest-ready without confirmed completion status from the cleaner — premature confirmation causes check-in disasters.
