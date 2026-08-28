# Build a survey design object for weighted PSM analysis

Wraps
[`survey::svydesign()`](https://rdrr.io/pkg/survey/man/svydesign.html)
with an unclustered design (`ids = ~1`) and weights taken from a column
of `data`, for use with
[`pricesensitivitymeter::psm_analysis_weighted()`](https://max-alletsee.github.io/pricesensitivitymeter/reference/psm_analysis_weighted.html).

## Usage

``` r
psm_design_for_weighted(data, weight_var)
```

## Arguments

- data:

  A data frame containing the price sensitivity meter data and the
  weight column.

- weight_var:

  String giving the name of the column in `data` that holds the survey
  weights.

## Value

A `survey.design` object, as returned by
[`survey::svydesign()`](https://rdrr.io/pkg/survey/man/svydesign.html).

## Examples

``` r
if (FALSE) { # \dontrun{
design <- psm_design_for_weighted(chm_synthetic, weight_var = "weight")
} # }
```
