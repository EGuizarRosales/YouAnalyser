# Model-based clustering

Fits Gaussian mixture models with
[`mclust::Mclust()`](https://mclust-org.github.io/mclust/reference/Mclust.html)
and assigns each respondent to the cluster with the highest probability.
Requires the mclust package.

## Usage

``` r
seg_cluster_model(
  x,
  k = 4,
  model_names = NULL,
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

  Number of clusters (or a vector of values). `NULL` lets the BIC choose
  among 1 to 9 clusters (slow).

- model_names:

  Covariance models to consider, e.g. `c("EII", "VVV")`. `NULL`
  (default) considers all models. See
  [`mclust::mclustModelNames()`](https://mclust-org.github.io/mclust/reference/mclustModelNames.html).

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

Model-based clustering assumes that the data comes from a mixture of `k`
groups, each following a multivariate normal distribution with its own
mean and covariance matrix. The covariance matrix determines the shape,
volume and orientation of each cluster (ellipsoids). mclust offers 14
models, from simple (e.g. `"EII"`: spherical clusters of equal volume)
to flexible (e.g. `"VVV"`: ellipsoids of varying shape, volume and
orientation).

1.  For each model and number of clusters, the parameters are estimated
    with the EM algorithm (expectation-maximization), starting from a
    hierarchical clustering: the *E-step* computes the probability of
    each respondent to belong to each cluster, the *M-step* updates the
    means and covariances based on these probabilities.

2.  The models are compared with the Bayesian Information Criterion
    (BIC), which balances fit and complexity; the model with the highest
    BIC is selected (`plots$bic`).

Each respondent is assigned to the cluster with the highest probability
(`cluster`); the probabilities are returned in `membership`, and the
uncertainty of the assignment (1 minus the highest probability) in
`assignment$uncertainty`.

### Number of clusters

With `k = NULL`, the BIC chooses the number of clusters among 1 to 9 as
well. This is statistically principled, but slow (about one minute for
1,400 respondents and 20 variables) and, in large samples, the BIC tends
to favor many clusters. With a given `k` (or a vector of values), the
best model is chosen for each `k`.

### When to use

When clusters of different shapes and sizes are expected, membership
probabilities are needed, or the number of clusters should be chosen on
statistical grounds. Model-based clustering can produce very unequal
cluster sizes, and with many variables the flexible models have many
parameters to estimate. It uses the data (not the distance matrix).

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
[`seg_cluster_partitioning()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_partitioning.md),
[`seg_dbscan_eps()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_dbscan_eps.md),
[`seg_plot_centers()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_centers.md),
[`seg_plot_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_cluster.md),
[`seg_plot_dend()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_dend.md),
[`seg_plot_heatmap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_heatmap.md)

## Examples

``` r
# \donttest{
if (requireNamespace("mclust", quietly = TRUE)) {
  prep <- seg_prep_data(
    sm_synthetic,
    vars = dplyr::starts_with("F50_0_"),
    missing = "mice",
    max_missing_prop = 0.2,
    verbose = FALSE
  )
  mc <- seg_cluster_model(prep, k = 4)
  mc$plots$bic
}
#> 
#> ── Cluster solution: Model-based clustering (VVE), k = 4 ──
#> 
#> • Cluster 1: n = 648 (47%)
#> • Cluster 2: n = 480 (35%)
#> • Cluster 3: n = 203 (15%)
#> • Cluster 4: n = 40 (3%)
#> Plots: `$plots$cluster`, `$plots$heatmap`, `$plots$centers`, and `$plots$bic`

# }
```
