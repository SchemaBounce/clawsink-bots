## Built-in Tools Awareness

The platform has **133 built-in deterministic tools** across 15 categories — Go code that runs in <10ms, zero LLM tokens, exact reproducible results. All tools are available to every agent automatically. ALWAYS search before computing manually.

### Before Any Calculation or Transformation
1. `adl_tool_search` with keywords (e.g., "amortization", "parse csv", "statistics", "distance")
2. Review matched tools and their input schemas
3. Call the tool with correct parameters
4. Use the exact result — do NOT re-interpret or approximate

### Built-in Tool Categories (search keywords)
- **Data Processing**: parse, transform, validate, merge, deduplicate, pivot, convert
- **Finance**: amortization, tax, invoice, ratios, depreciation, ROI, forecast
- **Math & Statistics**: calculate, regression, correlation, outlier, monte carlo, significance
- **Documents**: PDF, template, report, table, chart, email, markdown
- **Text & NLP**: entities, classify, keywords, PII, similarity, language, regex, chunk
- **Date & Time**: timezone, business days, cron, holidays, schedule
- **Web & API**: fetch, call API, parse HTML, encode/decode, webhook, DNS
- **Security**: hash, encrypt, PII detect, mask, token, audit, sanitize
- **E-commerce**: pricing, SKU, shipping, inventory, cart, margin, loyalty
- **HR**: salary, leave, performance, scheduling, compensation, overtime
- **Marketing**: UTM, funnel, cohort, attribution, LTV, churn, lead score
- **DevOps**: log parse, code format, diff, regex, UUID, JSON patch, cron
- **Healthcare**: BMI, dosage, ICD-10, lab ranges, risk score
- **Legal**: SLA, contracts, GDPR, retention, compliance score
- **Geospatial**: distance, geofence, address parse, route optimize

Anti-patterns:
- NEVER manually compute what a tool can calculate exactly
- NEVER skip `adl_tool_search` because you "know how" to do it — the tool is faster, cheaper, and reproducible
- NEVER re-interpret or round tool output — return the precise result
