# Plot a cluster solution in the space of the principal components

Plots the respondents in the space of the first two principal
components, colored by cluster, using
[`factoextra::fviz_cluster()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_cluster.html).
The defaults depend on the clustering family:

## Usage

``` r
seg_plot_cluster(object, ...)
```

## Arguments

- object:

  A `seg_cluster` object, e.g. from
  [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md).

- ...:

  Arguments passed to
  [`factoextra::fviz_cluster()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_cluster.html),
  overriding the defaults.

## Value

A ggplot object.

## Details

- partitioning, fuzzy and external solutions: `ellipse.type = "euclid"`
  (circles around the cluster centers) and `star.plot = TRUE` (segments
  from each respondent to its cluster center),

- hierarchical clustering: `ellipse.type = "convex"` (convex hulls) and
  `show.clust.cent = FALSE`,

- model-based clustering: `ellipse.type = "norm"` (normal ellipses),

- density-based clustering: convex hulls, noise in grey.

The principal components are computed on the prepared clustering
variables (`stand = FALSE`, as the variables are already rescaled by
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)).
With many clustering variables, the first two components explain only
part of the variance (see the axis labels).

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
[`seg_dbscan_eps()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_dbscan_eps.md),
[`seg_plot_centers()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_centers.md),
[`seg_plot_dend()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_dend.md),
[`seg_plot_heatmap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_heatmap.md)
