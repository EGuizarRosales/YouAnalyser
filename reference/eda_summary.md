# Exploratory data analysis: Summary of data

Generate a summary table of the data, including variable types, missing
values, and basic statistics. The summary is displayed in the browser
for easy inspection.

## Usage

``` r
eda_summary(
  data,
  variables = NULL,
  console_output = TRUE,
  browser_output = TRUE,
  describe_distribution_args = list(iqr = FALSE, quartiles = TRUE, by = NULL)
)
```

## Arguments

- data:

  A data frame to be inspected.

- variables:

  An optional vector of variable names to include in the inspection. If
  NULL, all variables are included.

- console_output:

  A logical value indicating whether to print descriptive statistics in
  the console. Defaults to TRUE.

- browser_output:

  A logical value indicating whether to display the summary table in the
  browser. Defaults to TRUE.

- describe_distribution_args:

  A list of additional arguments passed to
  [`datawizard::describe_distribution()`](https://easystats.github.io/datawizard/reference/describe_distribution.html).

- dfSummary_args:

  A list of additional arguments passed to
  [`summarytools::dfSummary()`](https://rdrr.io/pkg/summarytools/man/dfSummary.html).

## Value

A temporary html summary table of the data, which is displayed in the
browser.

## Examples

``` r
# Inspect a subset of variables in the data
eda_summary(data = bkw_raw, variables = c("F600", "F800_1", "F800_2"), console_output = TRUE, browser_output = TRUE)
#> Warning: no DISPLAY variable so Tk is not available
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> 
#> ── Data Frame Summary ──────────────────────────────────────────────────────────
#> ℹ Summary table is displayed in the browser. Please check your browser windows or tabs.
#> 
#> ── Descriptive Statistics ──────────────────────────────────────────────────────
#> Variable | Mean |   SD |        Range |  Quartiles | Skewness | Kurtosis |    n | n_Missing
#> -------------------------------------------------------------------------------------------
#> F600     | 4.34 | 1.36 | [1.00, 7.00] | 4.00, 5.00 |    -0.28 |     0.35 | 1216 |      4307
#> F800_1   | 5.14 | 1.32 | [1.00, 7.00] | 4.00, 6.00 |    -0.51 |     0.12 | 1216 |      4307
#> F800_2   | 4.79 | 1.23 | [1.00, 7.00] | 4.00, 6.00 |    -0.27 |     0.37 | 1216 |      4307
```
