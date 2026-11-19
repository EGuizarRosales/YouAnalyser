# Plot the cluster centers of a solution

Plots the profiles of the clusters: the mean of each clustering variable
per cluster (the centers of the solution), as profile lines, bars or a
heatmap. This is the quickest overview of what characterizes each
cluster and the basis for naming the clusters.

## Usage

``` r
seg_plot_centers(
  object,
  type = c("lines", "bars", "heatmap"),
  scale = c("prepared", "original"),
  order = c("data", "difference"),
  total = TRUE,
  axis_labels = c("label", "name", "both"),
  label_width = 40,
  digits = 1
)
```

## Arguments

- object:

  A `seg_cluster` object, e.g. from
  [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md).

- type:

  Type of plot: `"lines"` (default), `"bars"` or `"heatmap"`, see
  "Details".

- scale:

  Scale of the means: `"prepared"` (default) for the prepared (e.g.
  z-standardized) clustering variables or `"original"` for the original
  variables, see "Details".

- order:

  Order of the variables: `"data"` (default) keeps the order of the
  clustering variables, `"difference"` sorts them by the difference
  between the clusters (range of the cluster means on the prepared
  scale), so that the variables that separate the clusters most come
  first.

- total:

  Logical. Whether to show the total mean of all respondents (and a
  "Total" column in the heatmap). Defaults to `TRUE`.

- axis_labels:

  How to label the variables: `"label"` (default) uses the variable
  labels (the names if missing), `"name"` the variable names, `"both"`
  the name followed by the label.

- label_width:

  Number of characters after which the labels are wrapped. Defaults
  to 40. `NULL` for no wrapping.

- digits:

  Number of decimals of the values in the heatmap. Defaults to 1.

## Value

A ggplot object.

## Details

### Types

- `"lines"` (default): the classic profile ("snake") plot, with the
  clustering variables on the y-axis and one line per cluster. Best to
  compare all clusters in one chart.

- `"bars"`: one panel per cluster with the means as horizontal bars and
  the total mean as a grey mark. Best to see the highs and lows of each
  cluster when naming them.

- `"heatmap"`: clusters (columns) by variables (rows), with the means as
  numbers and the difference to the total mean as color (red = above,
  blue = below the total).

### Scales

- `"prepared"` (default): the means of the prepared clustering
  variables, i.e. the centers that the clustering is based on
  (`object$centers`). With z-standardized variables
  ([`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
  with `scale = "z"`), the means are expressed in standard deviations
  from the total mean (0): following Cohen (1988), deviations of about
  0.2, 0.5 and 0.8 can be regarded as small, medium and large.

- `"original"`: the means of the original clustering variables (e.g. on
  a 1-10 rating scale) of the respondents of each cluster, from
  `object$data_full`. Imputed values are not included. Easier to
  communicate, but variables with different scales or variances are less
  comparable.

The dashed grey line (`"lines"`) or grey marks (`"bars"`) show the total
mean of all respondents of the solution. For fuzzy and model-based
clustering, the means are computed for the respondents assigned to each
cluster (highest membership / probability). Noise (density-based
methods) is not shown, but included in the total.

For a detailed comparison of the clusters, with confidence intervals,
significance tests, survey weights and further profiling variables, see
[`eda_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot.md)
and
[`eda_explore()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_explore.md).

## References

Cohen, J. (1988). *Statistical power analysis for the behavioral
sciences* (2nd ed.). Lawrence Erlbaum.

## See also

Other clustering:
[`predict.seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/predict.seg_cluster.md),
[`seg_agreement()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_agreement.md),
[`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md),
[`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md),
[`seg_cluster_density()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_density.md),
[`seg_cluster_fuzzy()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_fuzzy.md),
[`seg_cluster_hierarchical()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hierarchical.md),
[`seg_cluster_hkmeans()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hkmeans.md),
[`seg_cluster_model()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_model.md),
[`seg_cluster_partitioning()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_partitioning.md),
[`seg_dbscan_eps()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_dbscan_eps.md),
[`seg_plot_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_cluster.md),
[`seg_plot_dend()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_dend.md),
[`seg_plot_heatmap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_heatmap.md)

## Examples

``` r
# \donttest{
prep <- seg_prep_data(
  sm_synthetic,
  vars = dplyr::starts_with("F50_0_"),
  missing = "mice",
  max_missing_prop = 0.2,
  verbose = FALSE
)
cl <- seg_cluster(prep, k = 4, plots = FALSE, verbose = FALSE)
seg_plot_centers(cl)

seg_plot_centers(cl, type = "bars", order = "difference")

seg_plot_centers(cl, type = "heatmap", scale = "original")

# }
```
