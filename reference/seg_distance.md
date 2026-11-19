# Compute a distance matrix for cluster analysis

Thin wrapper around
[`factoextra::get_dist()`](https://rpkgs.datanovia.com/factoextra/reference/dist.html)
and [`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html)
with a common interface. Usually called via
[`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md),
but can be used on its own on already prepared (e.g. standardized) data.

## Usage

``` r
seg_distance(
  x,
  distance = "euclidean",
  distance_engine = c("auto", "get_dist", "daisy"),
  labels = NULL,
  daisy_args = list()
)
```

## Arguments

- x:

  A data frame or numeric matrix with the (prepared) clustering
  variables.

- distance:

  Distance measure, see
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md).

- distance_engine:

  `"auto"`, `"get_dist"` or `"daisy"`, see
  [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md).

- labels:

  Optional vector of labels for the observations (length `nrow(x)`),
  used as labels of the distance matrix.

- daisy_args:

  A list of further arguments passed to
  [`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html).

## Value

A distance matrix of class `dist` (for `"daisy"` additionally of class
`dissimilarity`).

## Examples

``` r
x <- scale(datasets::USArrests)
d <- seg_distance(x, distance = "manhattan")
d_gower <- seg_distance(datasets::USArrests, distance = "gower")
```
