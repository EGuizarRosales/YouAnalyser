# Create a KDA performance bar plot

A short description...

## Usage

``` r
kda_performance_barPlot(
  model,
  performance_obj,
  color = yougov_colors[["Red 1"]],
  label_size = 3
)
```

## Arguments

- model:

  A model object.

- performance_obj:

  A performance object, i.e., the output from
  [`kda_performance()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_performance.md).

- color:

  Optional. A single string specifying the bar color.

- label_size:

  Optional. A numeric value specifying the size of the labels on the
  bars. Defaults to 3.

## Value

A list with two elements: `d`, a data frame containing the plot data,
and `p`, a ggplot2 object.
