# Conduct KDA regression analysis

A short description...

## Usage

``` r
kda_regression(
  data = NULL,
  outcome = NULL,
  predictors = NULL,
  model = NULL,
  diagnostics = FALSE,
  importance_method = "auto",
  importance_barPlot_args = list(),
  performance_barPlot_args = list(),
  ipma_scatterPlot_args = list()
)
```

## Arguments

- data:

  A data frame containing the outcome and predictors. Optional if
  `model` is provided.

- outcome:

  A single string naming the outcome variable. Optional if `model` is
  provided.

- predictors:

  A character vector of predictor variable names. Optional if `model` is
  provided.

- model:

  A fitted regression model object. Optional if `data`, `outcome`, and
  `predictors` are provided.

- diagnostics:

  A logical indicating whether to compute model diagnostics. Defaults to
  `FALSE`.

- importance_method:

  One of `"auto"`, `"domir"`, `"jrw"`, or `"sumOfCoefficients"`.
  Defaults to `"auto"`.

- importance_barPlot_args:

  Optional. A list of additional arguments passed to the importance bar
  plot function. See
  [`kda_importance_barPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_barPlot.md)
  for details..

- performance_barPlot_args:

  Optional. A list of additional arguments passed to the performance bar
  plot function. See
  [`kda_performance_barPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_performance_barPlot.md)
  for details..

- ipma_scatterPlot_args:

  Optional. A list of additional arguments passed to the IPMA scatter
  plot function. See
  [`kda_ipma_scatterPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_ipma_scatterPlot.md)
  for details..

## Value

A list containing model results, importance measures, performance
metrics, IPMA analysis, and associated plots. Errors if neither `model`
nor all of `data`, `outcome`, and `predictors` are provided.
