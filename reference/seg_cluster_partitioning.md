# Partitioning clustering: k-means and PAM

Partitions the respondents into `k` clusters with k-means
([`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html)) or PAM
(partitioning around medoids,
[`cluster::pam()`](https://rdrr.io/pkg/cluster/man/pam.html)).

## Usage

``` r
seg_cluster_partitioning(
  x,
  k = 4,
  method = c("kmeans", "pam"),
  nstart = 25,
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

- method:

  `"kmeans"` (default) or `"pam"`.

- nstart:

  Number of random starts for k-means. Defaults to 25.

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

### k-means

k-means describes each cluster by its center (the mean of its members)
and looks for the partition with the smallest total within-cluster sum
of squares, i.e. the most compact clusters:

1.  Choose `k` respondents at random as initial cluster centers.

2.  Assign each respondent to the nearest center (Euclidean distance).

3.  Recompute each center as the mean of its members.

4.  Repeat steps 2 and 3 until the assignment no longer changes.

The result depends on the random start, so the algorithm is run `nstart`
times and the best solution is kept. k-means is fast and simple, but
assumes roughly spherical clusters of similar size, is sensitive to
outliers and always uses Euclidean distances (the distance measure of
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
is not used).

### PAM (k-medoids)

PAM works like k-means, but each cluster is represented by a *medoid*:
the respondent with the smallest average distance to all other members
of the cluster.

1.  *Build:* select `k` respondents as initial medoids.

2.  *Swap:* for each medoid and each non-medoid, check whether swapping
    them reduces the sum of the distances of all respondents to their
    nearest medoid; carry out the best swap.

3.  Repeat step 2 until no swap improves the solution.

As it minimizes distances rather than squared distances and uses real
respondents as centers, PAM is more robust to outliers and extreme
answer patterns than k-means. It works with any distance measure: the
distance matrix of
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
is used (e.g. Manhattan or Gower). PAM is slower than k-means
(computation grows with the square of the number of respondents) and
deterministic.

### When to use

Use k-means for large samples and well-behaved rating scales; prefer
[hierarchical
k-means](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hkmeans.md),
which removes the dependence on random starts. Use PAM if the data
contains outliers, if you want to use a distance measure other than
Euclidean, or if real respondents as "typical members" of each segment
are useful (e.g. for personas).

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
km <- seg_cluster_partitioning(prep, k = 4)
#> 
#> ── Cluster solution: k-means, k = 4 ──
#> 
#> • Cluster 1: n = 389 (28%)
#> • Cluster 2: n = 370 (27%)
#> • Cluster 3: n = 353 (26%)
#> • Cluster 4: n = 259 (19%)
#> Plots: `$plots$cluster`, `$plots$heatmap`, and `$plots$centers`
pam <- seg_cluster_partitioning(prep, k = 2:5, method = "pam")
#> 
#> ── Cluster solutions: pam ──
#> 
#> • k = 2: 861 / 510 (smallest: 37%)
#> • k = 3: 600 / 509 / 262 (smallest: 19%)
#> • k = 4: 414 / 369 / 355 / 233 (smallest: 17%)
#> • k = 5: 315 / 306 / 292 / 233 / 225 (smallest: 16%)
#> Solutions: `$solutions$k2`, `$solutions$k3`, `$solutions$k4`, and
#> `$solutions$k5`
# }
```
