# Assign new respondents to the clusters of a solution

Assigns new respondents (e.g. a new survey wave, a holdout sample or a
short "golden question" screener) to the clusters of an existing cluster
solution from
[`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md),
and optionally returns their membership probabilities.

## Usage

``` r
# S3 method for class 'seg_cluster'
predict(
  object,
  newdata = NULL,
  type = c("cluster", "prob"),
  rule = NULL,
  neighbors = 10,
  id = NULL,
  labels = TRUE,
  verbose = TRUE,
  ...
)

# S3 method for class 'seg_cluster_set'
predict(object, ...)
```

## Arguments

- object:

  A cluster solution of class `seg_cluster`, e.g. from
  [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md).

- newdata:

  A data frame with the new respondents. It must contain the (original,
  unprepared) clustering variables, e.g. the same columns as the data
  passed to
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md).
  If `NULL` (default), the assignment of the original sample is
  returned.

- type:

  `"cluster"` (default) for the assigned cluster, or `"prob"` to add the
  membership probabilities (`prob_cluster_1`, `prob_cluster_2`, ...).
  Probabilities are available for fuzzy clustering, model-based
  clustering and `rule = "knn"`.

- rule:

  Assignment rule: `NULL` (default) for the rule of the clustering
  method (see "Assignment rules"), `"centroid"`, `"knn"`, or `"linkage"`
  (AGNES and DIANA only).

- neighbors:

  Number of nearest neighbors for `rule = "knn"`. Defaults to 10.

- id:

  Name of an identifier column in `newdata` to be included in the
  result. Defaults to the identifier of
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
  if `newdata` contains it, otherwise the row number (column `row`).

- labels:

  Logical. Whether to add the cluster labels of an existing segmentation
  ([`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md))
  as value labels to `cluster`. Defaults to `TRUE`.

- verbose:

  Logical. Whether to report respondents that could not be assigned.
  Defaults to `TRUE`.

- ...:

  Not used.

## Value

A tibble with one row per row of `newdata` (in the same order), with the
identifier, the assigned `cluster` (`NA` for respondents who could not
be assigned, 0 for noise of density-based methods), the rule-specific
information (see "Assignment rules") and, for `type = "prob"`, the
membership probabilities.

## Details

### Preparation of the new data

The new respondents are prepared exactly like the respondents of the
solution in
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md),
using the parameters of the original sample (never statistics of the new
data):

1.  The clustering variables are selected from `newdata` (other columns
    are ignored) and value labels are removed.

2.  Respondents without any valid answer, or with more missing values
    than `max_missing_prop`, are not assigned (`NA`).

