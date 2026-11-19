# Optimal number of clusters: Average silhouette method

Computes the average silhouette width for 2 to `k_max` clusters using
[`factoextra::fviz_nbclust()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_nbclust.html).
The silhouette width measures how well each respondent fits into its own
cluster compared to the nearest other cluster. The optimal number of
clusters maximizes the average silhouette width.

## Usage

``` r
seg_nbclust_silhouette(
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

For each k, the respondents are clustered. For each respondent \\i\\,
\\a_i\\ is the average distance to the other members of its own cluster
(compactness) and \\b_i\\ the average distance to the members of the
nearest other cluster (separation). The silhouette width of the
respondent is \$\$s_i = \frac{b_i - a_i}{\max(a_i, b_i)}\$\$ and the
average silhouette width is the mean of \\s_i\\ over all respondents.
The silhouette is not defined for k = 1, so the method cannot indicate
that there are no clusters. The distance matrix computed by
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
is used if available.

### Interpretation

Values of \\s_i\\ close to 1 indicate respondents that are well
clustered, values around 0 respondents between two clusters, and
negative values respondents that are probably in the wrong cluster. For
the average silhouette width, Kaufman and Rousseeuw (1990) suggest:

- above 0.70: strong structure,

- 0.51 to 0.70: reasonable structure,

- 0.26 to 0.50: weak structure, could be artificial,

- 0.25 or below: no substantial structure.

Attitudinal survey data mostly falls in the last category (values of 0.1
to 0.25 are common); segmentations can still be useful, but the segments
then partition a continuum rather than separating natural groups. The
silhouette method often favors k = 2; also look at the second-best k.

## References

Kaufman, L. and Rousseeuw, P. J. (1990). *Finding Groups in Data: An
Introduction to Cluster Analysis*. Wiley.
[doi:10.1002/9780470316801](https://doi.org/10.1002/9780470316801)

## See also

Other optimal number of clusters:
[`seg_nbclust_gap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_gap.md),
[`seg_nbclust_indices()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_indices.md),
[`seg_nbclust_wss()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_wss.md)

## Examples

``` r
# \donttest{
prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
seg_nbclust_silhouette(prep)$plot

# }
```
