# Density-based clustering: DBSCAN and HDBSCAN

Finds dense regions of respondents with DBSCAN
([`dbscan::dbscan()`](https://michael.hahsler.net/dbscan/reference/dbscan.html))
or HDBSCAN
([`dbscan::hdbscan()`](https://michael.hahsler.net/dbscan/reference/hdbscan.html))
and labels respondents outside of them as noise (cluster 0). Requires
the dbscan package.

## Usage

``` r
seg_cluster_density(
  x,
  method = c("dbscan", "hdbscan"),
  eps = NULL,
  min_pts = NULL,
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

- method:

  `"dbscan"` (default) or `"hdbscan"`.

- eps:

  Radius of the neighborhood for DBSCAN. `NULL` (default) uses the knee
  of the k-nearest-neighbor distance plot (see
  [`seg_dbscan_eps()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_dbscan_eps.md)).

- min_pts:

  Minimum number of respondents in the neighborhood of a core point
  (DBSCAN) or minimum cluster size (HDBSCAN). `NULL` (default) uses
  twice the number of clustering variables.

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

### DBSCAN

DBSCAN (density-based spatial clustering of applications with noise)
does not need the number of clusters, but two parameters: the radius
`eps` and the minimum number of points `min_pts`.

1.  A respondent is a *core point* if at least `min_pts` respondents
    (including itself) lie within the distance `eps`.

2.  Core points within `eps` of each other are connected and form a
    cluster; respondents within `eps` of a core point (*border points*)
    are added to its cluster.

3.  All other respondents are *noise* (cluster 0).

DBSCAN finds clusters of arbitrary shape and identifies outliers, but
uses a single density threshold for all clusters. `min_pts` defaults to
twice the number of clustering variables (a common rule of thumb). `eps`
defaults to the "knee" of the sorted k-nearest-neighbor distances, see
[`seg_dbscan_eps()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_dbscan_eps.md).

### HDBSCAN

HDBSCAN (hierarchical DBSCAN) runs DBSCAN for all values of `eps` at
once, builds a hierarchy of the resulting clusters and keeps the most
stable clusters. It only needs `min_pts` (the minimum cluster size) and
can find clusters of varying density. It also returns the probability of
each respondent to belong to its cluster (`assignment$membership_prob`)
and an outlier score (`assignment$outlier_score`, higher = more
outlying).

### When to use

For data with dense, well separated groups of arbitrary shape, and to
detect outliers. Survey data with many correlated rating scales rarely
contains such dense regions: the methods then find a single cluster
(with some noise) or only noise. They are therefore mainly useful to
identify outliers (e.g. to exclude them before a k-means or PAM
segmentation) rather than for the segmentation itself. With many
clustering variables, distances become similar for all respondents
("curse of dimensionality"), which makes density-based clustering
difficult; consider clustering on a few principal components instead.
The distance matrix of
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
is used if available.

## See also

Other clustering:
[`predict.seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/predict.seg_cluster.md),
[`seg_agreement()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_agreement.md),
[`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md),
[`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md),
[`seg_cluster_fuzzy()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_fuzzy.md),
[`seg_cluster_hierarchical()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hierarchical.md),
[`seg_cluster_hkmeans()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hkmeans.md),
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
if (requireNamespace("dbscan", quietly = TRUE)) {
  prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
  db <- seg_cluster_density(prep, eps = 0.8, min_pts = 8)
  db$sizes
}
#> 
#> ── Cluster solution: DBSCAN, k = 2 ──
#> 
#> • Cluster 1: n = 94 (63%)
#> • Cluster 2: n = 48 (32%)
#> • Noise: n = 8 (5%)
#> Plots: `$plots$cluster`, `$plots$heatmap`, and `$plots$centers`
#> # A tibble: 3 × 3
#>   cluster     n  share
#>     <int> <int>  <dbl>
#> 1       1    94 0.627 
#> 2       2    48 0.32  
#> 3       0     8 0.0533
# }
```
