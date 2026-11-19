# Prepare survey data for cluster analysis

Prepares a (haven-labelled) data frame for segmentation: selects the
clustering variables, handles missing values, rescales the variables and
(optionally) computes a distance matrix using
[`factoextra::get_dist()`](https://rpkgs.datanovia.com/factoextra/reference/dist.html)
or [`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html).

## Usage

``` r
seg_prep_data(
  data,
  vars = dplyr::everything(),
  id = NULL,
  missing = c("omit", "mean", "median", "mice", "none"),
  max_missing_prop = NULL,
  scale = c("z", "range", "none"),
  distance = "euclidean",
  distance_engine = c("auto", "get_dist", "daisy"),
  compute_distance = TRUE,
  imputation_args = list(),
  daisy_args = list(),
  seed = 123,
  verbose = TRUE
)
```

## Arguments

- data:

  A data frame, typically a haven-labelled tibble (e.g. read in with
  `haven::read_sav(path, user_na = TRUE)`). User-defined missing values
  (e.g. 99 = "don't know") must already be recoded to `NA`, e.g. with
  [`dp_recode_missing()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_recode_missing.md).

- vars:

  \<[`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html)\>
  Clustering variables. Must be numeric (haven-labelled numeric
  variables are fine). Defaults to all variables.

- id:

  Optional single string naming an identifier column in `data`. Its
  values are used as row names of the prepared data and labels of the
  distance matrix (e.g. for
  [`factoextra::fviz_dist()`](https://rpkgs.datanovia.com/factoextra/reference/dist.html)).

- missing:

  How to handle missing values in the clustering variables. Respondents
  without any valid answer on the clustering variables are always
  removed first.

  - `"omit"` (default): listwise deletion of respondents with any
    missing value.

  - `"mean"` / `"median"`: replace missing values with the variable mean
    / median.

  - `"mice"`: single imputation with
    [`mice::mice()`](https://amices.org/mice/reference/mice.html)
    (predictive mean matching by default, see `imputation_args`).
    Preserves the relationships between variables better than
    mean/median imputation.

  - `"none"`: keep missing values. Only allowed with
    `distance_engine = "daisy"`, which computes dissimilarities from the
    available pairs of values.

- max_missing_prop:

  Optional number between 0 and 1. Respondents with a higher proportion
  of missing values across the clustering variables are removed *before*
  `missing` is applied. Useful to combine with imputation, e.g.
  `max_missing_prop = 0.2, missing = "mice"`. `NULL` (default) keeps all
  respondents.

- scale:

  How to rescale the clustering variables:

  - `"z"` (default): z-standardization (mean 0, SD 1), see
    [`base::scale()`](https://rdrr.io/r/base/scale.html).

  - `"range"`: min-max scaling to the range 0 to 1.

  - `"none"`: keep the original values, e.g. if all variables share the
    same response scale and differences in variance are meaningful.

- distance:

  Distance measure. With `distance_engine = "get_dist"` one of
  `"euclidean"`, `"maximum"`, `"manhattan"`, `"canberra"`, `"binary"`,
  `"minkowski"`, `"pearson"`, `"spearman"` or `"kendall"`. With
  `distance_engine = "daisy"` one of `"euclidean"`, `"manhattan"` or
  `"gower"`. Defaults to `"euclidean"`.

- distance_engine:

  Which function computes the distance matrix: `"auto"` (default) uses
  [`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html) for
  `distance = "gower"` and
  [`factoextra::get_dist()`](https://rpkgs.datanovia.com/factoextra/reference/dist.html)
  otherwise; `"get_dist"` or `"daisy"` force the respective function.

- compute_distance:

  Logical. Whether to compute the distance matrix. Defaults to `TRUE`.
  Set to `FALSE` for large samples if only the prepared data is needed
  (e.g. for k-means), as the distance matrix grows with the square of
  the number of respondents.

- imputation_args:

  A list of arguments passed to
  [`mice::mice()`](https://amices.org/mice/reference/mice.html) when
  `missing = "mice"`, added to the defaults `method = "pmm"` (predictive
  mean matching) and `printFlag = FALSE`, e.g. `list(method = "cart")`.
  Only a single imputation (`m = 1`) is used. A `seed` given here takes
  precedence over `seed`.

- daisy_args:

  A list of further arguments passed to
  [`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html), e.g.
  `list(type = list(ordratio = c("F50_0_1", "F50_0_2")))` to treat
  variables as ordinal when using Gower distance.

- seed:

  Random seed for the imputation with `missing = "mice"`, which makes
  the imputed values reproducible. The global random seed is left
  untouched. Defaults to 123. `NULL` uses the current random state (not
  reproducible).

- verbose:

  Logical. Whether to print a summary of the preparation steps. Defaults
  to `TRUE`.

## Value

An object of class `seg_prep`, a list with the elements:

- `data`: tibble with the prepared (cleaned, imputed, rescaled)
  clustering variables, keeping their variable labels. Use this as input
  for clustering algorithms such as k-means.

- `data_full`: the original `data` (all columns, labels intact)
  restricted to the respondents retained in `data`, in the same order.
  Use this to profile the resulting segments.

- `dist`: the distance matrix (class `dist`), or `NULL` if
  `compute_distance = FALSE`.

- `row_index`: integer positions of the retained respondents in `data`.

- `settings`: list of the settings used, including the parameters needed
  to prepare new respondents in the same way (see
  [`predict.seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/predict.seg_cluster.md)):
  `scaling` (tibble with the center and scale of each clustering
  variable), `impute_values` (the means or medians used for imputation),
  `imputation_args` and `seed`.

- `info`: list with the number of respondents before and after the
  preparation, the number of imputed values and dropped constant
  variables.

## Details

Cluster analysis groups respondents that are *similar*. How similarity
is measured is defined by the distance measure, which is therefore one
of the most important choices of a segmentation. The descriptions below
follow
[datanovia](https://www.datanovia.com/learn/machine-learning/clustering/distance-measures).
\\x\\ and \\y\\ denote the answers of two respondents on the \\n\\
clustering variables.

### Distance-based measures

These measures compare the *values* of two respondents: respondents with
similar answers on all variables are close.

- **Euclidean** (`"euclidean"`, default): \\d(x, y) =
  \sqrt{\sum\_{i=1}^n (x_i - y_i)^2}\\. The straight-line distance.
  Large differences weigh more, as they are squared. *Use it* as the
  default, in particular with k-means and Ward's hierarchical
  clustering, which are built on it (k-means always uses Euclidean
  distances, whatever is specified here).

- **Manhattan** (`"manhattan"`): \\d(x, y) = \sum\_{i=1}^n \|x_i -
  y_i\|\\. The sum of the absolute differences ("city block" distance).
  Less sensitive to outliers and single extreme answers than Euclidean.
  *Use it* for rating scales, where differences of one scale point
  simply add up, or if the data contains outliers; works well with PAM.

- **Maximum** (`"maximum"`, Chebyshev distance): \\d(x, y) = \max_i
  \|x_i - y_i\|\\. Only the largest difference on any single variable
  counts. *Rarely useful* for survey data, as a single item dominates
  the distance.

- **Minkowski** (`"minkowski"`): \\d(x, y) = (\sum\_{i=1}^n \|x_i -
  y_i\|^p)^{1/p}\\, a generalization of Manhattan (\\p = 1\\) and
  Euclidean (\\p = 2\\, used here).

- **Canberra** (`"canberra"`): \\d(x, y) = \sum\_{i=1}^n \|x_i - y_i\| /
  (\|x_i\| + \|y_i\|)\\. A weighted Manhattan distance, in which
  differences between small values weigh more. *Use it* only for
  non-negative data (e.g. counts or shares, with `scale = "range"` or
  `"none"`), not with z-standardized data.

- **Binary** (`"binary"`): the proportion of variables in which only one
  of the two respondents has a non-zero value, among the variables in
  which at least one has a non-zero value. *Use it* for 0/1 data, e.g.
  multiple-response questions (with `scale = "none"`).

### Correlation-based measures

These measures compare the *profiles* of two respondents across the
variables: two respondents are close if their answers go up and down
together, regardless of their overall level. The distance is \\d(x, y) =
1 - r(x, y)\\, where \\r\\ is a correlation coefficient between the
answers of the two respondents (range 0 to 2).

- **Pearson** (`"pearson"`): based on the Pearson correlation.

- **Spearman** (`"spearman"`): based on the rank correlation. More
  robust to outliers and only assumes a monotonic relation; well suited
  for ordinal rating scales.

- **Kendall** (`"kendall"`): based on the proportion of concordant pairs
  of ranks. Similar to Spearman, more robust with many ties, but slower.

*Use them* when the *pattern* of answers matters more than their level,
e.g. to reduce the influence of response styles: a respondent who agrees
a bit more with every item (acquiescence) has the same profile as a
respondent with the same relative preferences. They require a fair
number of clustering variables, as the correlation is computed across
them for each pair of respondents.

### Gower distance

**Gower** (`"gower"`, via
[`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html)): each
variable contributes a distance between 0 and 1 (the absolute difference
divided by the range for numeric variables, 0/1 for a mismatch for
nominal variables, ranks for ordinal variables), and the distance is the
average over all variables that both respondents answered. *Use it* for
mixed data types (see `daisy_args`) or to keep missing values
(`missing = "none"`). Combine it with PAM or hierarchical clustering,
not with k-means.

### Choosing a distance measure and scaling

- Typical attitude batteries on the same rating scale: Euclidean
  (default) or Manhattan; Spearman or Pearson to cluster on answer
  patterns.

- Data with outliers or extreme answers: Manhattan (with PAM).

- Binary data: binary; mixed data types or missing values: Gower.

Distance-based measures depend on the scale of the variables: variables
with a large range or variance dominate the distance. Variables measured
on different scales must therefore be rescaled (`scale = "z"` or
`"range"`). For items on the same scale, z-standardization gives each
item the same weight; use `scale = "none"` if differences in variance
are meaningful.

## See also

[`seg_distance()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_distance.md)
to compute a distance matrix on already prepared data.

## Examples

``` r
# \donttest{
prep <- seg_prep_data(
  sm_synthetic,
  vars = dplyr::starts_with("F50_0_"),
  id = "id",
  missing = "mice",
  max_missing_prop = 0.2
)
#> 
#> ── Data prepared for cluster analysis ──
#> 
#> • Clustering variables: 20
#> • Respondents: 1401 in, 1371 retained
#> • Without any valid answer: 1 respondent removed
#> • Missing threshold: 29 respondent(s) with more than 20% missing removed
#> • Missing values: "mice" (0 respondents removed, 407 values imputed)
#> • Scaling: "z"
#> • Distance: euclidean (get_dist)
# }
```
