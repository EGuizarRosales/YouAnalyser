# Fuzzy clustering

Assigns each respondent a membership degree for every cluster with fuzzy
clustering
([`cluster::fanny()`](https://rdrr.io/pkg/cluster/man/fanny.html)).

## Usage

``` r
seg_cluster_fuzzy(
  x,
  k = 4,
  memb_exp = 1.1,
  max_iter = 1000,
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

- memb_exp:

  Membership exponent (\> 1). Defaults to 1.1, see "Details".

- max_iter:

  Maximum number of iterations. Defaults to 1000.

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

In "hard" clustering (e.g. k-means), each respondent belongs to exactly
one cluster. In fuzzy clustering, each respondent \\i\\ has a membership
degree \\u\_{ic}\\ between 0 and 1 for each cluster \\c\\, summing to 1.
The algorithm minimizes \$\$\sum\_{c=1}^{k} \frac{\sum\_{i,j} u\_{ic}^r
u\_{jc}^r d(i, j)}{2 \sum_j u\_{jc}^r}\$\$ where \\d(i, j)\\ is the
distance between two respondents and \\r\\ the membership exponent
(`memb_exp`): respondents that are close to each other should have high
memberships in the same clusters. Each respondent is assigned to the
cluster with its highest membership degree (`cluster`); the membership
degrees are returned in `membership`, and the highest membership degree
of each respondent in `assignment$membership_max`.

### Membership exponent

The membership exponent (\\r \> 1\\) controls the fuzziness: the closer
to 1, the crisper the solution; the larger, the fuzzier. The usual
default of 2 leads to *complete fuzziness* (all memberships equal to
1/k) for survey data with many clustering variables, which is why the
default here is 1.1. Dunn's partition coefficient (in
`settings$partition_coefficient`) ranges from 1/k (completely fuzzy) to
1 (crisp); a warning is given if the solution is (almost) completely
fuzzy.

### When to use

When respondents are expected to belong partly to several segments, or
to identify respondents that are clearly assigned (high membership) vs.
respondents between segments (e.g. to exclude them when building a
typing tool). The distance matrix of
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
is used.

## See also

Other clustering:
[`predict.seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/predict.seg_cluster.md),
[`seg_agreement()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_agreement.md),
[`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md),
[`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md),
[`seg_cluster_density()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_density.md),
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
prep <- seg_prep_data(
  sm_synthetic,
  vars = dplyr::starts_with("F50_0_"),
  missing = "mice",
  max_missing_prop = 0.2,
  verbose = FALSE
)
fz <- seg_cluster_fuzzy(prep, k = 4)
#> 
#> ── Cluster solution: Fuzzy clustering, k = 4 ──
#> 
#> • Cluster 1: n = 381 (28%)
#> • Cluster 2: n = 360 (26%)
#> • Cluster 3: n = 353 (26%)
#> • Cluster 4: n = 277 (20%)
#> Plots: `$plots$cluster`, `$plots$heatmap`, and `$plots$centers`
head(fz$membership)
#>    cluster_1   cluster_2 cluster_3   cluster_4
#> 1 0.48113718 0.404488239 0.1103792 0.003995412
#> 2 0.53461197 0.143301176 0.3181298 0.003957007
#> 3 0.01380938 0.001488135 0.2815827 0.703119737
#> 4 0.05313373 0.039559339 0.8940031 0.013303829
#> 5 0.31711313 0.036899342 0.6407878 0.005199758
#> 6 0.03177246 0.006745253 0.8454946 0.115987657
# }
```
