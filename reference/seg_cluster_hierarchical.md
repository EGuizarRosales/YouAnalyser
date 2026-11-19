# Hierarchical clustering: AGNES and DIANA

Builds a hierarchy of clusters (a tree) with agglomerative
([`cluster::agnes()`](https://rdrr.io/pkg/cluster/man/agnes.html)) or
divisive
([`cluster::diana()`](https://rdrr.io/pkg/cluster/man/diana.html))
hierarchical clustering and cuts it into `k` clusters.

## Usage

``` r
seg_cluster_hierarchical(
  x,
  k = 4,
  method = c("agnes", "diana"),
  linkage = c("ward", "complete", "average", "single", "weighted", "gaverage"),
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

  `"agnes"` (default) or `"diana"`.

- linkage:

  Linkage method for AGNES: `"ward"` (default), `"complete"`,
  `"average"`, `"single"`, `"weighted"` or `"gaverage"`. Ignored by
  DIANA.

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

### Agglomerative clustering (AGNES, bottom-up)

1.  Start with each respondent as its own cluster.

2.  Merge the two most similar clusters.

3.  Repeat step 2 until all respondents are in one cluster.

How the similarity of two clusters is measured is defined by the
*linkage*:

- `"ward"` (default): merge the two clusters that lead to the smallest
  increase in the within-cluster variance. Produces compact clusters of
  similar size; the recommended choice for segmentations.

- `"complete"`: distance of the two most distant members. Compact
  clusters, sensitive to outliers.

- `"average"`: average distance of all pairs of members. A compromise,
  but often produces one large cluster and a few small ones.

- `"single"`: distance of the two closest members. Tends to chain
  respondents into long, unbalanced clusters; rarely useful for
  segmentations.

### Divisive clustering (DIANA, top-down)

1.  Start with all respondents in one cluster.

2.  Split the cluster with the largest diameter: the respondent with the
    largest average distance to the others starts a "splinter group",
    and respondents that are closer to the splinter group than to the
    rest follow.

3.  Repeat step 2 until each respondent forms its own cluster.

DIANA is better at identifying a few large clusters, AGNES at
identifying many small ones.

### Dendrogram and cutting the tree

The result is a tree (dendrogram), in which the height of each merge
reflects the distance between the merged clusters. Cutting the tree at a
given height yields `k` clusters; for several values of `k`, the tree is
computed only once. Long vertical branches above the cut indicate well
separated clusters. The agglomerative / divisive coefficient (in
`settings$coefficient`, range 0 to 1) describes the strength of the
clustering structure; values close to 1 indicate a clear structure.

Both methods use the distance matrix of
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
and therefore work with any distance measure. Once respondents are
merged (or split), they cannot change cluster, so the solution is not
optimized afterwards (see
[`seg_cluster_hkmeans()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hkmeans.md)
for a combination with k-means).

### When to use

To explore the structure of the data and how clusters merge or split for
different numbers of clusters, and for smaller samples. For a final
segmentation, hierarchical k-means usually gives more compact clusters.

## See also

Other clustering:
[`predict.seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/predict.seg_cluster.md),
[`seg_agreement()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_agreement.md),
[`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md),
[`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md),
[`seg_cluster_density()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_density.md),
[`seg_cluster_fuzzy()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_fuzzy.md),
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
ag <- seg_cluster_hierarchical(prep, k = 2:5)
#> 
#> ── Cluster solutions: agnes ──
#> 
#> • k = 2: 751 / 620 (smallest: 45%)
#> • k = 3: 751 / 310 / 310 (smallest: 23%)
#> • k = 4: 499 / 310 / 310 / 252 (smallest: 18%)
#> • k = 5: 418 / 310 / 310 / 252 / 81 (smallest: 6%)
#> Solutions: `$solutions$k2`, `$solutions$k3`, `$solutions$k4`, and
#> `$solutions$k5`
ag$solutions$k4$plots$dend

# }
```
