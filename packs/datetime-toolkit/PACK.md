---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: datetime-toolkit
  displayName: Date & Time Toolkit
  version: 1.0.0
  description: Date calculations, timezone conversions, scheduling, and business day logic
  category: Utilities
  tags: [date, time, timezone, cron, scheduling, business-days, holiday]
  icon: calendar
tools:
  - name: calculate_date
    description: Add or subtract days, weeks, months, or years from a date
    category: calculation
  - name: convert_timezone
    description: Convert a datetime between timezones
    category: conversion
  - name: business_days
    description: Calculate the number of business days between two dates excluding weekends and holidays
    category: calculation
  - name: parse_date
    description: Parse a date string in any common format and normalize to ISO 8601
    category: parsing
  - name: cron_explain
    description: Explain a cron expression in plain language and list next N execution times
    category: scheduling
  - name: schedule_optimizer
    description: Find optimal meeting times across multiple timezones and availability windows
    category: scheduling
  - name: date_range_generate
    description: Generate a sequence of dates between start and end with a configurable step
    category: generation
  - name: holiday_check
    description: Check whether a given date is a public holiday for a specified country
    category: lookup
---

# Date & Time Toolkit

Date calculations, timezone conversions, scheduling, and business day logic. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent that handles scheduling, deadline tracking, or time-sensitive calculations.

## Use Cases

- Calculate business days between order and delivery dates
- Convert meeting times across team timezones
- Explain cron schedules in human-readable terms
- Generate date ranges for reporting periods
- Check if a date falls on a public holiday

## Tools

### calculate_date
Add or subtract days, weeks, months, or years from a date. Returns the resulting date in ISO 8601 format.

### convert_timezone
Convert a datetime value from one timezone to another. Accepts IANA timezone identifiers.

### business_days
Count business days between two dates, excluding weekends and optionally specified holidays.

### parse_date
Parse date strings in common formats (ISO, US, European, natural language) and normalize to ISO 8601.

### cron_explain
Parse a cron expression and return a plain-language explanation plus the next N scheduled execution times.

### schedule_optimizer
Given multiple timezone and availability constraints, find overlapping windows suitable for meetings.

### date_range_generate
Generate an array of dates from start to end with a configurable step (daily, weekly, monthly, quarterly).

### holiday_check
Check whether a date is a recognized public holiday for a given country code.
