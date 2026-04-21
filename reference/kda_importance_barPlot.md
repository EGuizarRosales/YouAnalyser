# Create KDA importance bar plot

A short description...

## Usage

``` r
kda_importance_barPlot(
  model,
  importance_obj,
  color = yougov_colors[["Red 1"]],
  label_size = 3
)
```

## Arguments

- model:

  A model object.

- importance_obj:

  An importance object, i.e., the output from
  [`kda_importance_sumOfCoefficients()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_sumOfCoefficients.md),
  [`kda_importance_domir()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_domir.md),
  or
  [`kda_importance_jrw()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_jrw.md).

- color:

  Optional. A single string specifying the bar color.

## Value

A list with elements `d` (a data frame of plot data) and `p` (a ggplot2
object).