3.  Missing values are handled with the strategy of
    [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md):

    - `"omit"`: respondents with missing values are not assigned (`NA`).

    - `"mean"` / `"median"`: imputed with the means / medians of the
      original sample.

    - `"mice"`: the new respondents are appended to the original sample
      and imputed with
      [`mice::mice()`](https://amices.org/mice/reference/mice.html),
      where the imputation model is estimated on the original sample
      only (argument `ignore`) and the settings of `imputation_args` and
      the `seed` of
      [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
      are reused, so that the imputation is reproducible.

4.  The variables are rescaled with the means and standard deviations
    (`scale = "z"`) or the minima and ranges (`scale = "range"`) of the
    original sample.

### Assignment rules

Each method assigns new respondents in the way that is consistent with
how it formed the clusters (`rule = NULL`, the default):

- k-means and hierarchical k-means (`"centroid"`): the cluster with the
  nearest center (Euclidean distance), as in the assignment step of
  k-means. Additional column: `distance` to that center.

- PAM (`"medoid"`): the cluster with the nearest medoid, using the
  distance measure of
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md).
  Additional column: `distance` to that medoid.

- AGNES and DIANA (`"linkage"`): the cluster the respondent would be
  merged with first under the linkage of the solution:

  - `"ward"`: the smallest increase of the within-cluster sum of
    squares, \\\frac{n_c}{n_c + 1}(\bar{d^2}(x, c) - W_c)\\, computed
    from the distances only (for Euclidean distances: the nearest
    center, weighted by cluster size),

  - `"average"`, `"weighted"`, `"gaverage"` and DIANA: the smallest
    average distance to the members of the cluster,

  - `"complete"`: the smallest maximum distance,

  - `"single"`: the nearest member.

  Additional column: `distance`, the linkage distance (for Ward on the
  scale of the dendrogram heights).

- Fuzzy clustering (`"membership"`): membership degrees that minimize
  the objective function of
  [`cluster::fanny()`](https://rdrr.io/pkg/cluster/man/fanny.html) for
  the new respondent, with the memberships of the original sample fixed.
  With the membership exponent \\r\\ and \\a_c(x) = \sum_j u\_{jc}^r
  d(x, j) / \sum_j u\_{jc}^r - \sum\_{i,j} u\_{ic}^r u\_{jc}^r d(i, j) /
  (2 (\sum_j u\_{jc}^r)^2)\\, the membership in cluster \\c\\ is
  proportional to \\a_c(x)^{-1/(r-1)}\\. The respondent is assigned to
  the cluster with the highest membership. Additional column:
  `membership_max`.

- Model-based clustering (`"model"`): posterior probabilities of the
  fitted Gaussian mixture model
  ([`mclust::predict.Mclust()`](https://mclust-org.github.io/mclust/reference/predict.Mclust.html));
  the respondent is assigned to the most probable cluster. Additional
  column: `uncertainty` (1 - highest probability).

- DBSCAN (`"density"`): the cluster of the nearest clustered (non-noise)
  respondent of the original sample if it lies within `eps`, otherwise
  noise (0), as in `dbscan::predict()`.

- HDBSCAN (`"density"`): the cluster of the nearest clustered respondent
  of the original sample if it lies within that respondent's core
  distance, otherwise noise (0), as in `dbscan::predict()`. Both density
  rules use the distance measure of
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md).
  Additional column: `distance` to the nearest clustered respondent.

- Existing segmentations from
  [`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md)
  (`"centroid"`).

Two alternative rules can be chosen for every method:

- `rule = "centroid"`: nearest cluster center (Euclidean distance).

- `rule = "knn"`: majority vote of the `neighbors` nearest respondents
  of the original sample (distance measure of
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md);
  ties are resolved by the smallest summed distance). The share of votes
  per cluster is returned as probabilities with `type = "prob"`, the
  highest share as `knn_share`.

### Consistency with the original assignment

Applied to the respondents of the original sample, the rules of k-means,
hierarchical k-means, PAM, fuzzy clustering (memberships), model-based
clustering (probabilities) and the density-based methods reproduce the
original assignment. For AGNES and DIANA, the linkage rule reproduces it
for most, but not all respondents (typically 80-90%), as the clusters
are formed by successively merging groups and cutting the tree, so that
their borders do not follow a simple rule for single respondents.
`rule = "knn"` often agrees more closely with the original assignment of
these methods.

With `missing = "mice"`, passing the original sample as `newdata`
re-imputes its missing values, so that respondents with imputed values
may be assigned differently. Use `newdata = NULL` for the original
assignment.

## See also

Other clustering:
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
[`seg_plot_dend()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_dend.md),
[`seg_plot_heatmap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_heatmap.md)

## Examples

``` r
# \donttest{
# Solution on one half of the sample, assignment of the other half
train <- sm_synthetic[1:600, ]
new <- sm_synthetic[601:nrow(sm_synthetic), ]

prep <- seg_prep_data(
  train,
  vars = dplyr::starts_with("F50_0_"),
  id = "id",
  missing = "mean",
  verbose = FALSE
)
cl <- seg_cluster(prep, k = 4, plots = FALSE, verbose = FALSE)

pred <- predict(cl, new)
pred
#> # A tibble: 801 × 3
#>       id cluster distance
#>    <dbl>   <int>    <dbl>
#>  1   601       1     3.69
#>  2   602       3     3.32
#>  3   603       2     2.87
#>  4   604       3     2.55
#>  5   605       4     5.57
#>  6   606       1     3.84
#>  7   607       1     3.98
#>  8   608       3     3.45
#>  9   609       2     3.03
#> 10   610       4     3.92
#> # ℹ 791 more rows
table(pred$cluster, useNA = "ifany")
#> 
#>   1   2   3   4 
#> 245 183 222 151 

# Membership probabilities of fuzzy clustering
cl_fuzzy <- seg_cluster(prep, "fuzzy", k = 3, plots = FALSE, verbose = FALSE)
predict(cl_fuzzy, new, type = "prob")
#> # A tibble: 801 × 6
#>       id cluster membership_max prob_cluster_1 prob_cluster_2 prob_cluster_3
#>    <dbl>   <int>          <dbl>          <dbl>          <dbl>          <dbl>
#>  1   601       1          0.812         0.812         0.0734        0.114   
#>  2   602       2          0.978         0.0218        0.978         0.000394
#>  3   603       1          0.523         0.523         0.00408       0.472   
#>  4   604       2          0.981         0.0191        0.981         0.000113
#>  5   605       3          0.971         0.0272        0.00195       0.971   
#>  6   606       1          0.531         0.531         0.453         0.0154  
#>  7   607       1          0.655         0.655         0.0199        0.325   
#>  8   608       2          0.966         0.0330        0.966         0.000684
#>  9   609       1          0.882         0.882         0.0350        0.0835  
#> 10   610       3          0.951         0.0474        0.00150       0.951   
#> # ℹ 791 more rows

# Alternative rule: 10 nearest neighbors
predict(cl, new, rule = "knn", type = "prob")
#> # A tibble: 801 × 7
#>       id cluster knn_share prob_cluster_1 prob_cluster_2 prob_cluster_3
#>    <dbl>   <int>     <dbl>          <dbl>          <dbl>          <dbl>
#>  1   601       1       0.7            0.7            0.3            0  
#>  2   602       3       1              0              0              1  
#>  3   603       2       0.6            0.3            0.6            0  
#>  4   604       3       1              0              0              1  
#>  5   605       4       0.9            0              0.1            0  
#>  6   606       1       0.7            0.7            0              0.3
#>  7   607       1       0.6            0.6            0.3            0  
#>  8   608       3       1              0              0              1  
#>  9   609       2       0.6            0.4            0.6            0  
#> 10   610       4       1              0              0              0  
#> # ℹ 791 more rows
#> # ℹ 1 more variable: prob_cluster_4 <dbl>
# }
```
