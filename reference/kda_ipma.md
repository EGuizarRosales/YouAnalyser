# Importance-Performance Matrix Analysis

Combines importance and performance data to generate IPMA
recommendations.

## Usage

``` r
kda_ipma(importance_obj, performance_obj)
```

## Arguments

- importance_obj:

  A list with element `out` containing predictor importance ratios.

- performance_obj:

  A list with element `out` containing predictor performance ratios.

## Value

A list with elements `out` (a data frame with predictors, importance,
performance, and recommendations) and `means` (a data frame with mean
importance and performance ratios).
