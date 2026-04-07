## Trend Analysis

1. Receive time-series data points with timestamps and numeric values.
2. Compute moving averages over configurable window sizes to smooth short-term noise.
3. Apply linear regression to identify the overall trend direction and slope.
4. Detect trend breaks where the direction changes significantly from the established pattern.
5. Flag seasonal or cyclical patterns if the data spans sufficient time periods.
6. Return trend direction (up, down, flat), slope magnitude, detected breakpoints, and seasonal notes.

Anti-patterns:
- NEVER extrapolate from fewer than 4 data points — minimum 4 time periods for any trend claim; fewer is noise.
- NEVER report a trend without the confidence interval or R-squared — consumers need to know how reliable the signal is.
- NEVER flag seasonal patterns from less than 2 full cycles of data — one peak is not a season.
