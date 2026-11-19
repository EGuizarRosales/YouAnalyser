# Choose eps for DBSCAN: k-nearest-neighbor distance plot

Computes the distance of each respondent to its \\k\\-th nearest
neighbor (\\k\\ = `min_pts` - 1), sorts these distances and plots them.
The suitable value of `eps` for DBSCAN is located at the "knee" of the
curve, where the distances start to increase sharply: respondents to the
right of the knee are in sparse regions (noise). The knee is determined
automatically as the point with the largest distance to the straight
line between the first and the last point of the (normalized) curve.

## Usage

``` r
seg_dbscan_eps(x, min_pts = NULL)
```

## Arguments

- x:

  The output of
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
  (recommended), or a data frame or numeric matrix with already prepared
  clustering variables (no missing values).

- min_pts:

  Minimum number of respondents in the neighborhood of a core point
  (DBSCAN) or minimum cluster size (HDBSCAN). `NULL` (default) uses
  twice the number of clustering variables.

## Value

A list with the elements `eps` (the suggested value), `min_pts`, `knn`
(tibble with the sorted distances) and `plot` (ggplot object).

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
[`seg_plot_centers()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_centers.md),
[`seg_plot_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_cluster.md),
[`seg_plot_dend()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_dend.md),
[`seg_plot_heatmap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_heatmap.md)

## Examples

``` r
# \donttest{
if (requireNamespace("dbscan", quietly = TRUE)) {
  prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
  seg_dbscan_eps(prep, min_pts = 8)$plot
}

# }
```
