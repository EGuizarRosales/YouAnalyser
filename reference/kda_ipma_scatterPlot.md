# Create an Importance-Performance Matrix Analysis scatter plot

A short description...

## Usage

``` r
kda_ipma_scatterPlot(
  model,
  ipma_obj,
  show_labels = TRUE,
  quadrant_colors = c(`Concentrate here` = yougov_colors[["Red 1"]],
    `Keep up the good work` = yougov_colors[["Purple 1"]], `Possible overkill` =
    yougov_colors[["Teal 1"]], `Low priority` = yougov_colors[["Blue 1"]])
)
```

## Arguments

- model:

  A fitted model object.

- ipma_obj:

  An IPMA results object, i.e., the output from
  [`kda_ipma()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_ipma.md).

- show_labels:

  Optional. A logical indicating whether to display predictor labels on
  the plot. Defaults to `TRUE`.

- quadrant_colors:

  Optional. A named character vector of colors for the four quadrants.
  Defaults to a set of predefined colors.

## Value

A list containing:

- `d`: A data frame with the plot data

- `p`: A ggplot2 plot object

## Examples

``` r
# Fit a model
m <- lm(F600 ~ ., data = bkw_processed)
#> Error in vec_arith("-", e1, e2): <haven_labelled> - <haven_labelled> is not permitted
# Fit importance and performance objects
importance_obj <- kda_importance_jrw(m)
#> Error: object 'm' not found
performance_obj <- kda_performance(m)
#> Error: object 'm' not found
ipma_obj <- kda_ipma(importance_obj, performance_obj)
#> Error: object 'importance_obj' not found
# Create IPMA scatter plot
ipma_plot <- kda_ipma_scatterPlot(m, ipma_obj)
#> Error: object 'm' not found
# Access IPMA plot
print(ipma_plot$p)
#> Error: object 'ipma_plot' not found
```
