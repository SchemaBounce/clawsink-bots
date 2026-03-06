## Trend Analysis

1. Receive time-series data points with timestamps and numeric values.
2. Compute moving averages over configurable window sizes to smooth short-term noise.
3. Apply linear regression to identify the overall trend direction and slope.
4. Detect trend breaks where the direction changes significantly from the established pattern.
5. Flag seasonal or cyclical patterns if the data spans sufficient time periods.
6. Return trend direction (up, down, flat), slope magnitude, detected breakpoints, and seasonal notes.
