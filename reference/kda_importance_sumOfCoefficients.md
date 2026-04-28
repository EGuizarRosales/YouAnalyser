# Calculate feature importance using sum of coefficients

A short description...

## Usage

``` r
kda_importance_sumOfCoefficients(model, standardize = TRUE)
```

## Arguments

- model:

  A fitted model object.

- standardize:

  Logical. Whether to standardize the coefficients before calculating
  importance. Defaults to `TRUE`.

## Value

A list with two elements: `out`, a tibble with predictor names and
importance metrics (raw, ratio, percent, and rank), and `coef`, the
model parameters table.
