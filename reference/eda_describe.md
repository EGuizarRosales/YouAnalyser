# Exploratory data analysis: descriptive statistics of several variables

Computes descriptive statistics for several variables at once,
optionally by group (e.g. a cluster solution) and weighted. Numeric
variables are summarized by their mean, standard deviation, standard
error, confidence interval and quantiles; categorical variables by their
(weighted) frequency distribution, using the value labels.

## Usage

``` r
eda_describe(
  data,
  vars,
  group = NULL,
  weight = NULL,
  treat_as = c("auto", "numeric", "categorical"),
  conf_level = 0.95,
  total = FALSE,
  test = FALSE,
  test_method = c("parametric", "nonparametric"),
  reference = c("total", "rest", "meandev", "groups"),
  p_adjust = "holm",
  min_labels = 5
)
```

## Arguments

- data:

  A data frame, typically a haven-labelled tibble, or the output of
  [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md)
  (see "Grouping by a cluster solution").

- vars:

  The variables to describe: a character vector of names or a tidyselect
  expression, e.g. `dplyr::starts_with("F50_0_")`.

- group:

  Optional. Name of a grouping variable (e.g. `"cluster_k4"`).
  Respondents with a missing group are excluded.

- weight:

  Optional. Name of a weight variable.

- treat_as:

  `"auto"` (default), `"numeric"` or `"categorical"`. See "Numeric or
  categorical?".

- conf_level:

  Confidence level of the confidence intervals. Defaults to 0.95.

- total:

  If `TRUE` and `group` is given, a "Total" group with all respondents
  is added. Defaults to `FALSE`.

- test:

  If `TRUE` and `group` is given, group differences are tested with
  [`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md).
  Defaults to `FALSE`.

- test_method:

  `"parametric"` (default) or `"nonparametric"`, passed to
  [`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md).

- reference:

  Reference of the comparisons of the groups, passed to
  [`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md):
  `"total"` (default, each group vs. the total including the group),
  `"rest"` (each group vs. the rest of the sample), `"meandev"` (each
  group vs. the mean of the group means) or `"groups"` (all pairs of
  groups). See
  [`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md),
  "Statistical tests", for details.

- p_adjust:

  Method to adjust the p-values of the comparisons (see
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html)).
  Defaults to `"holm"`.

- min_labels:

  Minimum number of value labels or distinct values for a variable to be
  treated as numeric (with `treat_as = "auto"`). Defaults to 5.

## Value

An object of class `eda_describe`, a list with the elements:

- `numeric`: tibble with one row per numeric variable (and group): `n`
  (valid answers), `n_eff` (effective sample size, only if weighted),
  `missing`, `mean`, `sd`, `se`, `ci_low`, `ci_high`, `median`, `q1`,
  `q3`, `min`, `max`. `NULL` if there are no numeric variables.

- `categorical`: tibble with one row per categorical variable, (group)
  and category: `n` (unweighted count), `n_weighted` and `percent`
  (weighted share among the valid answers, 0-100). `NULL` if there are
  no categorical variables.

- `tests`: the
  [`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md)
  results if `test = TRUE`, otherwise `NULL`.

- `settings`: list of the settings used.

## Details

### Numeric or categorical?

With `treat_as = "auto"`, a variable is summarized as *numeric* (means)
if it has at least `min_labels` value labels (e.g. a 5-point Likert
scale), at least `min_labels` distinct observed values (e.g. a 1-10
scale with labelled end points only) or no value labels at all. Factors,
character vectors and labelled variables with fewer values are
summarized as *categorical* (frequency distributions). Use
`treat_as = "numeric"` or `"categorical"` to treat all variables the
same way.

### Missing values

User-defined missing values (e.g. "don't know" = 99, kept by
`haven::read_sav(user_na = TRUE)`) are set to `NA` before computing any
statistic, so they never distort means or percentages.

### Weights

If `weight` is given, means, standard deviations, quantiles and
percentages are weighted. Standard errors and confidence intervals use
the effective sample size of Kish, \\n\_{eff} = (\sum w)^2 / \sum w^2\\,
which accounts for the loss of precision due to weighting (reported as
`n_eff`).

### Grouping by a cluster solution

`data` can also be the output of
[`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md)
(a `seg_cluster` or a `seg_cluster_set`). Its original data
(`data_full`, all variables with labels, restricted to the clustered
respondents) is used, and each cluster solution is added as a labelled
grouping variable, e.g. `cluster_k4` (noise points of density-based
methods are labelled "Noise").

