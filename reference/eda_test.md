# Exploratory data analysis: test group differences of several variables

Tests for each variable whether it differs between the groups (e.g. the
clusters of a segmentation): an omnibus test of all groups and, for
numeric variables, comparisons of each group with the total (default),
the rest of the sample, the mean of the group means, or all other
groups.

## Usage

``` r
eda_test(
  data,
  vars,
  group,
  weight = NULL,
  treat_as = c("auto", "numeric", "categorical"),
  method = c("parametric", "nonparametric"),
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

  Name of the grouping variable (e.g. `"cluster_k4"`).

- weight:

  Optional. Name of a weight variable.

- treat_as:

  `"auto"` (default), `"numeric"` or `"categorical"`. See "Numeric or
  categorical?".

- method:

  `"parametric"` (default) or `"nonparametric"`. See "Statistical
  tests".

- reference:

  `"total"` (default), `"rest"`, `"meandev"` or `"groups"`. See
  "Statistical tests".

- p_adjust:

  Method to adjust the p-values of the comparisons (see
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html)).
  Defaults to `"holm"`.

- min_labels:

  Minimum number of value labels or distinct values for a variable to be
  treated as numeric (with `treat_as = "auto"`). Defaults to 5.

## Value

An object of class `eda_test`, a list with the elements:

- `omnibus`: tibble with one row per variable: `test`, `statistic` (F,
  Kruskal-Wallis H or chi-square), `df1`, `df2`, `p`, `effect` (name of
  the effect size), `effect_size`, `effect_ci_low`, `effect_ci_high`,
  `n`.

- `pairwise`: tibble with the comparisons of the numeric variables:
  `group1`, `group2` (the other group, or `"Total"`, `"Rest"`,
  `"Mean of groups"`), `estimate1`, `estimate2` (means, or medians if
  nonparametric), `difference`, `direction`, `se`, `ci_low`, `ci_high`
  (of the difference), `t`, `df`, `p`, `p_adj`.

- `settings`: list of the settings used.

## Details

Numeric and categorical variables are distinguished as in
[`eda_describe()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_describe.md).

## Statistical tests

### Numeric variables: omnibus test

Does the variable differ between any of the groups?

