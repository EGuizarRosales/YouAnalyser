# Create a forest plot for model coefficients

A short description...

## Usage

``` r
kda_forestPlot(model, model_parameters_args = list())
```

## Arguments

- model:

  A fitted regression model.

- model_parameters_args:

  Optional. A list of additional arguments passed to
  [`parameters::model_parameters()`](https://easystats.github.io/parameters/reference/model_parameters.html).

## Value

A list with elements `d` (a data frame of plot data) and `p` (a ggplot2
object).
