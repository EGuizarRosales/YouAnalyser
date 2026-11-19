# Hierarchical k-means clustering

Combines hierarchical clustering and k-means
([`factoextra::hkmeans()`](https://rpkgs.datanovia.com/factoextra/reference/hkmeans.html)):
the hierarchical solution is used as the starting point for k-means.

## Usage

``` r
seg_cluster_hkmeans(
  x,
  k = 4,
  hc_method = "ward.D2",
  iter_max = 50,
  plots = TRUE,
  cluster_plot_args = list(),
  dend_args = list(),
  centers_args = list(),
  heatmap_n = 200,
  seed = 123,
  verbose = TRUE
)
```

## Arguments

- x:

  The output of
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
  (recommended), or a data frame or numeric matrix with already prepared
  clustering variables (no missing values).

- k:

  Number of clusters. A vector (e.g. `2:6`) returns one solution per
  number of clusters. Ignored by the density-based methods. For
  `"mclust"`, `NULL` lets the BIC choose the number of clusters (slow).

- hc_method:

  Agglomeration method for the hierarchical step, passed to
  [`stats::hclust()`](https://rdrr.io/r/stats/hclust.html). Defaults to
  `"ward.D2"`.

- iter_max:

  Maximum number of iterations for k-means. Defaults to 50.

- plots:

  Logical. Whether to create the plots. Defaults to `TRUE`.

- cluster_plot_args:

  A list of arguments passed to
  [`factoextra::fviz_cluster()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_cluster.html),
  overriding the defaults (see
  [`seg_plot_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_cluster.md)),
  e.g. `list(ellipse.type = "convex")`.

- dend_args:

  A list of arguments passed to
  [`factoextra::fviz_dend()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_dend.html),
  overriding the defaults (see
  [`seg_plot_dend()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_dend.md)),
  e.g. `list(type = "phylogenic")`.

- centers_args:

  A list of arguments passed to
  [`seg_plot_centers()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_centers.md),
  overriding the defaults, e.g.
  `list(type = "bars", scale = "original")`.

- heatmap_n:

  Number of respondents randomly sampled for the heatmap. Defaults to
  200.

- seed:

  Random seed. The global random seed is left untouched. Defaults to
  123.

- verbose:

  Logical. Whether to print the results. Defaults to `TRUE`.

## Value

For a single number of clusters, an object of class `seg_cluster`, a
list with the elements:

- `method`, `family`: the clustering method and its family.

- `k`: the requested number of clusters (`NA` for density-based
  methods).

- `k_found`: the number of clusters found (excluding noise).

- `cluster`: integer vector with the cluster of each respondent (0 =
  noise), in the order of the prepared data.

- `membership`: matrix with the membership degrees (fuzzy) or
  probabilities (model-based) of each respondent in each cluster, `NULL`
  for the other methods.

- `sizes`: tibble with the size and share of each cluster.

- `centers`: tibble with the mean of each clustering variable per
  cluster.

- `assignment`: tibble with the respondent identifier, the cluster and
  method-specific information (e.g. the highest membership degree).

- `data`, `data_full`, `dist`: the prepared clustering variables, the
  original data of the retained respondents and the distance matrix (if
  available), as passed on from
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md).

- `fit`: the result of the underlying clustering function.

- `tree`: the hierarchical tree (class `hclust`) for hierarchical
  methods and hierarchical k-means, otherwise `NULL`.

- `cluster_map`: named integer vector mapping the cluster codes of `fit`
  (names) to the renumbered codes, `NULL` if not renumbered.

- `prep`: the preparation settings of
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
  (variables, missing values, rescaling parameters), used to prepare new
  respondents in
  [`predict.seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/predict.seg_cluster.md).

- `plots`: list of plots (see "Visualizations").

- `settings`: list of the settings used.

For several numbers of clusters, an object of class `seg_cluster_set`, a
list with the elements `solutions` (named list of `seg_cluster` objects,
e.g. `solutions$k4`), `summary` (tibble with the cluster sizes per
solution), `plot` (the cluster plots of all solutions combined) and
`method`.

## Details

### Algorithm

k-means depends on its random starting centers, and different starts can
lead to different solutions. Hierarchical k-means removes this
dependence:

1.  Compute a hierarchical clustering of the respondents (Ward's method
    by default, see
    [`seg_cluster_hierarchical()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hierarchical.md))
    and cut the tree into `k` clusters.

2.  Compute the center (mean) of each of these clusters.

3.  Use these centers as starting centers for k-means, which then
    optimizes the assignment: respondents can move to the cluster whose
    center is closest (which is not possible in pure hierarchical
    clustering).

The result is deterministic, usually at least as good as k-means with
many random starts, and combines the "global view" of hierarchical
clustering with the optimization of k-means.

### When to use

A robust default for survey segmentations based on rating scales, and
the default method of
[`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md).
As for k-means, the clusters are assumed to be roughly spherical, and
outliers can affect the solution.

The dendrogram (`plots$dend`) shows the hierarchical clustering of the
first step; its colors show the final cluster that most members of each
branch belong to after the k-means step.

## See also

Other clustering:
[`predict.seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/predict.seg_cluster.md),
[`seg_agreement()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_agreement.md),
[`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md),
[`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md),
[`seg_cluster_density()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_density.md),
[`seg_cluster_fuzzy()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_fuzzy.md),
[`seg_cluster_hierarchical()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hierarchical.md),
[`seg_cluster_model()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_model.md),
[`seg_cluster_partitioning()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_partitioning.md),
[`seg_dbscan_eps()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_dbscan_eps.md),
[`seg_plot_centers()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_centers.md),
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
hk <- seg_cluster_hkmeans(prep, k = 4)
#> 
#> ── Cluster solution: Hierarchical k-means, k = 4 ──
#> 
#> • Cluster 1: n = 387 (28%)
#> • Cluster 2: n = 368 (27%)
#> • Cluster 3: n = 355 (26%)
#> • Cluster 4: n = 261 (19%)
#> Plots: `$plots$cluster`, `$plots$dend`, `$plots$heatmap`, and `$plots$centers`
hk$plots$dend

# }
```