- `method = "parametric"` (default): one-way analysis of variance
  (ANOVA, F-test of the linear model `variable ~ group`; weighted least
  squares if `weight` is given). Effect size: eta squared
  ([`effectsize::eta_squared()`](https://easystats.github.io/effectsize/reference/eta_squared.html)),
  the share of the variance explained by the groups, with confidence
  interval.

- `method = "nonparametric"`: Kruskal-Wallis rank sum test
  ([`stats::kruskal.test()`](https://rdrr.io/r/stats/kruskal.test.html)),
  which compares the distributions of the ranks instead of the means and
  is robust to outliers and skewed or ordinal data. Effect size: rank
  epsilon squared
  ([`effectsize::rank_epsilon_squared()`](https://easystats.github.io/effectsize/reference/rank_epsilon_squared.html)).
  Weights are ignored.

### Numeric variables: comparisons

Which groups differ from the reference? All comparisons are *linear
contrasts* of the group means of one linear model `variable ~ group`,
estimated with
[`modelbased::estimate_contrasts()`](https://easystats.github.io/modelbased/reference/estimate_contrasts.html):

- The standard errors are heteroscedasticity-consistent
  (`vcov = "HC3"`), so the groups may have different variances (as in
  Welch's t-test).

- Each contrast is tested with a t-test (degrees of freedom: residual
  degrees of freedom of the model).

- If `weight` is given, the model is fitted with weighted least squares,
  so the group means and the total are weighted.

- The p-values are adjusted for the number of comparisons within each
  variable (`p_adjust`, default Holm), reported as `p_adj`.

The reference (`reference`) defines the contrasts:

- `"total"` (default): each group vs. the **total including the group**,
  i.e. the (weighted) mean of all respondents, as shown by the "Total"
  bar of
  [`eda_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot.md).
  The contrast is \\\bar{y}\_g - \sum_k p_k \bar{y}\_k\\, with \\p_k\\
  the (weighted) share of group \\k\\. Its standard error accounts for
  the group being part of the total; a simple two-sample test of the
  group against the total would wrongly treat them as independent
  samples.

- `"rest"`: each group vs. the **rest of the sample** (all respondents
  not in the group). As \\\bar{y}\_g - \bar{y}\_{total} = (1 -
  p_g)(\bar{y}\_g - \bar{y}\_{rest})\\, this test has exactly the same
  t- and p-values as `"total"`; only the reported difference is larger.

- `"meandev"`: each group vs. the **unweighted mean of the group means**
  (deviation or "effect" coding, `comparison = "meandev"` in
  [`modelbased::estimate_contrasts()`](https://easystats.github.io/modelbased/reference/estimate_contrasts.html)).
  Every group counts equally, regardless of its size. This equals
  `"total"` only if all groups are of the same size.

- `"groups"`: **all pairs of groups** (`comparison = "pairwise"`).

With `method = "nonparametric"`, the same contrasts are computed on the
ranks of the variable (rank-transformation approach of Conover & Iman,
1981), i.e. the groups are compared by their mean ranks; weights are
ignored. The estimates are then reported as medians, and the standard
errors and confidence intervals (on the rank scale) are omitted.

`direction` tells whether the group (`group1`) is `"higher"` or
`"lower"` than the reference (by the contrast of the means or of the
mean ranks).

### Categorical variables

Pearson's chi-square test of independence of the variable and the groups
([`stats::chisq.test()`](https://rdrr.io/r/stats/chisq.test.html),
without continuity correction). Effect size: Cramér's V
([`effectsize::cramers_v()`](https://easystats.github.io/effectsize/reference/phi.html),
not bias-corrected). If weighted, the weighted contingency table is
rescaled to the unweighted sample size before testing, so that the
weights do not inflate the sample size. There are no comparisons of
single groups for categorical variables.

### Limitations

The weighted tests treat the weights as precision weights of a linear
model. This is an approximation; for design-based inference (strata,
clusters, calibration weights), use the `survey` package. Many tests
(many variables and groups) increase the chance of false positives; the
p-values are only adjusted within each variable, not across variables.

For a detailed plot of a single variable with further tests (e.g. robust
or Bayesian), see
[`eda_plot_detail()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot_detail.md).

## References

Conover, W. J., & Iman, R. L. (1981). Rank transformations as a bridge
between parametric and nonparametric statistics. *The American
Statistician, 35*(3), 124-129.

## See also

Other eda:
[`eda_describe()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_describe.md),
[`eda_explore()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_explore.md),
[`eda_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot.md),
[`eda_plot_detail()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot_detail.md)

## Examples

``` r
eda_test(
  sm_synthetic,
  vars = c("F50_0_1", "F50_0_2", "gender"),
  group = "cluster_benchmark",
  weight = "weight"
)
#> 
#> ── Tests of group differences (cluster_benchmark) 
#> # A tibble: 3 × 13
#>   variable label      type  test  statistic   df1   df2 p     effect effect_size
#>   <chr>    <chr>      <chr> <chr>     <dbl> <int> <dbl> <chr> <chr>        <dbl>
#> 1 F50_0_1  Ich bin e… nume… Weig…    110.       3  1366 < .0… Eta2         0.194
#> 2 F50_0_2  Ich esse … nume… Weig…     63.5      3  1368 < .0… Eta2         0.122
#> 3 gender   GESCHLECHT cate… Chi-…      7.52     3    NA .057  Crame…       0.073
#> # ℹ 3 more variables: effect_ci_low <dbl>, effect_ci_high <dbl>, n <int>
#> 
#> ── Comparisons with the total (p adjusted: holm) 
#> # A tibble: 8 × 14
#>   variable group1   group2 estimate1 estimate2 difference direction    se ci_low
#>   <chr>    <chr>    <chr>      <dbl>     <dbl>      <dbl> <chr>     <dbl>  <dbl>
#> 1 F50_0_1  Ausgewo… Total       7.68      6.87      0.803 higher    0.079  0.649
#> 2 F50_0_1  Nachhal… Total       7.77      6.87      0.899 higher    0.081  0.74 
#> 3 F50_0_1  Pragmat… Total       5.98      6.87     -0.891 lower     0.081 -1.05 
#> 4 F50_0_1  Preisbe… Total       5.68      6.87     -1.20  lower     0.14  -1.47 
#> 5 F50_0_2  Ausgewo… Total       7.10      6.49      0.608 higher    0.084  0.443
#> 6 F50_0_2  Nachhal… Total       7.20      6.49      0.711 higher    0.088  0.538
#> 7 F50_0_2  Pragmat… Total       5.79      6.49     -0.7   lower     0.083 -0.863
#> 8 F50_0_2  Preisbe… Total       5.58      6.49     -0.919 lower     0.127 -1.17 
#> # ℹ 5 more variables: ci_high <dbl>, t <dbl>, df <int>, p <chr>, p_adj <chr>
```
