# Heatmap of a cluster solution

Plots the prepared clustering variables of a random sample of
respondents as a heatmap with dendrograms, built with ggplot2:

## Usage

``` r
seg_plot_heatmap(
  object,
  n = 200,
  row_order = c("cluster", "dendrogram"),
  seed = 123
)
```

## Arguments

- object:

  A `seg_cluster` object, e.g. from
  [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md).

- n:

  Number of respondents sampled (proportionally to the cluster sizes, at
  least 2 per cluster). Defaults to 200. `NULL` uses all respondents.

- row_order:

  How to order the respondents: `"cluster"` (default) or `"dendrogram"`,
  see "Details".

- seed:

  Random seed for the sample. The global random seed is left untouched.
  Defaults to 123.

## Value

A ggplot object.

## Details

- **Cells:** the values of the prepared clustering variables (e.g.
  z-standardized), from low (blue) to high (red). Extreme values are
  capped at the 1st and 99th percentile, so that a few outliers do not
  dominate the colors.

- **Top dendrogram:** hierarchical clustering of the variables (Ward's
  method), so that variables with similar answer patterns are next to
  each other.

- **Left dendrogram and color bar:** the respondents and their cluster.

With `row_order = "cluster"` (default), respondents are grouped by
cluster; within each cluster, they are ordered by a hierarchical
clustering, whose dendrogram is drawn in the color of the cluster. Clear
blocks of color within a cluster indicate a homogeneous cluster with a
distinct profile.

With `row_order = "dendrogram"`, the respondents are ordered by a
hierarchical clustering of the whole sample (Ward's method), as in a
classical heatmap, independently of the cluster solution. The color bar
then shows whether the clusters of the solution correspond to the
structure found by the hierarchical clustering; branches containing
respondents of a single cluster are drawn in its color.

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
[`seg_plot_centers()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_centers.md),
[`seg_plot_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_cluster.md),
[`seg_plot_dend()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_dend.md)

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
seg_plot_heatmap(cl)

seg_plot_heatmap(cl, n = 300, row_order = "dendrogram")

# }
```