## See also

[`eda_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot.md)
to plot the statistics,
[`eda_explore()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_explore.md)
to explore them interactively.

Other eda:
[`eda_explore()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_explore.md),
[`eda_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot.md),
[`eda_plot_detail()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot_detail.md),
[`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md)

## Examples

``` r
# Means of a battery of rating items
eda_describe(sm_synthetic, vars = dplyr::starts_with("F50_0_"))
#> 
#> ── Descriptive statistics ──
#> 
#> • Variables: 20 (20 numeric, 0 categorical)
#> • Group: none
#> • Weight: none
#> 
#> ── Numeric variables 
#> # A tibble: 20 × 14
#>    variable label        n missing  mean    sd    se ci_low ci_high median    q1
#>    <chr>    <chr>    <int>   <int> <dbl> <dbl> <dbl>  <dbl>   <dbl>  <dbl> <dbl>
#>  1 F50_0_1  Ich bin…  1370      31  6.91  2.13  0.06   6.8     7.02      7     6
#>  2 F50_0_2  Ich ess…  1372      29  6.5   2.08  0.06   6.39    6.61      7     5
#>  3 F50_0_3  Ich pro…  1377      24  7.36  2.13  0.06   7.25    7.47      8     6
#>  4 F50_0_4  Je natü…  1326      75  7.2   2.22  0.06   7.08    7.32      8     6
#>  5 F50_0_5  Ich nut…  1381      20  3.7   2.38  0.06   3.57    3.82      3     2
#>  6 F50_0_6  Bei mir…  1372      29  4.3   2.35  0.06   4.17    4.42      4     2
#>  7 F50_0_7  Ich ach…  1381      20  7.69  1.81  0.05   7.59    7.78      8     7
#>  8 F50_0_8  Ich bev…  1355      46  5.52  2.7   0.07   5.38    5.67      6     3
#>  9 F50_0_9  Tierisc…  1359      42  7.34  2.26  0.06   7.22    7.46      8     6
#> 10 F50_0_10 Ich ach…  1363      38  5.86  2.62  0.07   5.72    6         6     4
#> 11 F50_0_11 Die Leb…  1323      78  6.95  2.3   0.06   6.83    7.07      7     6
#> 12 F50_0_12 Meiner …  1307      94  6.56  2.74  0.08   6.41    6.71      7     5
#> 13 F50_0_13 Ich kau…  1376      25  5.43  2.88  0.08   5.28    5.58      5     3
#> 14 F50_0_14 Ich ach…  1377      24  7.4   2.13  0.06   7.29    7.51      8     6
#> 15 F50_0_15 Für nac…  1376      25  6.19  2.53  0.07   6.05    6.32      7     5
#> 16 F50_0_16 Mir ist…  1366      35  5.98  2.35  0.06   5.85    6.1       6     5
#> 17 F50_0_17 Ich hal…  1359      42  4.96  2.56  0.07   4.82    5.09      5     3
#> 18 F50_0_18 Ich kau…  1373      28  7.17  2.05  0.06   7.06    7.28      7     6
#> 19 F50_0_19 Ich ach…  1354      47  5.94  2.6   0.07   5.8     6.08      6     4
#> 20 F50_0_20 Ich int…  1355      46  6.45  2.35  0.06   6.33    6.58      7     5
#> # ℹ 3 more variables: q3 <dbl>, min <dbl>, max <dbl>

# By the benchmark segments, weighted, with tests of group differences
eda_describe(
  sm_synthetic,
  vars = c("F50_0_1", "F50_0_2", "gender"),
  group = "cluster_benchmark",
  weight = "weight",
  test = TRUE
)
#> 
#> ── Descriptive statistics ──
#> 
#> • Variables: 3 (2 numeric, 1 categorical)
#> • Group: cluster_benchmark
#> • Weight: weight
#> 
#> ── Numeric variables 
#> # A tibble: 8 × 16
#>   variable label      group     n n_eff missing  mean    sd    se ci_low ci_high
#>   <chr>    <chr>      <fct> <int> <dbl>   <int> <dbl> <dbl> <dbl>  <dbl>   <dbl>
#> 1 F50_0_1  Ich bin e… Ausg…   386  378.      24  7.68  1.71  0.09   7.5     7.85
#> 2 F50_0_1  Ich bin e… Nach…   369  363.       1  7.77  1.72  0.09   7.59    7.95
#> 3 F50_0_1  Ich bin e… Prag…   363  352.       2  5.98  1.75  0.09   5.8     6.17
#> 4 F50_0_1  Ich bin e… Prei…   252  242.       4  5.68  2.56  0.16   5.35    6   
#> 5 F50_0_2  Ich esse … Ausg…   390  382.      20  7.1   1.89  0.1    6.91    7.29
#> 6 F50_0_2  Ich esse … Nach…   367  361.       3  7.2   1.94  0.1    7       7.41
#> 7 F50_0_2  Ich esse … Prag…   362  351.       3  5.79  1.78  0.09   5.61    5.98
#> 8 F50_0_2  Ich esse … Prei…   253  243.       3  5.57  2.26  0.14   5.29    5.86
#> # ℹ 5 more variables: median <dbl>, q1 <dbl>, q3 <dbl>, min <dbl>, max <dbl>
#> 
#> ── Categorical variables 
#> # A tibble: 8 × 7
#>   variable label      group                       value     n n_weighted percent
#>   <chr>    <chr>      <fct>                       <fct> <int>      <dbl>   <dbl>
#> 1 gender   GESCHLECHT Ausgewogener Omnivore       MÄNN…   183       184.    45.5
#> 2 gender   GESCHLECHT Ausgewogener Omnivore       FRAU…   227       221.    54.5
#> 3 gender   GESCHLECHT Nachhaltig-Ökologischer Ge… MÄNN…   163       166.    44.8
#> 4 gender   GESCHLECHT Nachhaltig-Ökologischer Ge… FRAU…   207       204.    55.2
#> 5 gender   GESCHLECHT Pragmatiker                 MÄNN…   175       189.    50.3
#> 6 gender   GESCHLECHT Pragmatiker                 FRAU…   190       187.    49.7
#> 7 gender   GESCHLECHT Preisbewusster Carnivore    MÄNN…   132       140.    54.4
#> 8 gender   GESCHLECHT Preisbewusster Carnivore    FRAU…   124       118.    45.6
#> 
#> ── Tests of group differences (cluster_benchmark) 
#> # A tibble: 3 × 13
#>   variable label      type  test  statistic   df1   df2 p     effect effect_size
#>   <chr>    <chr>      <chr> <chr>     <dbl> <int> <dbl> <chr> <chr>        <dbl>
#> 1 F50_0_1  Ich bin e… nume… Weig…    110.       3  1366 < .0… Eta2          0.19
#> 2 F50_0_2  Ich esse … nume… Weig…     63.5      3  1368 < .0… Eta2          0.12
#> 3 gender   GESCHLECHT cate… Chi-…      7.52     3    NA .057  Crame…        0.07
#> # ℹ 3 more variables: effect_ci_low <dbl>, effect_ci_high <dbl>, n <int>
#> 
#> ── Comparisons with the total (p adjusted: holm) 
#> # A tibble: 8 × 14
#>   variable group1   group2 estimate1 estimate2 difference direction    se ci_low
#>   <chr>    <chr>    <chr>      <dbl>     <dbl>      <dbl> <chr>     <dbl>  <dbl>
#> 1 F50_0_1  Ausgewo… Total       7.68      6.87       0.8  higher     0.08   0.65
#> 2 F50_0_1  Nachhal… Total       7.77      6.87       0.9  higher     0.08   0.74
#> 3 F50_0_1  Pragmat… Total       5.98      6.87      -0.89 lower      0.08  -1.05
#> 4 F50_0_1  Preisbe… Total       5.68      6.87      -1.2  lower      0.14  -1.47
#> 5 F50_0_2  Ausgewo… Total       7.1       6.49       0.61 higher     0.08   0.44
#> 6 F50_0_2  Nachhal… Total       7.2       6.49       0.71 higher     0.09   0.54
#> 7 F50_0_2  Pragmat… Total       5.79      6.49      -0.7  lower      0.08  -0.86
#> 8 F50_0_2  Preisbe… Total       5.57      6.49      -0.92 lower      0.13  -1.17
#> # ℹ 5 more variables: ci_high <dbl>, t <dbl>, df <int>, p <chr>, p_adj <chr>

# \donttest{
# By a cluster solution
prep <- seg_prep_data(sim_segments, vars = dplyr::starts_with("item_"), verbose = FALSE)
km <- seg_cluster(prep, k = 3, plots = FALSE, verbose = FALSE)
eda_describe(km, vars = dplyr::starts_with("item_"), group = "cluster_k3")
#> 
#> ── Descriptive statistics ──
#> 
#> • Variables: 20 (20 numeric, 0 categorical)
#> • Group: cluster_k3
#> • Weight: none
#> 
#> ── Numeric variables 
#> # A tibble: 60 × 15
#>    variable label    group     n missing  mean    sd    se ci_low ci_high median
#>    <chr>    <chr>    <fct> <int>   <int> <dbl> <dbl> <dbl>  <dbl>   <dbl>  <dbl>
#>  1 item_1   Simulat… Clus…   200       0  7.9   1.32  0.09   7.72    8.09      8
#>  2 item_1   Simulat… Clus…   200       0  5.06  1.48  0.1    4.85    5.27      5
#>  3 item_1   Simulat… Clus…   200       0  3.09  1.44  0.1    2.89    3.29      3
#>  4 item_2   Simulat… Clus…   200       0  7.94  1.44  0.1    7.74    8.14      8
#>  5 item_2   Simulat… Clus…   200       0  5.09  1.57  0.11   4.87    5.31      5
#>  6 item_2   Simulat… Clus…   200       0  3.06  1.49  0.11   2.86    3.27      3
#>  7 item_3   Simulat… Clus…   200       0  7.95  1.41  0.1    7.75    8.15      8
#>  8 item_3   Simulat… Clus…   200       0  5.07  1.63  0.12   4.84    5.3       5
#>  9 item_3   Simulat… Clus…   200       0  3.16  1.3   0.09   2.98    3.34      3
#> 10 item_4   Simulat… Clus…   200       0  8.04  1.53  0.11   7.82    8.25      8
#> 11 item_4   Simulat… Clus…   200       0  4.97  1.48  0.1    4.76    5.18      5
#> 12 item_4   Simulat… Clus…   200       0  2.9   1.24  0.09   2.72    3.07      3
#> 13 item_5   Simulat… Clus…   200       0  7.96  1.41  0.1    7.77    8.16      8
#> 14 item_5   Simulat… Clus…   200       0  5.12  1.63  0.12   4.9     5.35      5
#> 15 item_5   Simulat… Clus…   200       0  2.98  1.36  0.1    2.79    3.17      3
#> 16 item_6   Simulat… Clus…   200       0  7.84  1.38  0.1    7.64    8.03      8
#> 17 item_6   Simulat… Clus…   200       0  5.07  1.62  0.11   4.84    5.29      5
#> 18 item_6   Simulat… Clus…   200       0  3.14  1.37  0.1    2.95    3.34      3
#> 19 item_7   Simulat… Clus…   200       0  7.77  1.37  0.1    7.58    7.96      8
#> 20 item_7   Simulat… Clus…   200       0  4.91  1.45  0.1    4.71    5.11      5
#> 21 item_7   Simulat… Clus…   200       0  3.19  1.43  0.1    3       3.39      3
#> 22 item_8   Simulat… Clus…   200       0  3.05  1.44  0.1    2.85    3.25      3
#> 23 item_8   Simulat… Clus…   200       0  4.01  1.45  0.1    3.81    4.21      4
#> 24 item_8   Simulat… Clus…   200       0  7.94  1.41  0.1    7.75    8.14      8
#> 25 item_9   Simulat… Clus…   200       0  2.98  1.36  0.1    2.79    3.16      3
#> 26 item_9   Simulat… Clus…   200       0  3.92  1.44  0.1    3.72    4.13      4
#> 27 item_9   Simulat… Clus…   200       0  8.02  1.28  0.09   7.84    8.2       8
#> 28 item_10  Simulat… Clus…   200       0  3.18  1.49  0.11   2.97    3.39      3
#> 29 item_10  Simulat… Clus…   200       0  4.16  1.54  0.11   3.95    4.38      4
#> 30 item_10  Simulat… Clus…   200       0  7.96  1.49  0.11   7.75    8.16      8
#> 31 item_11  Simulat… Clus…   200       0  3     1.4   0.1    2.8     3.2       3
#> 32 item_11  Simulat… Clus…   200       0  4.2   1.43  0.1    4.01    4.4       4
#> 33 item_11  Simulat… Clus…   200       0  7.89  1.49  0.11   7.68    8.1       8
#> 34 item_12  Simulat… Clus…   200       0  2.86  1.36  0.1    2.67    3.05      3
#> 35 item_12  Simulat… Clus…   200       0  4.04  1.46  0.1    3.83    4.24      4
#> 36 item_12  Simulat… Clus…   200       0  7.92  1.4   0.1    7.73    8.12      8
#> 37 item_13  Simulat… Clus…   200       0  3.17  1.37  0.1    2.98    3.36      3
#> 38 item_13  Simulat… Clus…   200       0  4.07  1.5   0.11   3.86    4.28      4
#> 39 item_13  Simulat… Clus…   200       0  7.88  1.5   0.11   7.67    8.09      8
#> 40 item_14  Simulat… Clus…   200       0  3.02  1.49  0.11   2.81    3.23      3
#> 41 item_14  Simulat… Clus…   200       0  4.24  1.51  0.11   4.02    4.45      4
#> 42 item_14  Simulat… Clus…   200       0  7.92  1.44  0.1    7.72    8.13      8
#> 43 item_15  Simulat… Clus…   200       0  5.08  1.67  0.12   4.84    5.31      5
#> 44 item_15  Simulat… Clus…   200       0  7.83  1.52  0.11   7.62    8.04      8
#> 45 item_15  Simulat… Clus…   200       0  3.99  1.51  0.11   3.78    4.2       4
#> 46 item_16  Simulat… Clus…   200       0  4.93  1.5   0.11   4.72    5.14      5
#> 47 item_16  Simulat… Clus…   200       0  7.88  1.43  0.1    7.69    8.08      8
#> 48 item_16  Simulat… Clus…   200       0  3.89  1.42  0.1    3.69    4.09      4
#> 49 item_17  Simulat… Clus…   200       0  4.9   1.44  0.1    4.7     5.11      5
#> 50 item_17  Simulat… Clus…   200       0  7.93  1.34  0.09   7.75    8.12      8
#> 51 item_17  Simulat… Clus…   200       0  3.9   1.52  0.11   3.69    4.11      4
#> 52 item_18  Simulat… Clus…   200       0  5.18  1.47  0.1    4.98    5.39      5
#> 53 item_18  Simulat… Clus…   200       0  7.87  1.4   0.1    7.68    8.06      8
#> 54 item_18  Simulat… Clus…   200       0  4.13  1.54  0.11   3.92    4.34      4
#> 55 item_19  Simulat… Clus…   200       0  4.99  1.64  0.12   4.76    5.22      5
#> 56 item_19  Simulat… Clus…   200       0  8.07  1.35  0.1    7.88    8.26      8
#> 57 item_19  Simulat… Clus…   200       0  4.07  1.45  0.1    3.87    4.27      4
#> 58 item_20  Simulat… Clus…   200       0  5.03  1.6   0.11   4.81    5.25      5
#> 59 item_20  Simulat… Clus…   200       0  8.02  1.42  0.1    7.82    8.21      8
#> 60 item_20  Simulat… Clus…   200       0  3.85  1.5   0.11   3.64    4.06      4
#> # ℹ 4 more variables: q1 <dbl>, q3 <dbl>, min <dbl>, max <dbl>
# }
```
