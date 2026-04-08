---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: web-toolkit
  displayName: Web Toolkit
  version: 1.0.0
  description: Fetch URLs, call APIs, parse HTML, and work with web protocols
  category: Web
  tags: [http, api, html, url, webhook, rss, dns, encoding]
  icon: web
tools:
  - name: fetch_url
    description: Fetch the content of a URL and return the response body and headers
    category: http
  - name: call_api
    description: Make an HTTP request with configurable method, headers, and body
    category: http
  - name: parse_html
    description: Parse HTML and extract elements using CSS selectors
    category: parsing
  - name: validate_url
    description: Validate URL syntax and optionally check reachability
    category: validation
  - name: encode_decode
    description: Encode or decode strings using Base64, URL encoding, or HTML entities
    category: encoding
  - name: generate_webhook_payload
    description: Build a structured webhook payload conforming to common formats
    category: generation
  - name: parse_rss
    description: Parse an RSS or Atom feed and return structured entries
    category: parsing
  - name: dns_lookup
    description: Perform DNS lookups for A, AAAA, MX, CNAME, and TXT records
    category: network
---

# Web Toolkit

Fetch URLs, call APIs, parse HTML, and work with web protocols. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent that integrates with external services, scrapes content, or processes web data.

## Use Cases

- Fetch and parse HTML pages for data extraction
- Call external REST APIs with custom headers and authentication
- Validate URLs before adding them to documents or databases
- Parse RSS feeds to monitor content sources
- Encode/decode data for API payloads

## Tools

### fetch_url
Fetch the content of a URL via GET request. Returns status code, response headers, and body.

### call_api
Make HTTP requests with configurable method (GET, POST, PUT, DELETE), headers, query parameters, and JSON body.

### parse_html
Parse an HTML document and extract elements matching CSS selectors. Returns text content and attributes.

### validate_url
Check that a URL is syntactically valid and optionally verify that it returns a successful HTTP status.

### encode_decode
Encode or decode strings using Base64, URL encoding, or HTML entity encoding/decoding.

### generate_webhook_payload
Build a structured webhook payload conforming to common formats (Slack, Discord, generic JSON).

### parse_rss
Parse RSS 2.0 or Atom feed XML and return an array of structured entries with title, link, date, and summary.

### dns_lookup
Perform DNS queries for a domain. Supports A, AAAA, MX, CNAME, TXT, and NS record types.
