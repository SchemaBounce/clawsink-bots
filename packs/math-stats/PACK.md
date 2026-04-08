---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: math-stats
  displayName: Math & Stats
  version: 1.0.0
  description: Mathematical calculations, statistical analysis, and hypothesis testing
  category: Analytics
  tags: [math, statistics, regression, correlation, forecasting, testing]
  icon: stats
tools:
  - name: calculate
    description: Evaluate mathematical expressions with support for common functions
    category: math
  - name: statistics_summary
    description: Compute descriptive statistics (mean, median, mode, std dev, quartiles) for a dataset
    category: statistics
  - name: regression_analysis
    description: Perform linear or polynomial regression and return coefficients and R-squared
    category: regression
  - name: correlation_matrix
    description: Compute pairwise correlation coefficients for multiple variables
    category: statistics
  - name: time_series_decompose
    description: Decompose a time series into trend, seasonal, and residual components
    category: forecasting
  - name: outlier_detection
    description: Detect outliers using IQR, Z-score, or modified Z-score methods
    category: analysis
  - name: distribution_fit
    description: Fit data to common probability distributions and rank by goodness of fit
    category: statistics
  - name: monte_carlo_simulate
    description: Run Monte Carlo simulations with configurable distributions and iterations
    category: simulation
  - name: ab_test_significance
    description: Calculate statistical significance for A/B test results using chi-squared or t-test
    category: testing
  - name: percentile_ranking
    description: Rank values within a dataset and return percentile positions
    category: statistics
---

# Math & Stats

Mathematical calculations, statistical analysis, and hypothesis testing. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent performing data analysis, forecasting, or experiment evaluation.

## Use Cases

- Compute descriptive statistics for sales data
- Run regression analysis on marketing spend vs revenue
- Detect outliers in sensor readings or financial transactions
- Evaluate A/B test results for statistical significance
- Decompose time series data to identify seasonal patterns

## Tools

### calculate
Evaluate mathematical expressions including arithmetic, exponents, logarithms, trigonometry, and common constants.

### statistics_summary
Compute mean, median, mode, standard deviation, variance, min, max, and quartiles for a numeric dataset.

### regression_analysis
Fit linear or polynomial regression models to data points. Returns coefficients, R-squared, and predicted values.

### correlation_matrix
Compute Pearson, Spearman, or Kendall correlation coefficients between pairs of numeric variables.

### time_series_decompose
Decompose a time series into trend, seasonal, and residual components using additive or multiplicative models.

### outlier_detection
Identify outliers in a dataset using IQR (1.5x rule), Z-score, or modified Z-score methods. Returns flagged indices.

### distribution_fit
Fit data to normal, log-normal, exponential, Poisson, and uniform distributions. Rank by goodness-of-fit metrics.

### monte_carlo_simulate
Run Monte Carlo simulations with configurable input distributions, iteration count, and output aggregation.

### ab_test_significance
Evaluate A/B test results. Accepts control/variant sample sizes and conversions, returns p-value and confidence interval.

### percentile_ranking
Rank each value in a dataset by percentile position. Supports standard and modified percentile methods.
