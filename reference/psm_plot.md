# Plot Price Sensitivity Meter (van Westendorp) results

Creates the classic van Westendorp price sensitivity meter plot (with
the four cumulative distribution curves, the indifference price point,
the optimal price point, and the acceptable price range), plus, when the
Newton-Miller-Smith (NMS) extension was used, the reach and revenue
optimization plots.

## Usage

``` r
psm_plot(output_psm, xlim = NULL, currency_prefix = "CHF ")
```

## Arguments

- output_psm:

  A list as returned by
  [`pricesensitivitymeter::psm_analysis()`](https://max-alletsee.github.io/pricesensitivitymeter/reference/psm_analysis.html)
  or
  [`pricesensitivitymeter::psm_analysis_weighted()`](https://max-alletsee.github.io/pricesensitivitymeter/reference/psm_analysis_weighted.html).

- xlim:

  Numeric vector of length 2 giving the x-axis (price) limits passed to
  [`ggplot2::coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html).
  Defaults to `NULL`, i.e. the full price range of the data.

- currency_prefix:

  String prefixed to the price axis labels via
  [`scales::label_currency()`](https://scales.r-lib.org/reference/label_currency.html).
  Defaults to `"CHF "`.

## Value

A named list of `ggplot` objects: `psm` (the price sensitivity meter
plot), `nms_reach` and `nms_revenue` (the NMS reach and revenue plots,
or `NULL` if `output_psm$nms` is `FALSE`).

## Examples

``` r
if (FALSE) { # \dontrun{
psm_nms <- psm_analysis(
 data = as.data.frame(chm_synthetic),
 toocheap = "tooCheap",
 cheap = "cheap",
 expensive = "expensive",
 tooexpensive = "tooExpensive",
 pi_cheap = "purchaseIntentionCheap",
 pi_expensive = "purchaseIntentionExpensive",
 validate = TRUE
)
plots <- psm_plot(psm_result)
plots$psm
} # }
```
