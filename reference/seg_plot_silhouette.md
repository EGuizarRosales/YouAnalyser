# Silhouette plot of a cluster solution

Plots the silhouette width of each respondent, sorted by cluster and
silhouette width, with
[`factoextra::fviz_silhouette()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_silhouette.html).
The dashed line shows the average silhouette width (silhouette
coefficient). Long bars indicate well clustered respondents, bars around
0 respondents between two clusters, and negative bars respondents that
are closer to another cluster than to their own (probably
misclassified). See
[`seg_validation()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_validation.md)
for the definition and interpretation of the silhouette width.

## Usage

``` r
seg_plot_silhouette(object, ...)
```

## Arguments

- object:

  A `seg_cluster` object, e.g. from
  [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md).

- ...:

  Arguments passed to
  [`factoextra::fviz_silhouette()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_silhouette.html)
  (and on to
  [`ggpubr::ggpar()`](https://rpkgs.datanovia.com/ggpubr/reference/ggpar.html)),
  overriding the defaults, e.g. `label = TRUE` or
  `ggtheme = ggplot2::theme_minimal()`.

## Value

A ggplot object, or `NULL` (with a message) for solutions with fewer
than two clusters.

## Details

The silhouette widths are computed on the distance matrix of the
prepared data (or with its distance measure, if the matrix is not
available). Respondents classified as noise (cluster 0) are excluded.

## See also

Other validation:
[`seg_validation()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_validation.md)

## Examples

``` r
# \donttest{
prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
cl <- seg_cluster(prep, k = 3, plots = FALSE, verbose = FALSE)
seg_plot_silhouette(cl)

# }
```
