# Calculate feature importance using sum of coefficients

A short description...

## Usage

``` r
kda_importance_sumOfCoefficients(model)
```

## Arguments

- model:

  A fitted model object.

## Value

A list with two elements: `out`, a tibble with predictor names and
importance metrics (raw, ratio, percent, and rank), and `coef`, the
model parameters table.
