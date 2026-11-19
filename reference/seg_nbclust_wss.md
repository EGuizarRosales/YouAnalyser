# Optimal number of clusters: Elbow method (WSS)

Computes the total within-cluster sum of squares (WSS) for 1 to `k_max`
clusters using
[`factoextra::fviz_nbclust()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_nbclust.html).
The optimal number of clusters is located at the "elbow" (bend) of the
curve, where adding another cluster no longer reduces the WSS much.

## Usage

``` r
seg_nbclust_wss(
  x,
  cluster_method = c("kmeans", "hclust", "pam"),
  k_max = 10,
  nstart = 25,
  hc_method = "ward.D2",
  seed = 123
)
```

## Arguments

- x:

  The output of
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
  (recommended), or a data frame or numeric matrix with already prepared
  clustering variables (no missing values).

- cluster_method:

  Clustering algorithm used to evaluate the solutions: `"kmeans"`
  (default, [`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html)),
  `"hclust"` (hierarchical clustering via
  [`factoextra::hcut()`](https://rpkgs.datanovia.com/factoextra/reference/hcut.html))
  or `"pam"` (partitioning around medoids,
  [`cluster::pam()`](https://rdrr.io/pkg/cluster/man/pam.html)). k-means
  always uses Euclidean distances. NbClust does not support `"pam"` and
  is skipped in that case.

- k_max:

  Maximum number of clusters to consider. Defaults to 10.

- nstart:

  Number of random starts for k-means (WSS, silhouette). Defaults to 25.

- hc_method:

  Agglomeration method for `cluster_method = "hclust"`. Defaults to
  `"ward.D2"`.

- seed:

  Random seed. The global random seed is left untouched. Defaults to
  123.

## Value

A list with the elements `method`, `optimal_k`, `criterion`, `values`
(tibble with the criterion per k) and `plot` (ggplot object).

## Details

### How it works

For each k, the respondents are clustered and the total within-cluster
sum of squares is computed: \$\$WSS(k) = \sum\_{c=1}^{k} \sum\_{i \in
C_c} d(x_i, \mu_c)^2\$\$ where \\\mu_c\\ is the center of cluster \\c\\.
WSS measures the compactness of the clusters: the smaller, the more
similar the respondents within the clusters. If a distance matrix other
than Euclidean was computed by
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md),
it is used to compute the WSS.

Since WSS always decreases when clusters are added (with k = n
respondents it is 0), its minimum is meaningless. Instead, the elbow
method looks for the k after which adding clusters brings only small
improvements. Here, the elbow is determined automatically as the point
with the largest distance below the straight line between the first and
the last point of the (normalized) curve.

### Interpretation

- A sharp bend indicates a natural number of clusters.

- A smooth curve without a clear bend, which is common for survey data,
  indicates that the data has no clear cluster structure. The
  automatically determined elbow is then only a rough guide and may
  change with `k_max`.

- The elbow method is the most widely used but also the most subjective
  method. Combine it with the other methods of
  [`seg_optimal_clusters()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_optimal_clusters.md).

## See also

Other optimal number of clusters:
[`seg_nbclust_gap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_gap.md),
[`seg_nbclust_indices()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_indices.md),
[`seg_nbclust_silhouette()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_silhouette.md)

## Examples

``` r
# \donttest{
prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
seg_nbclust_wss(prep)$plot

# }
```
