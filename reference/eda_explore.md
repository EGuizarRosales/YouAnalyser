# Explore data interactively

Opens a Shiny gadget (in the viewer pane by default) to explore the
variables of a data set: select variables by name or label (or by a
pattern, e.g. a whole item battery), choose a grouping variable (e.g. a
cluster solution) and an optional weight, and get

- plots of all selected variables in one plot
  ([`eda_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot.md)):
  horizontal or vertical bar charts of the means with or without error
  bars, boxplots, or stacked bar charts of the distributions;

- descriptive statistics
  ([`eda_describe()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_describe.md));

- tests of group differences
  ([`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md),
  see "Statistical tests" there), comparing each group with the total
  (default), the rest of the sample, the mean of the group means, or all
  other groups;

- if `ggstatsplot` is installed, a detailed plot of a single variable
  with the test results
  ([`eda_plot_detail()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot_detail.md);
  "Detailed plot" tab, customizable in the sidebar);

- a codebook with the variable and value labels;

- the code to reproduce the plot and the statistics in a script.

The plots can be downloaded as JPEG
([`ya_save_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_save_plot.md),
300 dpi) and the statistics as Excel file. Click "Done" to close the
gadget and return them to the console.

## Usage

``` r
eda_explore(data = NULL, viewer = c("pane", "browser", "dialog"))
```

## Arguments

- data:

  Optional. A data frame or the output of
  [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md)
  to show first. If `NULL` (default), the first data frame in the global
  environment is shown; all others can be selected in the gadget.

- viewer:

  Where to show the gadget: `"pane"` (RStudio/Positron viewer pane,
  default), `"browser"` or `"dialog"`.

## Value

Invisibly, when closed with "Done": a list with `plot` (ggplot),
`describe`
([`eda_describe()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_describe.md)
output) and `code` (character, the code to reproduce them). `NULL` if no
variables were selected.

## Details

The gadget lists all data frames and
[`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md)
outputs in the global environment. For a `seg_cluster` or
`seg_cluster_set`, the original data of the clustered respondents is
shown and each cluster solution is available as grouping variable (e.g.
`cluster_k4`), see
[`eda_describe()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_describe.md).

Requires the packages `shiny`, `bslib` and `DT`; `ggstatsplot` is
optional.

## See also

Other eda:
[`eda_describe()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_describe.md),
[`eda_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot.md),
[`eda_plot_detail()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot_detail.md),
[`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md)

## Examples

``` r
if (FALSE) { # interactive()
eda_explore(sm_synthetic)

# With a cluster solution as grouping variable
prep <- seg_prep_data(sim_segments, vars = dplyr::starts_with("item_"), verbose = FALSE)
km <- seg_cluster(prep, k = 2:4, plots = FALSE, verbose = FALSE)
eda_explore(km)
}
```
