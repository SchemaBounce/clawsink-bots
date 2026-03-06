## Anomaly Detection

1. Receive the numeric field values and compute descriptive statistics (mean, standard deviation, quartiles).
2. Apply z-score detection: flag any value where |z| > 3 as an anomaly.
3. Apply IQR detection: flag any value below Q1 - 1.5*IQR or above Q3 + 1.5*IQR.
4. Merge results from both methods, deduplicating flagged records.
5. Classify each anomaly by severity (critical, high, medium, low) based on deviation magnitude.
6. Return a structured list of anomalies with field name, value, method triggered, and severity.
