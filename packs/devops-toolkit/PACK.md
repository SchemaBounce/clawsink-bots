---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: devops-toolkit
  displayName: DevOps Toolkit
  version: 1.0.0
  description: Log parsing, code formatting, diffing, regex testing, and developer utilities
  category: DevOps
  tags: [logging, formatting, diff, regex, uuid, json-patch, cron]
  icon: terminal
tools:
  - name: parse_log
    description: Parse structured and unstructured log lines into timestamp, level, and message fields
    category: logging
  - name: format_code
    description: Format code snippets with consistent indentation and style
    category: formatting
  - name: diff_text
    description: Compute a unified diff between two text inputs
    category: diff
  - name: regex_test
    description: Test a regular expression against sample input and return matches and groups
    category: regex
  - name: generate_uuid
    description: Generate UUIDs in v4 (random) or v7 (time-ordered) format
    category: generation
  - name: base_convert
    description: Convert numbers between decimal, hexadecimal, octal, and binary bases
    category: conversion
  - name: json_patch
    description: Apply JSON Patch (RFC 6902) operations to a JSON document
    category: transform
  - name: cron_validate
    description: Validate a cron expression and check for common syntax errors
    category: validation
---

# DevOps Toolkit

Log parsing, code formatting, diffing, regex testing, and developer utilities. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent working with logs, configuration files, or developer workflows.

## Use Cases

- Parse application logs to extract error patterns and timestamps
- Diff configuration files to identify changes between environments
- Test regex patterns before applying them to production data
- Generate UUIDs for resource identifiers
- Apply JSON Patch operations to API payloads

## Tools

### parse_log
Parse log lines into structured fields (timestamp, level, message, metadata). Supports common log formats (JSON, syslog, Apache).

### format_code
Format code snippets with configurable indentation (spaces/tabs), line width, and language-aware styling.

### diff_text
Compute a unified diff between two text inputs. Returns added, removed, and changed lines with context.

### regex_test
Test a regular expression pattern against sample input. Returns all matches, named capture groups, and match positions.

### generate_uuid
Generate a UUID in v4 (random) or v7 (time-ordered, sortable) format.

### base_convert
Convert numeric values between decimal, hexadecimal, octal, and binary representations.

### json_patch
Apply RFC 6902 JSON Patch operations (add, remove, replace, move, copy, test) to a JSON document.

### cron_validate
Validate cron expression syntax and report errors. Supports standard 5-field and extended 6-field formats.
