---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: data-transform
  displayName: Data Transform
  version: 1.0.0
  description: Parse, validate, transform, and merge structured data
  category: Data Processing
  tags: [csv, json, xml, yaml, etl, transform, validate, merge, pivot, deduplicate]
  icon: transform
tools:
  - name: format_data
    description: Auto-detect input format and normalize to structured JSON
    category: parsing
  - name: parse_csv
    description: Parse CSV with configurable delimiters and type inference
    category: parsing
  - name: parse_json
    description: Parse JSON and extract with dot-notation path
    category: parsing
  - name: parse_xml
    description: Parse XML to JSON representation
    category: parsing
  - name: parse_yaml
    description: Parse YAML to JSON
    category: parsing
  - name: validate_schema
    description: Validate data against a JSON Schema definition
    category: validation
  - name: transform_data
    description: Transform data with select, rename, filter, map, and sort operations
    category: transform
  - name: merge_datasets
    description: Join two datasets on a key with inner, left, right, or full join
    category: transform
  - name: deduplicate
    description: Remove duplicate objects from array by key fields
    category: transform
  - name: pivot_table
    description: Pivot rows to columns with aggregation
    category: transform
  - name: flatten_nested
    description: Flatten nested objects to dot-notation keys
    category: transform
  - name: enrich_data
    description: Pattern guide for enriching data from ADL records
    category: transform
  - name: generate_sample_data
    description: Generate synthetic test data from a field schema
    category: generation
  - name: diff_datasets
    description: Compare two datasets and return added, removed, and changed records
    category: analysis
  - name: convert_units
    description: Convert between units of measurement
    category: conversion
---

# Data Transform

Parse, validate, transform, and merge data in any format. All tools are deterministic Go functions — fast (<10ms), zero LLM tokens, fully reproducible.

This is the most universally useful tool pack. Any agent that processes structured data should include it.

## Use Cases

- Parse CSV bank statements for financial analysis
- Validate incoming webhook payloads against a schema
- Merge customer data from two sources on a shared key
- Deduplicate records before writing to the ADL
- Pivot time-series data for reporting
- Generate synthetic test data for development

## Tools

### format_data
Auto-detect whether input is CSV, JSON, XML, or YAML and normalize to structured JSON.

### parse_csv
Parse CSV content with configurable delimiter, header detection, and automatic type inference for numbers and booleans.

### parse_json
Parse and validate JSON strings. Optionally extract nested values using dot-notation paths (e.g., `data.users.0.name`).

### parse_xml
Convert XML documents to a JSON representation with element names as keys and text content as values.

### parse_yaml
Parse YAML content to JSON. Handles basic YAML structures including nested objects and arrays.

### validate_schema
Validate data against a JSON Schema definition. Checks types, required fields, string length constraints, and numeric ranges.

### transform_data
Apply transformation operations to data: select specific fields, rename fields, filter arrays by conditions, map transformations, and sort by field values.

### merge_datasets
Join two arrays of objects on a shared key field. Supports inner, left, right, and full outer joins.

### deduplicate
Remove duplicate objects from an array based on one or more key fields. Returns the deduplicated array and count of removed duplicates.

### pivot_table
Pivot tabular data from rows to columns with aggregation (sum, count, average, or first value).

### flatten_nested
Flatten deeply nested objects into a single-level object with dot-notation keys. Configurable separator and max depth.

### enrich_data
Helper that documents the pattern for enriching data using ADL records. Use `adl_query_records` to fetch lookup data, then `merge_datasets` to join.

### generate_sample_data
Generate synthetic test data from a field schema definition. Supports string, int, float, bool, email, date, and uuid field types. Deterministic when a seed is provided.

### diff_datasets
Compare two arrays of objects by key fields and return added, removed, and changed records with detailed change tracking.

### convert_units
Convert between units of measurement: length (m, km, mi, ft, in, cm, mm), weight (kg, g, lb, oz), temperature (C, F, K), volume (L, mL, gal), and data (B, KB, MB, GB, TB).
