---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: document-gen
  displayName: Document Generation
  version: 1.0.0
  description: Generate PDFs, reports, emails, and formatted documents from structured data
  category: Content
  tags: [pdf, template, report, email, markdown, chart, table]
  icon: document
tools:
  - name: generate_pdf
    description: Generate a PDF document from structured content blocks
    category: generation
  - name: render_template
    description: Render a template string with variable substitution and conditionals
    category: template
  - name: markdown_to_html
    description: Convert Markdown content to HTML with syntax highlighting support
    category: conversion
  - name: generate_report
    description: Generate a structured report with sections, tables, and summary statistics
    category: generation
  - name: create_table
    description: Build a formatted table from rows and columns with alignment options
    category: formatting
  - name: generate_chart_data
    description: Transform raw data into chart-ready datasets for bar, line, and pie charts
    category: visualization
  - name: compose_email
    description: Compose a structured email with subject, body sections, and attachments metadata
    category: generation
  - name: merge_documents
    description: Merge multiple document sections into a single unified document
    category: transform
  - name: extract_table_from_text
    description: Extract tabular data from unstructured text into rows and columns
    category: extraction
  - name: format_number
    description: Format numbers with locale-aware currency, percentage, or decimal formatting
    category: formatting
---

# Document Generation

Generate PDFs, reports, emails, and formatted documents from structured data. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent that produces business documents, reports, or formatted communications.

## Use Cases

- Generate monthly financial reports from database records
- Render invoice templates with customer and line item data
- Compose formatted email summaries from pipeline metrics
- Convert Markdown documentation to HTML
- Extract tables from unstructured text for further processing

## Tools

### generate_pdf
Generate a PDF document from an array of content blocks (headings, paragraphs, tables, images).

### render_template
Render a template string using variable substitution, conditionals, and loops. Supports Mustache-style syntax.

### markdown_to_html
Convert Markdown to semantic HTML. Supports tables, code blocks with syntax highlighting, and task lists.

### generate_report
Build a structured report with title, sections, embedded tables, and computed summary statistics.

### create_table
Construct a formatted table from headers and row data with configurable column alignment and width.

### generate_chart_data
Transform raw datasets into chart-ready structures for bar, line, pie, and scatter visualizations.

### compose_email
Build a structured email object with subject, greeting, body sections, signature, and attachment metadata.

### merge_documents
Combine multiple document sections or fragments into a single cohesive document with consistent formatting.

### extract_table_from_text
Parse tabular data from plain text or semi-structured input into clean rows and columns.

### format_number
Format numbers with locale-aware rules for currency symbols, thousand separators, decimal places, and percentages.
