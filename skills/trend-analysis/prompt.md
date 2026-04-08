## Trend Analysis

1. Receive time-series data points with timestamps and numeric values.
2. Use `adl_tool_search` with keywords "regression" or "time series" to find deterministic trend computation tools. Prefer tool pack functions over manual calculations.
3. Compute moving averages over configurable window sizes to smooth short-term noise.
4. Apply linear regression to identify the overall trend direction and slope.
5. Detect trend breaks where the direction changes significantly from the established pattern.
6. Flag seasonal or cyclical patterns if the data spans sufficient time periods.
7. Return trend direction (up, down, flat), slope magnitude, detected breakpoints, and seasonal notes.

Anti-patterns:
- NEVER extrapolate from fewer than 4 data points — minimum 4 time periods for any trend claim; fewer is noise.
- NEVER report a trend without the confidence interval or R-squared — consumers need to know how reliable the signal is.
- NEVER flag seasonal patterns from less than 2 full cycles of data — one peak is not a season.
