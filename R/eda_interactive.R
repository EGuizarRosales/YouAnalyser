# Descriptive statistics, group comparisons and plots of several variables at
# once (eda_describe(), eda_test(), eda_plot()) and an interactive Shiny gadget
# built on top of them (eda_explore()).

# ---- Exported: descriptive statistics ----------------------------------------

# marginaleffects and sandwich are used by modelbased::estimate_contrasts()
# (backend and HC3 standard errors), but are only suggested by modelbased
#' @importFrom marginaleffects avg_predictions
#' @importFrom sandwich vcovHC
#' @noRd
NULL

#' Exploratory data analysis: descriptive statistics of several variables
#'
#' @description
#' Computes descriptive statistics for several variables at once, optionally
#' by group (e.g. a cluster solution) and weighted. Numeric variables are
#' summarized by their mean, standard deviation, standard error, confidence
#' interval and quantiles; categorical variables by their (weighted)
#' frequency distribution, using the value labels.
#'
#' @details
#' ## Numeric or categorical?
#'
#' With `treat_as = "auto"`, a variable is summarized as *numeric* (means) if
#' it has at least `min_labels` value labels (e.g. a 5-point Likert scale),
#' at least `min_labels` distinct observed values (e.g. a 1-10 scale with
#' labelled end points only) or no value labels at all. Factors, character
#' vectors and labelled variables with fewer values are summarized as
#' *categorical* (frequency distributions). Use `treat_as = "numeric"` or
#' `"categorical"` to treat all variables the same way.
#'
#' ## Missing values
#'
#' User-defined missing values (e.g. "don't know" = 99, kept by
#' `haven::read_sav(user_na = TRUE)`) are set to `NA` before computing any
#' statistic, so they never distort means or percentages.
#'
#' ## Weights
#'
#' If `weight` is given, means, standard deviations, quantiles and
#' percentages are weighted. Standard errors and confidence intervals use the
#' effective sample size of Kish, \eqn{n_{eff} = (\sum w)^2 / \sum w^2}, which
#' accounts for the loss of precision due to weighting (reported as `n_eff`).
#'
#' ## Grouping by a cluster solution
#'
#' `data` can also be the output of [seg_cluster()] (a `seg_cluster` or a
#' `seg_cluster_set`). Its original data (`data_full`, all variables with
#' labels, restricted to the clustered respondents) is used, and each cluster
#' solution is added as a labelled grouping variable, e.g. `cluster_k4` (noise
#' points of density-based methods are labelled "Noise").
#'
#' @param data A data frame, typically a haven-labelled tibble, or the output
#'   of [seg_cluster()] (see "Grouping by a cluster solution").
#' @param vars The variables to describe: a character vector of names or a
#'   tidyselect expression, e.g. `dplyr::starts_with("F50_0_")`.
#' @param group Optional. Name of a grouping variable (e.g. `"cluster_k4"`).
#'   Respondents with a missing group are excluded.
#' @param weight Optional. Name of a weight variable.
#' @param treat_as `"auto"` (default), `"numeric"` or `"categorical"`. See
#'   "Numeric or categorical?".
#' @param conf_level Confidence level of the confidence intervals. Defaults to
#'   0.95.
#' @param total If `TRUE` and `group` is given, a "Total" group with all
#'   respondents is added. Defaults to `FALSE`.
#' @param test If `TRUE` and `group` is given, group differences are tested
#'   with [eda_test()]. Defaults to `FALSE`.
#' @param test_method `"parametric"` (default) or `"nonparametric"`, passed
#'   to [eda_test()].
#' @param reference Reference of the comparisons of the groups, passed to
#'   [eda_test()]: `"total"` (default, each group vs. the total including
#'   the group), `"rest"` (each group vs. the rest of the sample),
#'   `"meandev"` (each group vs. the mean of the group means) or `"groups"`
#'   (all pairs of groups). See [eda_test()], "Statistical tests", for
#'   details.
#' @param p_adjust Method to adjust the p-values of the comparisons (see
#'   [stats::p.adjust()]). Defaults to `"holm"`.
#' @param min_labels Minimum number of value labels or distinct values for a
#'   variable to be treated as numeric (with `treat_as = "auto"`). Defaults
#'   to 5.
#'
#' @returns An object of class `eda_describe`, a list with the elements:
#'   * `numeric`: tibble with one row per numeric variable (and group): `n`
#'     (valid answers), `n_eff` (effective sample size, only if weighted),
#'     `missing`, `mean`, `sd`, `se`, `ci_low`, `ci_high`, `median`, `q1`,
#'     `q3`, `min`, `max`. `NULL` if there are no numeric variables.
#'   * `categorical`: tibble with one row per categorical variable, (group)
#'     and category: `n` (unweighted count), `n_weighted` and `percent`
#'     (weighted share among the valid answers, 0-100). `NULL` if there are
#'     no categorical variables.
#'   * `tests`: the [eda_test()] results if `test = TRUE`, otherwise `NULL`.
#'   * `settings`: list of the settings used.
#'
#' @family eda
#' @seealso [eda_plot()] to plot the statistics, [eda_explore()] to explore
#'   them interactively.
#'
#' @export
#' @examples
#' # Means of a battery of rating items
#' eda_describe(sm_synthetic, vars = dplyr::starts_with("F50_0_"))
#'
#' # By the benchmark segments, weighted, with tests of group differences
#' eda_describe(
#'   sm_synthetic,
#'   vars = c("F50_0_1", "F50_0_2", "gender"),
#'   group = "cluster_benchmark",
#'   weight = "weight",
#'   test = TRUE
#' )
#'
#' \donttest{
#' # By a cluster solution
#' prep <- seg_prep_data(sim_segments, vars = dplyr::starts_with("item_"), verbose = FALSE)
#' km <- seg_cluster(prep, k = 3, plots = FALSE, verbose = FALSE)
#' eda_describe(km, vars = dplyr::starts_with("item_"), group = "cluster_k3")
#' }
eda_describe <- function(
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
) {
  treat_as <- rlang::arg_match(treat_as)
  test_method <- rlang::arg_match(test_method)
  reference <- rlang::arg_match(reference)
  data <- eda_resolve_data(data)
  vars <- eda_select(data, {{ vars }})
  prep <- eda_prepare(data, vars, group, weight, treat_as, min_labels)

  num_vars <- vars[prep$types == "numeric"]
  cat_vars <- vars[prep$types == "categorical"]

  numeric <- if (length(num_vars) > 0) {
    eda_long_numeric(prep, num_vars, total) |>
      eda_stats_numeric(conf_level) |>
      eda_finish_table(prep, weighted = !is.null(weight))
  }
  categorical <- if (length(cat_vars) > 0) {
    eda_stats_categorical(prep, cat_vars, total) |>
      eda_finish_table(prep, weighted = !is.null(weight))
  }

  tests <- if (test && !is.null(group)) {
    eda_test_prepared(prep, vars, test_method, reference, p_adjust, conf_level)
  }

  structure(
    list(
      numeric = numeric,
      categorical = categorical,
      tests = tests,
      settings = list(
        vars = vars,
        types = prep$types,
        group = group,
        weight = weight,
        treat_as = treat_as,
        conf_level = conf_level
      )
    ),
    class = c("eda_describe", "list")
  )
}

#' @export
print.eda_describe <- function(x, digits = 2, ...) {
  settings <- x$settings
  cli::cli_h2("Descriptive statistics")
  cli::cli_bullets(c(
    "*" = "Variables: {length(settings$vars)} ({sum(settings$types == 'numeric')} numeric, {sum(settings$types == 'categorical')} categorical)",
    "*" = "Group: {settings$group %||% 'none'}",
    "*" = "Weight: {settings$weight %||% 'none'}"
  ))
  if (!is.null(x$numeric)) {
    cli::cli_h3("Numeric variables")
    eda_print_table(x$numeric, digits)
  }
  if (!is.null(x$categorical)) {
    cli::cli_h3("Categorical variables")
    eda_print_table(x$categorical, digits)
  }
  if (!is.null(x$tests)) {
    print(x$tests, digits = digits)
  }
  invisible(x)
}


# ---- Exported: tests of group differences ------------------------------------

#' Exploratory data analysis: test group differences of several variables
#'
#' @description
#' Tests for each variable whether it differs between the groups (e.g. the
#' clusters of a segmentation): an omnibus test of all groups and, for
#' numeric variables, comparisons of each group with the total (default), the
#' rest of the sample, the mean of the group means, or all other groups.
#'
#' @details
#' Numeric and categorical variables are distinguished as in
#' [eda_describe()].
#'
#' # Statistical tests
#'
#' ## Numeric variables: omnibus test
#'
#' Does the variable differ between any of the groups?
#' * `method = "parametric"` (default): one-way analysis of variance (ANOVA,
#'   F-test of the linear model `variable ~ group`; weighted least squares if
#'   `weight` is given). Effect size: eta squared
#'   ([effectsize::eta_squared()]), the share of the variance explained by
#'   the groups, with confidence interval.
#' * `method = "nonparametric"`: Kruskal-Wallis rank sum test
#'   ([stats::kruskal.test()]), which compares the distributions of the ranks
#'   instead of the means and is robust to outliers and skewed or ordinal
#'   data. Effect size: rank epsilon squared
#'   ([effectsize::rank_epsilon_squared()]). Weights are ignored.
#'
#' ## Numeric variables: comparisons
#'
#' Which groups differ from the reference? All comparisons are *linear
#' contrasts* of the group means of one linear model `variable ~ group`,
#' estimated with [modelbased::estimate_contrasts()]:
#' * The standard errors are heteroscedasticity-consistent (`vcov = "HC3"`),
#'   so the groups may have different variances (as in Welch's t-test).
#' * Each contrast is tested with a t-test (degrees of freedom: residual
#'   degrees of freedom of the model).
#' * If `weight` is given, the model is fitted with weighted least squares,
#'   so the group means and the total are weighted.
#' * The p-values are adjusted for the number of comparisons within each
#'   variable (`p_adjust`, default Holm), reported as `p_adj`.
#'
#' The reference (`reference`) defines the contrasts:
#' * `"total"` (default): each group vs. the **total including the group**,
#'   i.e. the (weighted) mean of all respondents, as shown by the "Total" bar
#'   of [eda_plot()]. The contrast is \eqn{\bar{y}_g - \sum_k p_k \bar{y}_k},
#'   with \eqn{p_k} the (weighted) share of group \eqn{k}. Its standard error
#'   accounts for the group being part of the total; a simple two-sample test
#'   of the group against the total would wrongly treat them as independent
#'   samples.
#' * `"rest"`: each group vs. the **rest of the sample** (all respondents not
#'   in the group). As \eqn{\bar{y}_g - \bar{y}_{total} = (1 - p_g)(\bar{y}_g
#'   - \bar{y}_{rest})}, this test has exactly the same t- and p-values as
#'   `"total"`; only the reported difference is larger.
#' * `"meandev"`: each group vs. the **unweighted mean of the group means**
#'   (deviation or "effect" coding, `comparison = "meandev"` in
#'   [modelbased::estimate_contrasts()]). Every group counts equally,
#'   regardless of its size. This equals `"total"` only if all groups are of
#'   the same size.
#' * `"groups"`: **all pairs of groups** (`comparison = "pairwise"`).
#'
#' With `method = "nonparametric"`, the same contrasts are computed on the
#' ranks of the variable (rank-transformation approach of Conover & Iman,
#' 1981), i.e. the groups are compared by their mean ranks; weights are
#' ignored. The estimates are then reported as medians, and the standard
#' errors and confidence intervals (on the rank scale) are omitted.
#'
#' `direction` tells whether the group (`group1`) is `"higher"` or `"lower"`
#' than the reference (by the contrast of the means or of the mean ranks).
#'
#' ## Categorical variables
#'
#' Pearson's chi-square test of independence of the variable and the groups
#' ([stats::chisq.test()], without continuity correction). Effect size:
#' Cramér's V ([effectsize::cramers_v()], not bias-corrected). If weighted,
#' the weighted contingency table is rescaled to the unweighted sample size
#' before testing, so that the weights do not inflate the sample size. There
#' are no comparisons of single groups for categorical variables.
#'
#' ## Limitations
#'
#' The weighted tests treat the weights as precision weights of a linear
#' model. This is an approximation; for design-based inference (strata,
#' clusters, calibration weights), use the `survey` package. Many tests (many
#' variables and groups) increase the chance of false positives; the
#' p-values are only adjusted within each variable, not across variables.
#'
#' For a detailed plot of a single variable with further tests (e.g. robust
#' or Bayesian), see [eda_plot_detail()].
#'
#' @references Conover, W. J., & Iman, R. L. (1981). Rank transformations as
#'   a bridge between parametric and nonparametric statistics. *The American
#'   Statistician, 35*(3), 124-129.
#'
#' @inheritParams eda_describe
#' @param group Name of the grouping variable (e.g. `"cluster_k4"`).
#' @param method `"parametric"` (default) or `"nonparametric"`. See
#'   "Statistical tests".
#' @param reference `"total"` (default), `"rest"`, `"meandev"` or `"groups"`.
#'   See "Statistical tests".
#'
#' @returns An object of class `eda_test`, a list with the elements:
#'   * `omnibus`: tibble with one row per variable: `test`, `statistic` (F,
#'     Kruskal-Wallis H or chi-square), `df1`, `df2`, `p`, `effect` (name of
#'     the effect size), `effect_size`, `effect_ci_low`, `effect_ci_high`,
#'     `n`.
#'   * `pairwise`: tibble with the comparisons of the numeric variables:
#'     `group1`, `group2` (the other group, or `"Total"`, `"Rest"`, `"Mean of
#'     groups"`), `estimate1`, `estimate2` (means, or medians if
#'     nonparametric), `difference`, `direction`, `se`, `ci_low`, `ci_high`
#'     (of the difference), `t`, `df`, `p`, `p_adj`.
#'   * `settings`: list of the settings used.
#'
#' @family eda
#'
#' @export
#' @examples
#' eda_test(
#'   sm_synthetic,
#'   vars = c("F50_0_1", "F50_0_2", "gender"),
#'   group = "cluster_benchmark",
#'   weight = "weight"
#' )
eda_test <- function(
  data,
  vars,
  group,
  weight = NULL,
  treat_as = c("auto", "numeric", "categorical"),
  method = c("parametric", "nonparametric"),
  reference = c("total", "rest", "meandev", "groups"),
  p_adjust = "holm",
  min_labels = 5
) {
  treat_as <- rlang::arg_match(treat_as)
  method <- rlang::arg_match(method)
  reference <- rlang::arg_match(reference)
  data <- eda_resolve_data(data)
  vars <- eda_select(data, {{ vars }})
  if (missing(group) || is.null(group)) {
    cli::cli_abort("{.arg group} is required to test group differences.")
  }
  prep <- eda_prepare(data, vars, group, weight, treat_as, min_labels)
  eda_test_prepared(prep, vars, method, reference, p_adjust)
}

#' @export
print.eda_test <- function(x, digits = 3, ...) {
  cli::cli_h3("Tests of group differences ({x$settings$group})")
  x$omnibus |>
    dplyr::mutate(p = eda_format_p(.data$p)) |>
    eda_print_table(digits)
  if (nrow(x$pairwise) > 0) {
    title <- eda_comparison_title(x$settings$reference)
    cli::cli_h3("{title} (p adjusted: {x$settings$p_adjust})")
    x$pairwise |>
      dplyr::mutate(
        p = eda_format_p(.data$p),
        p_adj = eda_format_p(.data$p_adj)
      ) |>
      eda_print_table(digits)
  }
  invisible(x)
}


# ---- Exported: plots ---------------------------------------------------------

#' Exploratory data analysis: plot several variables in one plot
#'
#' @description
#' Plots several variables at once, optionally by group (e.g. a cluster
#' solution) and weighted: bar charts of the means with error bars, boxplots,
#' or stacked bar charts of the frequency distributions. Variables are shown
#' with their variable labels.
#'
#' @details
#' With `type = "auto"`, the means are plotted as bar chart if all variables
#' are numeric (see [eda_describe()]), otherwise the distributions are shown
#' as stacked bar chart. `type = "bar"` and `type = "box"` treat all
#' variables as numeric (e.g. to plot the mean of a 4-point scale),
#' `type = "stacked"` treats all as categorical (e.g. to show the
#' distribution of a 5-point Likert scale).
#'
#' ## Significant differences
#'
#' With `show_sig = TRUE` (bar charts and boxplots with a group), significant
#' differences are marked next to the bars or boxes. The tests are the
#' comparisons of [eda_test()] (see "Statistical tests" there): t-tests of
#' linear contrasts of the (weighted) group means with robust (HC3) standard
#' errors (`test_method = "parametric"`), or of the mean ranks
#' (`"nonparametric"`), Holm-adjusted within each variable, at significance
#' level `alpha`.
#' * `reference = "total"` (default), `"rest"` or `"meandev"`: triangles
#'   pointing up (green, `yougov_colors[["Green 2"]]`) / down (red, `yougov_colors[["Red 2"]]`) mark groups that are significantly higher / lower
#'   than the total (including the group), the rest of the sample, or the
#'   mean of the group means.
#' * `reference = "groups"`: each group gets a letter (A, B, C, ...) and each
#'   bar shows the letters of the groups it significantly exceeds.
#'
#' The subtitle of the plot states the test and the reference.
#'
#' @inheritParams eda_describe
#' @param type `"auto"` (default), `"bar"` (means), `"box"` (boxplots) or
#'   `"stacked"` (frequency distributions). See "Details".
#' @param orientation `"horizontal"` (default) or `"vertical"` bars.
#' @param error Error bars of bar charts: `"ci"` (confidence interval,
#'   default), `"se"` (standard error), `"sd"` (standard deviation) or
#'   `"none"`.
#' @param facet If `TRUE`, each variable is shown in its own panel with free
#'   axes (useful for variables on different scales). Defaults to `FALSE`.
#' @param show_values If `TRUE` (default), the means or percentages are
#'   printed on the bars.
#' @param show_sig If `TRUE`, significant group differences are marked (bar
#'   charts and boxplots with a group). Defaults to `FALSE`. See "Significant
#'   differences".
#' @param reference `"total"` (default), `"rest"`, `"meandev"` or
#'   `"groups"`. See "Significant differences".
#' @param test_method `"parametric"` (default) or `"nonparametric"`. See
#'   "Significant differences".
#' @param alpha Significance level for `show_sig`. Defaults to 0.05.
#' @param axis_labels Labels of the variables: `"label"` (variable label,
#'   default), `"name"` (variable name) or `"both"`.
#' @param label_width Maximum number of characters per line of the variable
#'   labels. Defaults to 40 for horizontal and 15 for vertical plots.
#' @param digits Number of decimals of the values on the bars. Defaults to 1.
#' @param title Optional plot title.
#'
#' @returns A ggplot object.
#'
#' @family eda
#'
#' @export
#' @examples
#' items <- paste0("F50_0_", 1:6)
#'
#' # Means with 95% confidence intervals
#' eda_plot(sm_synthetic, vars = items)
#'
#' # By the benchmark segments, weighted, with differences from the total
#' eda_plot(
#'   sm_synthetic,
#'   vars = items,
#'   group = "cluster_benchmark",
#'   weight = "weight",
#'   total = TRUE,
#'   show_sig = TRUE
#' )
#'
#' # Significance letters for the differences between the groups
#' eda_plot(
#'   sm_synthetic,
#'   vars = items,
#'   group = "cluster_benchmark",
#'   show_sig = TRUE,
#'   reference = "groups"
#' )
#'
#' # Boxplots and distributions
#' eda_plot(sm_synthetic, vars = items, type = "box", orientation = "vertical")
#' eda_plot(sm_synthetic, vars = c("gender", "education"), type = "stacked")
eda_plot <- function(
  data,
  vars,
  group = NULL,
  weight = NULL,
  type = c("auto", "bar", "box", "stacked"),
  orientation = c("horizontal", "vertical"),
  error = c("ci", "se", "sd", "none"),
  conf_level = 0.95,
  total = FALSE,
  facet = FALSE,
  show_values = TRUE,
  show_sig = FALSE,
  reference = c("total", "rest", "meandev", "groups"),
  test_method = c("parametric", "nonparametric"),
  alpha = 0.05,
  axis_labels = c("label", "name", "both"),
  label_width = NULL,
  digits = 1,
  min_labels = 5,
  title = NULL
) {
  type <- rlang::arg_match(type)
  orientation <- rlang::arg_match(orientation)
  error <- rlang::arg_match(error)
  axis_labels <- rlang::arg_match(axis_labels)
  reference <- rlang::arg_match(reference)
  test_method <- rlang::arg_match(test_method)
  data <- eda_resolve_data(data)
  vars <- eda_select(data, {{ vars }})

  if (type == "auto") {
    types <- purrr::map_chr(data[vars], \(x) eda_var_type(x, min_labels))
    type <- if (all(types == "numeric")) "bar" else "stacked"
    if (type == "stacked" && any(types == "numeric")) {
      cli::cli_inform(c(
        "i" = "Some variables are categorical, so all are shown as distributions.",
        " " = "Use {.code type = \"bar\"} to plot the means of all variables."
      ))
    }
  }
  treat_as <- if (type == "stacked") "categorical" else "numeric"
  prep <- eda_prepare(data, vars, group, weight, treat_as, min_labels)
  label_width <- label_width %||% if (orientation == "horizontal") 40 else 15
  prep$x_labels <- eda_axis_labels(vars, prep$labels, axis_labels, label_width)

  sig <- if (show_sig && type != "stacked") {
    if (prep$has_group) {
      list(reference = reference, method = test_method, alpha = alpha, conf_level = conf_level)
    } else {
      cli::cli_inform(c("i" = "{.arg show_sig} requires a grouping variable."))
      NULL
    }
  }

  p <- switch(
    type,
    bar = eda_plot_bar(prep, vars, error, conf_level, total, facet, show_values, sig, digits, orientation),
    box = eda_plot_box(prep, vars, total, facet, sig, orientation),
    stacked = eda_plot_stacked(prep, vars, total, show_values, orientation)
  )

  if (orientation == "horizontal" && type != "stacked") {
    p <- p + ggplot2::coord_flip()
  }
  caption <- if (!is.null(weight)) glue::glue("Weighted by {weight}.")
  p +
    ggplot2::labs(title = title, caption = caption) +
    ggplot2::theme_classic(base_size = 11) +
    ggplot2::theme(
      legend.position = "bottom",
      plot.caption = ggplot2::element_text(hjust = 0, colour = "grey30"),
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold", hjust = 0)
    )
}


# ---- Exported: interactive gadget --------------------------------------------

#' Explore data interactively
#'
#' @description
#' Opens a Shiny gadget (in the viewer pane by default) to explore the
#' variables of a data set: select variables by name or label (or by a
#' pattern, e.g. a whole item battery), choose a grouping variable (e.g. a
#' cluster solution) and an optional weight, and get
#' * plots of all selected variables in one plot ([eda_plot()]): horizontal
#'   or vertical bar charts of the means with or without error bars,
#'   boxplots, or stacked bar charts of the distributions;
#' * descriptive statistics ([eda_describe()]);
#' * tests of group differences ([eda_test()], see "Statistical tests"
#'   there), comparing each group with the total (default), the rest of the
#'   sample, the mean of the group means, or all other groups;
#' * if `ggstatsplot` is installed, a detailed plot of a single variable with
#'   the test results ([eda_plot_detail()]; "Detailed plot" tab, customizable
#'   in the sidebar);
#' * a codebook with the variable and value labels;
#' * the code to reproduce the plot and the statistics in a script.
#'
#' The plots can be downloaded as JPEG ([ya_save_plot()], 300 dpi) and the
#' statistics as Excel file. Click "Done" to close the gadget and return them
#' to the console.
#'
#' @details
#' The gadget lists all data frames and [seg_cluster()] outputs in the global
#' environment. For a `seg_cluster` or `seg_cluster_set`, the original data
#' of the clustered respondents is shown and each cluster solution is
#' available as grouping variable (e.g. `cluster_k4`), see
#' [eda_describe()].
#'
#' Requires the packages `shiny`, `bslib` and `DT`; `ggstatsplot` is
#' optional.
#'
#' @param data Optional. A data frame or the output of [seg_cluster()] to
#'   show first. If `NULL` (default), the first data frame in the global
#'   environment is shown; all others can be selected in the gadget.
#' @param viewer Where to show the gadget: `"pane"` (RStudio/Positron viewer
#'   pane, default), `"browser"` or `"dialog"`.
#'
#' @returns Invisibly, when closed with "Done": a list with `plot` (ggplot),
#'   `describe` ([eda_describe()] output) and `code` (character, the code to
#'   reproduce them). `NULL` if no variables were selected.
#'
#' @family eda
#'
#' @export
#' @examplesIf interactive()
#' eda_explore(sm_synthetic)
#'
#' # With a cluster solution as grouping variable
#' prep <- seg_prep_data(sim_segments, vars = dplyr::starts_with("item_"), verbose = FALSE)
#' km <- seg_cluster(prep, k = 2:4, plots = FALSE, verbose = FALSE)
#' eda_explore(km)
eda_explore <- function(data = NULL, viewer = c("pane", "browser", "dialog")) {
  rlang::check_installed(c("shiny", "bslib", "DT"), reason = "to use `eda_explore()`.")
  viewer <- rlang::arg_match(viewer)

  objects <- eda_session_objects(globalenv())
  first <- NULL
  if (!is.null(data)) {
    first <- paste(deparse(substitute(data)), collapse = "")
    eda_resolve_data(data) # validate early
    objects[[first]] <- data
  }
  if (length(objects) == 0) {
    cli::cli_abort(c(
      "No data found.",
      "i" = "Supply {.arg data} or create a data frame in the global environment."
    ))
  }
  first <- first %||% names(objects)[1]

  app <- eda_explore_app(objects, first)
  viewer_fun <- switch(
    viewer,
    pane = shiny::paneViewer(minHeight = "maximize"),
    browser = shiny::browserViewer(),
    dialog = shiny::dialogViewer("Explore data", width = 1400, height = 900)
  )
  invisible(shiny::runGadget(app$ui, app$server, viewer = viewer_fun))
}


# ---- Internal: data preparation ----------------------------------------------

# Data frame from a data frame or a seg_cluster(_set), with cluster variables
eda_resolve_data <- function(data, call = rlang::caller_env()) {
  if (inherits(data, "seg_cluster_set")) {
    solutions <- data$solutions
    out <- tibble::as_tibble(solutions[[1]]$data_full)
    for (solution in solutions) {
      out <- eda_add_cluster(out, solution, call)
    }
    return(out)
  }
  if (inherits(data, "seg_cluster")) {
    return(eda_add_cluster(tibble::as_tibble(data$data_full), data, call))
  }
  if (!is.data.frame(data)) {
    cli::cli_abort(
      "{.arg data} must be a data frame or the output of {.fn seg_cluster}, not {.obj_type_friendly {data}}.",
      call = call
    )
  }
  data
}

# Add the cluster assignment of a solution as labelled variable
eda_add_cluster <- function(data, solution, call = rlang::caller_env()) {
  cluster <- as.integer(solution$cluster)
  if (is.null(data) || length(cluster) != nrow(data)) {
    cli::cli_abort(
      "The cluster solution does not contain the original data ({.field data_full}) of all clustered respondents.",
      call = call
    )
  }
  name <- if (is.na(solution$k)) {
    paste0("cluster_", solution$method)
  } else {
    paste0("cluster_k", solution$k)
  }
  name <- utils::tail(make.unique(c(names(data), name)), 1)

  codes <- sort(unique(cluster))
  labels <- ifelse(codes == 0, "Noise", paste("Cluster", codes))
  if (!is.null(solution$cluster_labels)) {
    custom <- unname(solution$cluster_labels[as.character(codes)])
    labels <- ifelse(is.na(custom), labels, custom)
  }
  k_text <- if (is.na(solution$k)) "" else glue::glue(", k = {solution$k}")

  data[[name]] <- cluster |>
    sjlabelled::set_labels(labels = stats::setNames(codes, labels)) |>
    sjlabelled::as_labelled() |>
    sjlabelled::set_label(label = glue::glue("Cluster solution ({solution$method}{k_text})"))
  data
}

# Resolve a tidyselect expression or a character vector to variable names
eda_select <- function(data, vars, call = rlang::caller_env()) {
  quo <- rlang::enquo(vars)
  if (rlang::quo_is_missing(quo) || rlang::quo_is_null(quo)) {
    cli::cli_abort("Please select at least one variable in {.arg vars}.", call = call)
  }
  # A character vector (e.g. `vars = items`) is selected with all_of() to
  # avoid tidyselect's deprecation warning for external vectors. Only plain
  # symbols are evaluated: evaluating calls such as all_of() outside of a
  # selection context triggers a deprecation warning of tidyselect.
  value <- if (rlang::quo_is_symbol(quo)) {
    tryCatch(rlang::eval_tidy(quo), error = function(e) NULL)
  }
  out <- if (is.character(value)) {
    names(dplyr::select(data, dplyr::all_of(value)))
  } else {
    names(dplyr::select(data, !!quo))
  }
  if (length(out) == 0) {
    cli::cli_abort("{.arg vars} does not select any variable.", call = call)
  }
  out
}

# Check the inputs and extract everything the statistics and plots need
eda_prepare <- function(
  data,
  vars,
  group,
  weight,
  treat_as,
  min_labels,
  call = rlang::caller_env()
) {
  for (arg in c("group", "weight")) {
    value <- get(arg)
    if (!is.null(value) && (!rlang::is_string(value) || !value %in% names(data))) {
      cli::cli_abort("{.arg {arg}} must be the name of a column of {.arg data}.", call = call)
    }
  }
  if (!is.null(group) && group %in% vars) {
    cli::cli_abort("The grouping variable {.val {group}} cannot also be in {.arg vars}.", call = call)
  }

  types <- if (treat_as == "auto") {
    purrr::map_chr(data[vars], \(x) eda_var_type(x, min_labels))
  } else {
    stats::setNames(rep(treat_as, length(vars)), vars)
  }

  w <- rep(1, nrow(data))
  if (!is.null(weight)) {
    w <- as.numeric(haven::zap_labels(haven::zap_missing(data[[weight]])))
    if (any(w < 0, na.rm = TRUE)) {
      cli::cli_abort("The weights in {.val {weight}} must not be negative.", call = call)
    }
  }

  g <- if (is.null(group)) {
    factor(rep("Total", nrow(data)))
  } else {
    eda_factor_values(data[[group]])
  }

  list(
    data = data,
    vars = vars,
    types = types,
    labels = eda_var_labels(data, vars),
    group = g,
    group_name = group,
    group_label = if (!is.null(group)) eda_var_labels(data, group),
    has_group = !is.null(group),
    w = w,
    weight = weight
  )
}

# Variable labels, falling back to the variable names
eda_var_labels <- function(data, vars) {
  purrr::map_chr(vars, \(v) {
    label <- sjlabelled::get_label(data[[v]])
    if (is.null(label) || is.na(label) || !nzchar(label)) v else as.character(label)
  }) |>
    stats::setNames(vars)
}

# Unique, wrapped axis labels of the variables
eda_axis_labels <- function(vars, labels, axis_labels = "label", width = 40) {
  out <- switch(
    axis_labels,
    label = unname(labels),
    name = vars,
    both = ifelse(labels == vars, vars, paste0(vars, ": ", labels))
  )
  dup <- duplicated(out) | duplicated(out, fromLast = TRUE)
  out[dup] <- paste0(out[dup], " (", vars[dup], ")")
  stats::setNames(stringr::str_wrap(out, width = width), vars)
}

# Codes of the value labels that are not user-defined missing values
eda_valid_label_codes <- function(x) {
  codes <- sjlabelled::get_values(x)
  if (is.null(codes)) {
    return(numeric(0))
  }
  keep <- !is.na(codes) & !codes %in% attr(x, "na_values")
  na_range <- attr(x, "na_range")
  if (!is.null(na_range)) {
    keep <- keep & !(codes >= na_range[1] & codes <= na_range[2])
  }
  codes[keep]
}

# "numeric" or "categorical" (see eda_describe(), "Numeric or categorical?")
eda_var_type <- function(x, min_labels = 5) {
  if (is.factor(x) || is.character(x) || is.logical(x) || !is.numeric(unclass(x))) {
    return("categorical")
  }
  codes <- eda_valid_label_codes(x)
  if (length(codes) == 0) {
    return("numeric")
  }
  n_values <- length(unique(stats::na.omit(as.numeric(haven::zap_missing(x)))))
  if (length(codes) >= min_labels || n_values >= min_labels) "numeric" else "categorical"
}

# Numeric values with user-defined missing values set to NA
eda_numeric_values <- function(x, name = "variable", call = rlang::caller_env()) {
  x <- haven::zap_missing(x)
  if (is.factor(x)) {
    return(as.numeric(x))
  }
  if (!is.numeric(unclass(x))) {
    cli::cli_abort("{.val {name}} is not numeric and cannot be summarized by its mean.", call = call)
  }
  as.numeric(haven::zap_labels(x))
}

# Factor using the value labels, with user-defined missing values set to NA
eda_factor_values <- function(x) {
  x <- haven::zap_missing(x)
  out <- if (is.factor(x)) {
    x
  } else if (!is.null(sjlabelled::get_labels(x))) {
    sjlabelled::as_label(x, add.non.labelled = TRUE, drop.levels = TRUE, drop.na = TRUE)
  } else {
    factor(x)
  }
  out <- droplevels(factor(out))
  attr(out, "label") <- NULL
  if ("Noise" %in% levels(out)) {
    out <- forcats::fct_relevel(out, "Noise", after = Inf)
  }
  out
}


# ---- Internal: statistics ----------------------------------------------------

# Long data of numeric variables: variable, group, value, w
eda_long_numeric <- function(prep, vars, total = FALSE) {
  long <- purrr::map(vars, \(v) {
    tibble::tibble(
      variable = v,
      group = prep$group,
      value = eda_numeric_values(prep$data[[v]], v),
      w = prep$w
    )
  }) |>
    purrr::list_rbind() |>
    dplyr::filter(!is.na(.data$group), !is.na(.data$w))
  eda_add_total(long, prep, total)
}

# Duplicate all rows as group "Total"
eda_add_total <- function(long, prep, total) {
  if (!total || !prep$has_group) {
    return(long)
  }
  levels_out <- c(levels(long$group), "Total")
  dplyr::bind_rows(
    dplyr::mutate(long, group = factor(.data$group, levels = levels_out)),
    dplyr::mutate(long, group = factor("Total", levels = levels_out))
  )
}

eda_stats_numeric <- function(long, conf_level = 0.95) {
  long |>
    dplyr::summarise(
      eda_wstats(.data$value, .data$w, conf_level),
      .by = c("variable", "group")
    ) |>
    dplyr::arrange(match(.data$variable, unique(long$variable)), .data$group)
}

# Weighted descriptive statistics of one vector
eda_wstats <- function(x, w, conf_level = 0.95) {
  missing <- sum(is.na(x))
  ok <- !is.na(x) & w > 0
  x <- x[ok]
  w <- w[ok]
  n <- length(x)
  if (n == 0) {
    return(tibble::tibble(
      n = 0L, n_eff = NA_real_, missing = missing, mean = NA_real_,
      sd = NA_real_, se = NA_real_, ci_low = NA_real_, ci_high = NA_real_,
      median = NA_real_, q1 = NA_real_, q3 = NA_real_, min = NA_real_,
      max = NA_real_
    ))
  }
  sum_w <- sum(w)
  mean <- sum(w * x) / sum_w
  n_eff <- sum_w^2 / sum(w^2)
  sd <- if (n_eff > 1) {
    sqrt(sum(w * (x - mean)^2) / sum_w * n_eff / (n_eff - 1))
  } else {
    NA_real_
  }
  se <- sd / sqrt(n_eff)
  t_crit <- if (n_eff > 1) stats::qt(1 - (1 - conf_level) / 2, df = n_eff - 1) else NA_real_
  q <- eda_wquantile(x, w, c(0.25, 0.5, 0.75))
  tibble::tibble(
    n = n, n_eff = n_eff, missing = missing, mean = mean, sd = sd, se = se,
    ci_low = mean - t_crit * se, ci_high = mean + t_crit * se,
    median = q[2], q1 = q[1], q3 = q[3], min = min(x), max = max(x)
  )
}

# Weighted quantiles (stats::quantile() if all weights are equal)
eda_wquantile <- function(x, w, probs) {
  if (all(w == w[1])) {
    return(unname(stats::quantile(x, probs, names = FALSE)))
  }
  o <- order(x)
  x <- x[o]
  cum_w <- cumsum(w[o]) / sum(w)
  purrr::map_dbl(probs, \(p) x[which(cum_w >= p - 1e-12)[1]])
}

# Weighted frequency distributions of categorical variables
eda_stats_categorical <- function(prep, vars, total = FALSE) {
  long <- purrr::map(vars, \(v) {
    tibble::tibble(
      variable = v,
      group = prep$group,
      value = eda_factor_values(prep$data[[v]]),
      w = prep$w
    )
  }) |>
    purrr::list_rbind() |>
    dplyr::filter(!is.na(.data$group), !is.na(.data$w), !is.na(.data$value))
  long <- eda_add_total(long, prep, total)

  long |>
    dplyr::summarise(
      n = dplyr::n(),
      n_weighted = sum(.data$w),
      .by = c("variable", "group", "value")
    ) |>
    dplyr::mutate(
      percent = 100 * .data$n_weighted / sum(.data$n_weighted),
      .by = c("variable", "group")
    ) |>
    dplyr::arrange(
      match(.data$variable, vars),
      .data$group,
      .data$value
    )
}

# Add labels, drop columns that do not apply
eda_finish_table <- function(tbl, prep, weighted) {
  tbl <- tbl |>
    dplyr::mutate(
      label = unname(prep$labels[.data$variable]),
      .after = "variable"
    )
  if (!prep$has_group) {
    tbl$group <- NULL
  }
  if (!weighted) {
    tbl$n_eff <- NULL
    tbl$n_weighted <- NULL
  }
  tbl
}

# Shorter labels for printing in the console
eda_print_table <- function(tbl, digits = 2) {
  if ("label" %in% names(tbl)) {
    tbl$label <- stringr::str_trunc(tbl$label, 30)
  }
  print(eda_round(tbl, digits), n = Inf)
}

eda_round <- function(tbl, digits = 2) {
  dplyr::mutate(tbl, dplyr::across(dplyr::where(is.double), \(x) round(x, digits)))
}

eda_format_p <- function(p) {
  ifelse(is.na(p), NA_character_, ifelse(p < 0.001, "< .001", sub("^0", "", sprintf("%.3f", p))))
}


# ---- Internal: tests ---------------------------------------------------------

# omnibus = FALSE skips the omnibus tests and effect sizes (e.g. for the
# significance markers of the plots, which only need the comparisons)
eda_test_prepared <- function(prep, vars, method, reference = "total", p_adjust = "holm",
                              conf_level = 0.95, omnibus = TRUE) {
  rows <- purrr::map(vars, \(v) {
    if (prep$types[[v]] == "numeric") {
      eda_test_numeric(prep, v, method, reference, p_adjust, conf_level, omnibus)
    } else if (omnibus) {
      eda_test_categorical(prep, v, conf_level)
    }
  })
  omnibus <- purrr::map(rows, "omnibus") |> purrr::list_rbind()
  pairwise <- purrr::map(rows, "pairwise") |> purrr::list_rbind()
  if (nrow(pairwise) == 0) {
    pairwise <- tibble::tibble(
      variable = character(), group1 = character(), group2 = character(),
      estimate1 = numeric(), estimate2 = numeric(), difference = numeric(),
      direction = character(), se = numeric(), ci_low = numeric(),
      ci_high = numeric(), t = numeric(), df = numeric(), p = numeric(),
      p_adj = numeric()
    )
  }
  if ("variable" %in% names(omnibus)) {
    omnibus <- omnibus |>
      dplyr::mutate(label = unname(prep$labels[.data$variable]), .after = "variable")
  }

  structure(
    list(
      omnibus = omnibus,
      pairwise = pairwise,
      settings = list(
        group = prep$group_name,
        weight = prep$weight,
        method = method,
        reference = reference,
        p_adjust = p_adjust
      )
    ),
    class = c("eda_test", "list")
  )
}

eda_omnibus_row <- function(variable, type, test, statistic = NA_real_, df1 = NA_real_,
                            df2 = NA_real_, p = NA_real_, effect = NA_character_,
                            effect_size = NA_real_, effect_ci_low = NA_real_,
                            effect_ci_high = NA_real_, n = NA_integer_) {
  tibble::tibble(
    variable = variable, type = type, test = test, statistic = statistic,
    df1 = df1, df2 = df2, p = p, effect = effect, effect_size = effect_size,
    effect_ci_low = effect_ci_low, effect_ci_high = effect_ci_high,
    n = as.integer(n)
  )
}

eda_test_numeric <- function(prep, v, method, reference, p_adjust, conf_level,
                             omnibus = TRUE) {
  d <- eda_long_numeric(prep, v) |>
    dplyr::filter(!is.na(.data$value), .data$w > 0) |>
    dplyr::mutate(group = droplevels(.data$group))
  n <- nrow(d)
  if (nlevels(d$group) < 2) {
    return(list(omnibus = eda_omnibus_row(v, "numeric", "Fewer than 2 groups", n = n)))
  }

  if (!omnibus) {
    omnibus <- NULL
  } else if (method == "parametric") {
    # One-way ANOVA (weighted least squares if weighted), eta squared
    fit <- stats::lm(value ~ group, data = d, weights = d$w)
    a <- stats::anova(fit)
    es <- effectsize::eta_squared(fit, partial = FALSE, ci = conf_level, verbose = FALSE)
    omnibus <- eda_omnibus_row(
      v, "numeric",
      test = if (is.null(prep$weight)) "ANOVA" else "Weighted ANOVA",
      statistic = a$`F value`[1], df1 = a$Df[1], df2 = a$Df[2],
      p = a$`Pr(>F)`[1], effect = "Eta2",
      effect_size = es$Eta2[1], effect_ci_low = es$CI_low[1], effect_ci_high = es$CI_high[1],
      n = n
    )
  } else {
    # Kruskal-Wallis test, rank epsilon squared (weights are ignored)
    kw <- stats::kruskal.test(value ~ group, data = d)
    es <- effectsize::rank_epsilon_squared(value ~ group, data = d, ci = conf_level, verbose = FALSE)
    omnibus <- eda_omnibus_row(
      v, "numeric", test = "Kruskal-Wallis",
      statistic = unname(kw$statistic), df1 = unname(kw$parameter),
      p = kw$p.value, effect = "Epsilon2 (rank)",
      effect_size = es$rank_epsilon_squared[1],
      effect_ci_low = es$CI_low[1], effect_ci_high = es$CI_high[1], n = n
    )
  }

  pairwise <- eda_contrasts(d, method, reference, conf_level)
  pairwise <- tibble::add_column(pairwise, variable = v, .before = 1)
  pairwise$direction <- vapply(pairwise$contrast, eda_direction, character(1))
  pairwise$contrast <- NULL
  pairwise <- dplyr::relocate(pairwise, "direction", .after = "difference")
  pairwise$p_adj <- stats::p.adjust(pairwise$p, method = p_adjust)
  list(omnibus = omnibus, pairwise = pairwise)
}

# Contrasts of the group means with modelbased::estimate_contrasts() (see
# eda_test(), "Comparisons"): a linear model of the variable (or of its ranks
# if nonparametric) on the groups, with heteroscedasticity-consistent (HC3)
# standard errors. Returns group1, group2, estimate1, estimate2, difference,
# se, ci_low, ci_high, t, df, p and the contrast on the model scale.
eda_contrasts <- function(d, method, reference, conf_level = 0.95) {
  groups <- levels(d$group)
  k <- length(groups)
  rank_based <- method == "nonparametric"

  # Neutral level names: modelbased splits labels at "-", and "group" is a
  # reserved name in marginaleffects
  ids <- paste0("g", seq_len(k))
  fit_data <- data.frame(
    y = if (rank_based) rank(d$value) else d$value,
    seg = factor(as.integer(d$group), levels = seq_len(k), labels = ids),
    wt = if (rank_based) 1 else d$w
  )
  fit <- stats::lm(y ~ seg, data = fit_data, weights = fit_data$wt)

  # Shares of the groups in the (weighted) total
  shares <- as.numeric(tapply(fit_data$wt, fit_data$seg, sum))
  shares <- shares / sum(shares)

  # Contrast matrices: one column per comparison
  comparison <- switch(
    reference,
    groups = "pairwise",
    meandev = "meandev",
    total = diag(k) - matrix(shares, k, k),
    rest = vapply(seq_len(k), \(g) {
      out <- -shares / (1 - shares[g])
      out[g] <- 1
      out
    }, numeric(k))
  )
  if (is.matrix(comparison)) {
    colnames(comparison) <- ids
  }

  res <- suppressMessages(modelbased::estimate_contrasts(
    fit,
    contrast = "seg",
    comparison = comparison,
    p_adjust = "none",
    vcov = "HC3",
    ci = conf_level
  )) |>
    as.data.frame()

  first <- if ("Parameter" %in% names(res)) res$Parameter else res$Level1
  out <- tibble::tibble(
    id1 = as.character(first),
    id2 = if ("Level2" %in% names(res)) as.character(res$Level2) else NA_character_,
    contrast = res$Difference,
    se = res$SE,
    ci_low = res$CI_low,
    ci_high = res$CI_high,
    t = res$t,
    df = res$df,
    p = res$p
  )
  if (reference == "groups") {
    # modelbased returns "later - earlier" level; flip to "earlier - later"
    out <- dplyr::mutate(
      out,
      id_tmp = .data$id1, id1 = .data$id2, id2 = .data$id_tmp,
      contrast = -.data$contrast, t = -.data$t,
      ci_tmp = .data$ci_low, ci_low = -.data$ci_high, ci_high = -.data$ci_tmp
    ) |>
      dplyr::select(-"id_tmp", -"ci_tmp")
  }

  # Estimates on the original scale: (weighted) means or medians
  idx1 <- match(out$id1, ids)
  idx2 <- match(out$id2, ids)
  if (rank_based) {
    group_est <- as.numeric(tapply(d$value, d$group, stats::median))
    rest_est <- vapply(seq_len(k), \(g) stats::median(d$value[as.integer(d$group) != g]), numeric(1))
    total_est <- stats::median(d$value)
    meandev_est <- NA_real_
  } else {
    group_est <- as.numeric(tapply(d$w * d$value, d$group, sum) / tapply(d$w, d$group, sum))
    rest_est <- vapply(seq_len(k), \(g) {
      other <- as.integer(d$group) != g
      sum(d$w[other] * d$value[other]) / sum(d$w[other])
    }, numeric(1))
    total_est <- sum(d$w * d$value) / sum(d$w)
    meandev_est <- mean(group_est)
  }

  out$group1 <- groups[idx1]
  out$estimate1 <- group_est[idx1]
  if (reference == "groups") {
    out$group2 <- groups[idx2]
    out$estimate2 <- group_est[idx2]
  } else {
    out$group2 <- switch(reference, total = "Total", rest = "Rest", meandev = "Mean of groups")
    out$estimate2 <- switch(reference, total = total_est, rest = rest_est[idx1], meandev = meandev_est)
  }
  out$difference <- out$estimate1 - out$estimate2
  if (rank_based) {
    # se and CI refer to the ranks, not to the original scale
    out$se <- NA_real_
    out$ci_low <- NA_real_
    out$ci_high <- NA_real_
  } else {
    # The contrast equals the difference of the means; use the model value
    out$difference <- out$contrast
  }

  dplyr::select(
    out, "group1", "group2", "estimate1", "estimate2", "difference",
    "se", "ci_low", "ci_high", "t", "df", "p", "contrast"
  )
}

eda_comparison_title <- function(reference) {
  switch(
    reference,
    total = "Comparisons with the total",
    rest = "Comparisons with the rest of the sample",
    meandev = "Comparisons with the mean of the group means",
    groups = "Pairwise comparisons"
  )
}

eda_direction <- function(difference) {
  if (is.na(difference)) {
    NA_character_
  } else if (difference > 0) {
    "higher"
  } else if (difference < 0) {
    "lower"
  } else {
    "equal"
  }
}

eda_test_categorical <- function(prep, v, conf_level = 0.95) {
  d <- tibble::tibble(
    value = eda_factor_values(prep$data[[v]]),
    group = prep$group,
    w = prep$w
  ) |>
    dplyr::filter(!is.na(.data$value), !is.na(.data$group), !is.na(.data$w))
  n <- nrow(d)
  tab <- stats::xtabs(w ~ value + group, data = d, drop.unused.levels = TRUE)
  if (any(dim(tab) < 2)) {
    return(list(omnibus = eda_omnibus_row(v, "categorical", "Fewer than 2 groups or categories", n = n)))
  }
  # Weighted table rescaled to the unweighted sample size
  tab <- tab * n / sum(tab)
  chi <- suppressWarnings(stats::chisq.test(tab, correct = FALSE))
  es <- suppressWarnings(effectsize::cramers_v(tab, adjust = FALSE, ci = conf_level))
  list(omnibus = eda_omnibus_row(
    v, "categorical",
    test = if (is.null(prep$weight)) "Chi-square" else "Chi-square (weighted)",
    statistic = unname(chi$statistic), df1 = unname(chi$parameter),
    p = chi$p.value, effect = "Cramer's V",
    effect_size = es$Cramers_v[1], effect_ci_low = es$CI_low[1], effect_ci_high = es$CI_high[1],
    n = n
  ))
}

# Markers of significant differences per variable and group: triangles
# (higher/lower than the total) or the letters of the groups that a group
# significantly exceeds
eda_sig_marks <- function(prep, vars, groups, sig) {
  pairwise <- eda_test_prepared(
    prep, vars, sig$method, sig$reference, "holm", sig$conf_level,
    omnibus = FALSE
  )$pairwise
  hit <- pairwise[
    !is.na(pairwise$p_adj) & pairwise$p_adj < sig$alpha &
      pairwise$direction %in% c("higher", "lower"),
  ]
  test_name <- if (sig$method == "parametric") {
    "contrasts of the means, robust SE"
  } else {
    "contrasts of the mean ranks, robust SE"
  }

  if (sig$reference != "groups") {
    marks <- tibble::tibble(
      variable = hit$variable,
      group = hit$group1,
      sig = hit$direction
    )
    reference_text <- switch(
      sig$reference,
      total = "the total",
      rest = "the rest of the sample",
      meandev = "the mean of the group means"
    )
    note <- glue::glue(
      "Green / red triangles: significantly higher / lower than {reference_text} ({test_name}, Holm-adjusted, p < {sig$alpha})."
    )
    letters_map <- NULL
  } else {
    real_groups <- setdiff(groups, "Total")
    letters_map <- stats::setNames(LETTERS[seq_along(real_groups)], real_groups)
    marks <- dplyr::bind_rows(
      tibble::tibble(variable = hit$variable, group = hit$group1, lower = hit$group2, keep = hit$direction == "higher"),
      tibble::tibble(variable = hit$variable, group = hit$group2, lower = hit$group1, keep = hit$direction == "lower")
    ) |>
      dplyr::filter(.data$keep) |>
      dplyr::mutate(letter = unname(letters_map[.data$lower])) |>
      dplyr::summarise(
        sig = paste(sort(.data$letter), collapse = ""),
        .by = c("variable", "group")
      )
    note <- glue::glue(
      "Letters: significantly higher than the group with this letter ({test_name}, Holm-adjusted, p < {sig$alpha})."
    )
  }
  list(
    marks = marks,
    note = stringr::str_wrap(note, 90),
    letters = letters_map,
    reference = sig$reference
  )
}

# Add the markers to a table with one row per variable and group
eda_join_marks <- function(tbl, marks) {
  tbl |>
    dplyr::mutate(group_chr = as.character(.data$group)) |>
    dplyr::left_join(marks, by = c("variable", group_chr = "group")) |>
    dplyr::select(-"group_chr")
}

# Legend labels with the letters of the groups
eda_legend_labels <- function(groups, letters_map) {
  out <- stats::setNames(groups, groups)
  if (!is.null(letters_map)) {
    out[names(letters_map)] <- paste0(names(letters_map), " (", letters_map, ")")
  }
  out
}

# Layers with the markers next to the bars or boxes (y: column with their
# end). Triangles are drawn as point shapes (not as text glyphs, which
# devices such as pdf() cannot render).
eda_sig_layer <- function(marks, tbl, y, pos, horizontal) {
  if (marks$reference == "groups") {
    return(ggplot2::geom_text(
      ggplot2::aes(y = .data[[y]], label = .data$sig),
      position = pos, size = 3, colour = "grey15", na.rm = TRUE,
      hjust = if (horizontal) -0.3 else 0.5,
      vjust = if (horizontal) 0.5 else -0.5
    ))
  }
  # One layer with all rows, so that the markers are dodged like the bars;
  # rows without a significant difference get shape NA (not drawn). Higher:
  # green, lower: red (fill = colour via after_scale(), as the fill scale is
  # used by the groups)
  offset <- 0.03 * max(abs(tbl[[y]]), na.rm = TRUE)
  higher <- unname(yougov_colors[["Green 2"]])
  lower <- unname(yougov_colors[["Red 2"]])
  list(
    ggplot2::geom_point(
      ggplot2::aes(
        y = .data[[y]] + offset,
        shape = dplyr::case_match(.data$sig, "higher" ~ 24, "lower" ~ 25, .default = NA),
        colour = dplyr::case_match(.data$sig, "higher" ~ !!higher, "lower" ~ !!lower, .default = NA_character_),
        fill = ggplot2::after_scale(.data$colour)
      ),
      position = pos, size = 2.2, na.rm = TRUE, show.legend = FALSE
    ),
    ggplot2::scale_shape_identity(),
    ggplot2::scale_colour_identity()
  )
}


# ---- Internal: plots ---------------------------------------------------------

eda_group_colors <- function(groups) {
  colors <- rep_len(yougov_palette, length(groups))
  colors[groups == "Total"] <- "grey60"
  stats::setNames(colors, groups)
}

# Order variables and groups so that the first one is on top in horizontal
# plots (coord_flip() puts the first level at the bottom)
eda_plot_levels <- function(tbl, prep, vars, horizontal) {
  # unname(): names would end up in the facet values, which shiny passes to
  # jsonlite ("Input to asJSON(keep_vec_names=TRUE) is a named vector")
  x_levels <- unname(prep$x_labels[vars])
  tbl$x <- factor(unname(prep$x_labels[tbl$variable]), levels = if (horizontal) rev(x_levels) else x_levels)
  if (horizontal) {
    tbl$group <- forcats::fct_rev(tbl$group)
  }
  tbl
}

eda_plot_bar <- function(prep, vars, error, conf_level, total, facet, show_values,
                         sig, digits, orientation) {
  horizontal <- orientation == "horizontal"
  long <- eda_long_numeric(prep, vars, total)
  stats_tbl <- eda_stats_numeric(long, conf_level)
  groups <- levels(stats_tbl$group)

  stats_tbl <- stats_tbl |>
    dplyr::mutate(
      lo = dplyr::case_when(
        error == "ci" ~ .data$ci_low,
        error == "se" ~ .data$mean - .data$se,
        error == "sd" ~ .data$mean - .data$sd,
        .default = .data$mean
      ),
      hi = dplyr::case_when(
        error == "ci" ~ .data$ci_high,
        error == "se" ~ .data$mean + .data$se,
        error == "sd" ~ .data$mean + .data$sd,
        .default = .data$mean
      ),
      value_label = formatC(.data$mean, format = "f", digits = digits)
    )

  marks <- if (!is.null(sig)) eda_sig_marks(prep, vars, groups, sig)
  if (!is.null(marks)) {
    stats_tbl <- eda_join_marks(stats_tbl, marks$marks)
  }

  stats_tbl <- eda_plot_levels(stats_tbl, prep, vars, horizontal)
  if (facet) {
    mapping <- ggplot2::aes(x = .data$group, y = .data$mean, fill = .data$group)
  } else {
    mapping <- ggplot2::aes(x = .data$x, y = .data$mean, fill = .data$group, group = .data$group)
  }
  pos <- ggplot2::position_dodge(width = 0.85)

  p <- ggplot2::ggplot(stats_tbl, mapping) +
    ggplot2::geom_col(position = pos, width = 0.8)
  if (error != "none") {
    p <- p + ggplot2::geom_errorbar(
      ggplot2::aes(ymin = .data$lo, ymax = .data$hi),
      position = pos, width = 0.25, colour = "grey25"
    )
  }
  if (show_values) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(y = 0, label = .data$value_label),
      position = pos, colour = "white", size = 3,
      hjust = if (horizontal) -0.2 else 0.5,
      vjust = if (horizontal) 0.5 else -0.6
    )
  }
  if (!is.null(marks)) {
    p <- p + eda_sig_layer(marks, stats_tbl, "hi", pos, horizontal)
  }

  error_text <- switch(
    error,
    ci = glue::glue("{conf_level * 100}% confidence interval"),
    se = "standard error",
    sd = "standard deviation",
    none = NULL
  )
  y_title <- if (is.null(error_text)) "Mean" else glue::glue("Mean (error bars: {error_text})")

  p <- p +
    ggplot2::scale_fill_manual(
      values = eda_group_colors(groups),
      breaks = groups,
      labels = eda_legend_labels(groups, marks$letters)[groups],
      name = prep$group_label
    ) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.12))) +
    ggplot2::labs(x = NULL, y = y_title, subtitle = marks$note)

  eda_finish_plot(p, prep, facet, horizontal)
}

eda_plot_box <- function(prep, vars, total, facet, sig, orientation) {
  horizontal <- orientation == "horizontal"
  long <- eda_long_numeric(prep, vars, total) |>
    dplyr::filter(!is.na(.data$value), .data$w > 0)
  groups <- levels(long$group)
  box <- long |>
    dplyr::summarise(
      eda_box_stats(.data$value, .data$w),
      .by = c("variable", "group")
    )
  marks <- if (!is.null(sig)) eda_sig_marks(prep, vars, groups, sig)
  if (!is.null(marks)) {
    box <- eda_join_marks(box, marks$marks)
  }
  box <- eda_plot_levels(box, prep, vars, horizontal)

  if (facet) {
    mapping <- ggplot2::aes(x = .data$group, fill = .data$group)
  } else {
    mapping <- ggplot2::aes(x = .data$x, fill = .data$group, group = interaction(.data$x, .data$group))
  }
  pos <- ggplot2::position_dodge(width = 0.85)
  p <- ggplot2::ggplot(box, mapping) +
    ggplot2::geom_boxplot(
      ggplot2::aes(
        ymin = .data$ymin, lower = .data$lower, middle = .data$middle,
        upper = .data$upper, ymax = .data$ymax
      ),
      stat = "identity", position = pos, width = 0.75
    ) +
    ggplot2::geom_point(
      ggplot2::aes(y = .data$mean),
      position = pos, shape = 23, size = 2, fill = "white"
    )
  if (!is.null(marks)) {
    p <- p + eda_sig_layer(marks, box, "ymax", pos, horizontal)
  }
  p <- p +
    ggplot2::scale_fill_manual(
      values = eda_group_colors(groups),
      breaks = groups,
      labels = eda_legend_labels(groups, marks$letters)[groups],
      name = prep$group_label
    ) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.05, 0.12))) +
    ggplot2::labs(
      x = NULL,
      y = "Value",
      subtitle = paste(
        c("Box: median and quartiles; whiskers: 1.5 x IQR; diamond: mean.", marks$note),
        collapse = "\n"
      )
    )
  eda_finish_plot(p, prep, facet, horizontal)
}

# Weighted boxplot statistics (Tukey whiskers, no outlier points)
eda_box_stats <- function(x, w) {
  q <- eda_wquantile(x, w, c(0.25, 0.5, 0.75))
  iqr <- q[3] - q[1]
  tibble::tibble(
    ymin = min(x[x >= q[1] - 1.5 * iqr]),
    lower = q[1],
    middle = q[2],
    upper = q[3],
    ymax = max(x[x <= q[3] + 1.5 * iqr]),
    mean = sum(w * x) / sum(w)
  )
}

eda_plot_stacked <- function(prep, vars, total, show_values, orientation) {
  freq <- eda_stats_categorical(prep, vars, total)
  categories <- levels(freq$value)
  horizontal <- orientation == "horizontal"

  freq$x_label <- factor(unname(prep$x_labels[freq$variable]), levels = unname(prep$x_labels[vars]))
  if (prep$has_group) {
    freq$x <- freq$group
  } else {
    freq$x <- freq$x_label
  }
  if (horizontal) {
    freq$x <- forcats::fct_rev(freq$x)
  }

  p <- ggplot2::ggplot(freq, ggplot2::aes(x = .data$x, y = .data$percent, fill = .data$value)) +
    ggplot2::geom_col(position = ggplot2::position_stack(reverse = TRUE), width = 0.75)
  if (show_values) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = ifelse(.data$percent >= 5, sprintf("%.0f%%", .data$percent), "")),
      position = ggplot2::position_stack(vjust = 0.5, reverse = TRUE),
      size = 3, colour = "white"
    )
  }
  p <- p +
    ggplot2::scale_fill_manual(values = eda_category_colors(categories), name = NULL) +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.02)),
      labels = \(x) paste0(x, "%")
    ) +
    ggplot2::labs(x = NULL, y = "Percent") +
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = if (length(categories) > 6) 2 else 1))

  if (prep$has_group) {
    p <- p + ggplot2::facet_wrap(
      ggplot2::vars(.data$x_label),
      ncol = if (horizontal) 1 else min(length(vars), 3)
    ) + ggplot2::labs(x = prep$group_label)
  }
  if (horizontal) {
    p <- p + ggplot2::coord_flip()
  }
  p
}

# Diverging colors for ordered categories, palette colors for few categories
eda_category_colors <- function(categories) {
  n <- length(categories)
  colors <- if (n <= 3) {
    yougov_palette[seq_len(n)]
  } else {
    grDevices::colorRampPalette(
      c(yougov_colors[["Red 1"]], "grey85", yougov_colors[["Blue 1"]])
    )(n)
  }
  stats::setNames(colors, categories)
}

eda_finish_plot <- function(p, prep, facet, horizontal) {
  if (facet) {
    facet_var <- if (horizontal) ggplot2::vars(forcats::fct_rev(.data$x)) else ggplot2::vars(.data$x)
    p <- p +
      ggplot2::facet_wrap(facet_var, scales = "free") +
      ggplot2::theme(legend.position = "none")
  }
  if (!prep$has_group) {
    p <- p + ggplot2::guides(fill = "none")
  } else if (!facet) {
    p <- p + ggplot2::guides(fill = ggplot2::guide_legend(ncol = 2, byrow = TRUE))
  }
  p
}

#' Exploratory data analysis: detailed plot of one variable by group
#'
#' @description
#' Plots the distribution of a single variable by group with the results of
#' statistical tests, using [ggstatsplot::ggbetweenstats()] (numeric
#' variables: violin plot, boxplot and individual data points) or
#' [ggstatsplot::ggbarstats()] (categorical variables: stacked bar chart),
#' in the YouAnalyser style (YouGov colors, `theme_classic()`). This is the
#' plot of the "Detailed plot" tab of [eda_explore()].
#'
#' Requires the `ggstatsplot` package.
#'
#' @details
#' Numeric and categorical variables are distinguished as in
#' [eda_describe()]. ggstatsplot does not support weights: the plot and all
#' tests are unweighted (a caption says so if `weight` is given).
#'
#' # Statistical tests
#'
#' The tests are computed by ggstatsplot (via `statsExpressions`) and differ
#' from those of [eda_test()]. The results of the omnibus test are shown in
#' the subtitle, the pairwise comparisons as brackets above the groups
#' (numeric variables) and the method in the caption.
#'
#' ## Numeric variables ([ggstatsplot::ggbetweenstats()])
#'
#' | `type` | Omnibus test (effect size) | Pairwise comparisons |
#' |---|---|---|
#' | `"parametric"` | Welch's one-way ANOVA, not assuming equal variances (partial omega squared) | Games-Howell test |
#' | `"nonparametric"` | Kruskal-Wallis rank sum test (rank epsilon squared) | Dunn's test |
#' | `"robust"` | Heteroscedastic one-way ANOVA of 20% trimmed means (explanatory measure of effect size) | Yuen's test of trimmed means |
#' | `"bayes"` | Bayesian one-way ANOVA: Bayes factor (posterior R squared) | Bayesian t-tests (Bayes factors) |
#'
#' The p-values of the pairwise comparisons are adjusted with `p_adjust`
#' (default Holm). With two groups, the omnibus test is a (Welch's,
#' Mann-Whitney, Yuen's or Bayesian) two-sample test.
#'
#' ## Categorical variables ([ggstatsplot::ggbarstats()])
#'
#' * Omnibus: Pearson's chi-square test of independence of the variable and
#'   the groups (Cramér's V; for `type = "bayes"`: Bayes factor of a Bayesian
#'   contingency table analysis).
#' * Above each bar: a chi-square goodness-of-fit test of whether the
#'   categories are equally frequent within this group (not a comparison
#'   between groups).
#'
#' @inheritParams eda_describe
#' @param var Name of the variable to plot.
#' @param group Name of the grouping variable (e.g. `"cluster_k4"`).
#' @param weight Optional. Name of a weight variable. Only noted in the
#'   caption, as ggstatsplot does not support weights.
#' @param type Type of the tests: `"parametric"` (default),
#'   `"nonparametric"`, `"robust"` or `"bayes"`. See "Statistical tests".
#' @param violin,points,boxplot Show the violin plot, the individual data
#'   points and the boxplot (numeric variables)? All default to `TRUE`.
#' @param centrality Show the mean (or median, if nonparametric) of each
#'   group with a label (numeric variables)? Defaults to `TRUE`.
#' @param pairwise_display Pairwise comparisons shown (numeric variables):
#'   `"significant"` (default), `"all"` or `"none"`.
#' @param p_adjust Method to adjust the p-values of the pairwise comparisons
#'   (see [stats::p.adjust()]). Defaults to `"holm"`.
#' @param results_subtitle Show the test results in the subtitle (and, for
#'   parametric tests, the Bayes factor in the caption)? Defaults to `TRUE`.
#' @param bar_label Labels of the bars (categorical variables):
#'   `"percentage"` (default), `"counts"` or `"both"`.
#'
#' @returns A ggplot object.
#'
#' @family eda
#'
#' @export
#' @examplesIf requireNamespace("ggstatsplot", quietly = TRUE)
#' # Numeric variable: violin plots, boxplots and Games-Howell tests
#' eda_plot_detail(sm_synthetic, var = "F50_0_1", group = "cluster_benchmark")
#'
#' # Only boxplots, nonparametric tests, all pairwise comparisons
#' eda_plot_detail(
#'   sm_synthetic,
#'   var = "F50_0_1",
#'   group = "cluster_benchmark",
#'   type = "nonparametric",
#'   violin = FALSE,
#'   points = FALSE,
#'   pairwise_display = "all"
#' )
#'
#' # Categorical variable
#' eda_plot_detail(sm_synthetic, var = "education", group = "cluster_benchmark")
eda_plot_detail <- function(
  data,
  var,
  group,
  weight = NULL,
  treat_as = c("auto", "numeric", "categorical"),
  min_labels = 5,
  type = c("parametric", "nonparametric", "robust", "bayes"),
  violin = TRUE,
  points = TRUE,
  boxplot = TRUE,
  centrality = TRUE,
  pairwise_display = c("significant", "all", "none"),
  p_adjust = "holm",
  results_subtitle = TRUE,
  bar_label = c("percentage", "counts", "both")
) {
  rlang::check_installed("ggstatsplot", reason = "for detailed plots with test results.")
  treat_as <- rlang::arg_match(treat_as)
  type <- rlang::arg_match(type)
  pairwise_display <- rlang::arg_match(pairwise_display)
  bar_label <- rlang::arg_match(bar_label)
  data <- eda_resolve_data(data)
  for (v in c(var, group)) {
    if (!rlang::is_string(v) || !v %in% names(data)) {
      cli::cli_abort("{.arg var} and {.arg group} must be names of columns of {.arg data}.")
    }
  }
  var_type <- if (treat_as == "auto") eda_var_type(data[[var]], min_labels) else treat_as
  labels <- eda_var_labels(data, c(var, group))
  d <- tibble::tibble(
    y = if (var_type == "numeric") eda_numeric_values(data[[var]], var) else eda_factor_values(data[[var]]),
    g = eda_factor_values(data[[group]])
  ) |>
    dplyr::filter(!is.na(.data$y), !is.na(.data$g)) |>
    dplyr::mutate(g = droplevels(.data$g))
  title <- stringr::str_wrap(labels[[var]], 80)
  caption <- if (!is.null(weight)) "Unweighted (ggstatsplot does not support weights)."
  theme <- ggplot2::theme_classic(base_size = 11)
  style <- ggplot2::theme(
    legend.position = "bottom",
    plot.caption = ggplot2::element_text(hjust = 0, colour = "grey30"),
    plot.title = ggplot2::element_text(size = 12)
  )
  # Invisible geoms (ggstatsplot has no switches to remove them)
  hidden <- list(alpha = 0, colour = NA, na.rm = TRUE)

  # suppressMessages(): "Scale for colour is already present"
  suppressMessages(if (var_type == "numeric") {
    ggstatsplot::ggbetweenstats(
      data = d, x = "g", y = "y", type = type,
      pairwise.display = pairwise_display, p.adjust.method = p_adjust,
      results.subtitle = results_subtitle, bf.message = results_subtitle,
      centrality.plotting = centrality,
      centrality.point.args = list(size = 4, colour = "grey15"),
      point.args = if (points) {
        list(
          position = ggplot2::position_jitterdodge(dodge.width = 0.6),
          alpha = 0.4, size = 2.5, stroke = 0, na.rm = TRUE
        )
      } else {
        c(list(position = ggplot2::position_jitterdodge(dodge.width = 0.6), size = 0), hidden)
      },
      boxplot.args = if (boxplot) {
        list(width = 0.3, alpha = 0.2, na.rm = TRUE)
      } else {
        c(list(width = 0.3), hidden)
      },
      violin.args = if (violin) list(width = 0.5, alpha = 0.2, na.rm = TRUE) else c(list(width = 0.5), hidden),
      xlab = labels[[group]], ylab = var, title = title, caption = caption,
      ggtheme = theme,
      ggplot.component = list(
        # unnamed: matched to the groups in the order of the levels
        ggplot2::scale_colour_manual(values = unname(eda_group_colors(levels(d$g)))),
        # unused colour label set by ggstatsplot ("Ignoring unknown labels")
        ggplot2::labs(colour = NULL),
        style,
        # the groups are already on the x axis
        ggplot2::theme(legend.position = "none")
      )
    )
  } else {
    ggstatsplot::ggbarstats(
      data = d, x = "y", y = "g", type = type,
      results.subtitle = results_subtitle, bf.message = results_subtitle,
      label = bar_label,
      p.adjust.method = p_adjust,
      xlab = labels[[group]], legend.title = var, title = title, caption = caption,
      ggtheme = theme,
      ggplot.component = list(
        ggplot2::scale_fill_manual(values = eda_category_colors(levels(d$y)), name = var),
        style
      )
    )
  })
}


# ---- Internal: gadget --------------------------------------------------------

# Data frames and seg_cluster outputs in an environment
eda_session_objects <- function(env) {
  names <- ls(envir = env)
  keep <- purrr::keep(names, \(n) {
    obj <- get(n, envir = env)
    is.data.frame(obj) || inherits(obj, c("seg_cluster", "seg_cluster_set"))
  })
  purrr::map(stats::setNames(keep, keep), \(n) get(n, envir = env))
}

# Choices "name: label" for a select input
eda_var_choices <- function(data, vars = names(data)) {
  if (length(vars) == 0) {
    return(character(0))
  }
  labels <- eda_var_labels(data, vars)
  display <- ifelse(labels == vars, vars, paste0(vars, ": ", stringr::str_trunc(unname(labels), 90)))
  stats::setNames(vars, display)
}

# The same as data frame for server-side selectize inputs: a named vector
# makes shiny pass named vectors to jsonlite::toJSON(), which warns
# ("Input to asJSON(keep_vec_names=TRUE) is a named vector")
eda_var_choices_df <- function(data, vars = names(data)) {
  choices <- eda_var_choices(data, vars)
  data.frame(label = names(choices), value = unname(choices), stringsAsFactors = FALSE)
}

# Possible grouping variables: cluster solutions first, then variables with
# 2 to max_groups categories
eda_group_choices <- function(data, max_groups = 15) {
  ok <- purrr::map_lgl(data, \(x) {
    values <- unique(stats::na.omit(haven::zap_missing(x)))
    discrete <- !is.numeric(unclass(values)) || all(values == round(values))
    discrete && length(values) >= 2 && length(values) <= max_groups
  })
  vars <- names(data)[ok]
  vars <- c(vars[startsWith(vars, "cluster_")], vars[!startsWith(vars, "cluster_")])
  eda_var_choices(data, vars)
}

# Possible weights: numeric variables without value labels
eda_weight_choices <- function(data) {
  ok <- purrr::map_lgl(data, \(x) {
    is.numeric(unclass(x)) && is.null(sjlabelled::get_labels(x)) && !all(is.na(x))
  })
  vars <- names(data)[ok]
  weight_like <- grepl("weight|gewicht|wgt", vars, ignore.case = TRUE)
  eda_var_choices(data, c(vars[weight_like], vars[!weight_like]))
}

# Codebook of the selected variables
eda_codebook <- function(data, vars, min_labels = 5) {
  purrr::map(vars, \(v) {
    x <- data[[v]]
    values <- sjlabelled::get_labels(x, values = "p")
    missing_codes <- c(attr(x, "na_values"), attr(x, "na_range"))
    tibble::tibble(
      variable = v,
      label = eda_var_labels(data, v)[[1]],
      type = eda_var_type(x, min_labels),
      valid = sum(!is.na(haven::zap_missing(x))),
      missing = sum(is.na(haven::zap_missing(x))),
      user_missing_codes = if (length(missing_codes) > 0) paste(missing_codes, collapse = ", ") else "",
      value_labels = if (is.null(values)) "" else paste(values, collapse = "; ")
    )
  }) |>
    purrr::list_rbind()
}

# Code of a function call, one argument per line
eda_call_string <- function(fun, data_name, args) {
  args <- purrr::compact(args)
  arg_text <- purrr::imap_chr(args, \(value, name) {
    paste0(name, " = ", paste(deparse(value, width.cutoff = 500L), collapse = ""))
  })
  paste0(fun, "(\n  ", paste(c(data_name, arg_text), collapse = ",\n  "), "\n)")
}

# Table with its own scroll bars (not resized by the card), so long tables do
# not overflow into the elements below
eda_dt <- function(tbl, digits = 2, height = "400px") {
  if (is.null(tbl) || nrow(tbl) == 0) {
    return(NULL)
  }
  DT::datatable(
    eda_round(tbl, digits),
    rownames = FALSE,
    filter = "top",
    fillContainer = FALSE,
    options = list(
      paging = FALSE,
      scrollX = TRUE,
      scrollY = height,
      scrollCollapse = TRUE,
      dom = "ti"
    )
  )
}

eda_explore_app <- function(objects, first) {
  nz <- function(x) if (is.null(x) || identical(x, "")) NULL else x
  red <- yougov_colors[["Red 1"]]

  ui <- bslib::page_sidebar(
    title = "YouAnalyser: explore data",
    theme = bslib::bs_theme(version = 5, primary = red),
    sidebar = bslib::sidebar(
      width = 360,
      shiny::selectInput("dataset", "Dataset", choices = names(objects), selected = first),
      shiny::selectizeInput(
        "vars", "Variables",
        choices = NULL, multiple = TRUE,
        options = list(
          placeholder = "Search by name or label",
          plugins = list("remove_button")
        )
      ),
      bslib::layout_columns(
        col_widths = c(6, 3, 3),
        shiny::textInput("pattern", NULL, placeholder = "Regex, e.g. ^F50_0_"),
        shiny::actionButton("add_pattern", "Add", class = "btn-sm"),
        shiny::actionButton("clear_vars", "Clear", class = "btn-sm")
      ),
      shiny::selectInput("group", "Grouping variable", choices = c("None" = "")),
      shiny::selectInput("weight", "Weight (optional)", choices = c("None" = "")),
      bslib::accordion(
        open = "Plot",
        bslib::accordion_panel(
          "Plot",
          shiny::radioButtons(
            "type", "Type",
            choices = c("Auto" = "auto", "Bars (means)" = "bar", "Boxplots" = "box", "Distributions" = "stacked"),
            inline = TRUE
          ),
          shiny::radioButtons(
            "orientation", "Orientation",
            choices = c("Horizontal" = "horizontal", "Vertical" = "vertical"),
            inline = TRUE
          ),
          shiny::radioButtons(
            "error", "Error bars",
            choices = c("95% CI" = "ci", "SE" = "se", "SD" = "sd", "None" = "none"),
            inline = TRUE
          ),
          shiny::checkboxInput("show_values", "Show values", TRUE),
          shiny::checkboxInput("show_sig", "Mark significant differences (with group)", FALSE),
          shiny::checkboxInput("total", "Add total", FALSE),
          shiny::checkboxInput("facet", "One panel per variable", FALSE),
          shiny::radioButtons(
            "axis_labels", "Variable names on axis",
            choices = c("Label" = "label", "Name" = "name", "Both" = "both"),
            inline = TRUE
          ),
          shiny::sliderInput("label_width", "Label width (characters)", 15, 100, 40, step = 5),
          shiny::sliderInput("height", "Plot height (px)", 300, 2000, 600, step = 50)
        ),
        bslib::accordion_panel(
          "Statistics",
          shiny::radioButtons(
            "treat_as", "Treat variables as",
            choices = c("Auto" = "auto", "Numeric (means)" = "numeric", "Categorical (distributions)" = "categorical")
          ),
          shiny::numericInput("min_labels", "Auto: numeric from ... value labels", 5, min = 2, max = 20),
          shiny::numericInput("conf_level", "Confidence level", 0.95, min = 0.5, max = 0.999, step = 0.01),
          shiny::radioButtons(
            "test_method", "Tests",
            choices = c("Parametric" = "parametric", "Nonparametric" = "nonparametric"),
            inline = TRUE
          ),
          shiny::radioButtons(
            "reference", "Compare each group with",
            choices = c(
              "Total (incl. the group)" = "total",
              "Rest of the sample" = "rest",
              "Mean of the group means" = "meandev",
              "Each other group" = "groups"
            )
          ),
          shiny::numericInput("alpha", "Significance level", 0.05, min = 0.001, max = 0.2, step = 0.01)
        ),
        bslib::accordion_panel(
          "Detailed plot (ggstatsplot)",
          shiny::selectInput("gs_var", "Variable", choices = NULL),
          shiny::selectInput(
            "gs_type", "Test type",
            choices = c(
              "Parametric" = "parametric", "Nonparametric" = "nonparametric",
              "Robust" = "robust", "Bayesian" = "bayes"
            )
          ),
          shiny::selectInput(
            "gs_pairwise", "Pairwise comparisons shown",
            choices = c("Significant" = "significant", "All" = "all", "None" = "none")
          ),
          shiny::selectInput(
            "gs_p_adjust", "p-value adjustment",
            choices = c("Holm" = "holm", "Bonferroni" = "bonferroni", "Benjamini-Hochberg" = "BH", "None" = "none")
          ),
          shiny::checkboxInput("gs_violin", "Violin plot", TRUE),
          shiny::checkboxInput("gs_points", "Individual data points", TRUE),
          shiny::checkboxInput("gs_boxplot", "Boxplot", TRUE),
          shiny::checkboxInput("gs_centrality", "Mean (or median) with label", TRUE),
          shiny::checkboxInput("gs_subtitle", "Test results as subtitle", TRUE),
          shiny::radioButtons(
            "gs_bar_label", "Bar labels (categorical variables)",
            choices = c("Percent" = "percentage", "Counts" = "counts", "Both" = "both"),
            inline = TRUE
          ),
          shiny::sliderInput("gs_height", "Plot height (px)", 300, 1500, 650, step = 50)
        )
      ),
      shiny::actionButton("done", "Done", class = "btn-primary")
    ),
    bslib::navset_card_tab(
      bslib::nav_panel(
        "Plot",
        shiny::plotOutput("plot", height = "auto"),
        bslib::layout_columns(
          col_widths = c(3, 3, 6),
          shiny::numericInput("dl_width", "Width (cm)", 30, min = 5, max = 60),
          shiny::numericInput("dl_height", "Height (cm)", 15, min = 5, max = 60),
          shiny::div(
            style = "margin-top: 2rem;",
            shiny::downloadButton("download_plot", "Download plot (JPEG)", class = "btn-sm")
          )
        )
      ),
      bslib::nav_panel(
        "Statistics",
        shiny::h5("Numeric variables"),
        DT::DTOutput("table_numeric"),
        shiny::h5("Categorical variables"),
        DT::DTOutput("table_categorical"),
        shiny::downloadButton("download_tables", "Download tables (Excel)", class = "btn-sm")
      ),
      bslib::nav_panel(
        "Tests",
        shiny::uiOutput("tests_info"),
        shiny::h5("Omnibus tests"),
        DT::DTOutput("table_omnibus"),
        shiny::uiOutput("comparisons_title"),
        DT::DTOutput("table_pairwise")
      ),
      bslib::nav_panel(
        "Detailed plot",
        shiny::p(shiny::em(
          "One variable by group with ggstatsplot (unweighted). Choose the variable and the options in the sidebar under \"Detailed plot (ggstatsplot)\"."
        )),
        shiny::plotOutput("ggstats", height = "auto"),
        bslib::layout_columns(
          col_widths = c(3, 3, 6),
          shiny::numericInput("gs_dl_width", "Width (cm)", 30, min = 5, max = 60),
          shiny::numericInput("gs_dl_height", "Height (cm)", 20, min = 5, max = 60),
          shiny::div(
            style = "margin-top: 2rem;",
            shiny::downloadButton("download_ggstats", "Download plot (JPEG)", class = "btn-sm")
          )
        )
      ),
      bslib::nav_panel("Codebook", DT::DTOutput("table_codebook")),
      bslib::nav_panel(
        "Code",
        shiny::p("Code to reproduce the plot and the statistics:"),
        shiny::verbatimTextOutput("code")
      )
    )
  )

  server <- function(input, output, session) {
    data <- shiny::reactive({
      shiny::req(input$dataset)
      eda_resolve_data(objects[[input$dataset]])
    })

    shiny::observeEvent(data(), {
      d <- data()
      shiny::updateSelectizeInput(
        session, "vars",
        choices = eda_var_choices_df(d), selected = character(0), server = TRUE
      )
      shiny::updateSelectInput(session, "group", choices = c("None" = "", eda_group_choices(d)))
      shiny::updateSelectInput(session, "weight", choices = c("None" = "", eda_weight_choices(d)))
    })

    shiny::observeEvent(input$add_pattern, {
      d <- data()
      matches <- tryCatch(
        grep(input$pattern, names(d), value = TRUE),
        error = function(e) character(0)
      )
      if (length(matches) == 0) {
        shiny::showNotification("No variable matches the pattern.", type = "warning")
      }
      shiny::updateSelectizeInput(
        session, "vars",
        choices = eda_var_choices_df(d),
        selected = union(input$vars, setdiff(matches, nz(input$group))),
        server = TRUE
      )
    })

    shiny::observeEvent(input$orientation, {
      width <- if (input$orientation == "horizontal") 40 else 15
      shiny::updateSliderInput(session, "label_width", value = width)
    }, ignoreInit = TRUE)

    shiny::observeEvent(input$clear_vars, {
      shiny::updateSelectizeInput(
        session, "vars",
        choices = eda_var_choices_df(data()), selected = character(0), server = TRUE
      )
    })

    shiny::observeEvent(input$vars, {
      choices <- eda_var_choices(data(), setdiff(input$vars %||% character(0), nz(input$group)))
      selected <- if (isTRUE(input$gs_var %in% choices)) input$gs_var
      shiny::updateSelectInput(session, "gs_var", choices = choices, selected = selected)
    }, ignoreNULL = FALSE)

    vars <- shiny::reactive({
      v <- setdiff(input$vars, nz(input$group))
      shiny::validate(shiny::need(length(v) > 0, "Select at least one variable."))
      v
    }) |>
      shiny::debounce(500)

    plot_args <- shiny::reactive({
      list(
        vars = vars(),
        group = nz(input$group),
        weight = nz(input$weight),
        type = input$type,
        orientation = input$orientation,
        error = input$error,
        conf_level = input$conf_level,
        total = input$total,
        facet = input$facet,
        show_values = input$show_values,
        show_sig = input$show_sig,
        reference = input$reference,
        test_method = input$test_method,
        alpha = input$alpha,
        axis_labels = input$axis_labels,
        label_width = input$label_width,
        min_labels = input$min_labels
      )
    })

    describe_args <- shiny::reactive({
      list(
        vars = vars(),
        group = nz(input$group),
        weight = nz(input$weight),
        treat_as = input$treat_as,
        conf_level = input$conf_level,
        total = input$total,
        test = !is.null(nz(input$group)),
        test_method = input$test_method,
        reference = input$reference,
        min_labels = input$min_labels
      )
    })

    plot_obj <- shiny::reactive(do.call(eda_plot, c(list(data = data()), plot_args())))
    describe_obj <- shiny::reactive(do.call(eda_describe, c(list(data = data()), describe_args())))

    output$plot <- shiny::renderPlot(plot_obj(), height = function() input$height, res = 96)

    output$download_plot <- shiny::downloadHandler(
      filename = function() "eda_plot.jpeg",
      content = function(file) {
        ya_save_plot(
          plot_obj(), file,
          width = input$dl_width, height = input$dl_height, verbose = FALSE
        )
      }
    )

    output$table_numeric <- DT::renderDT(eda_dt(describe_obj()$numeric))
    output$table_categorical <- DT::renderDT(eda_dt(describe_obj()$categorical))

    output$download_tables <- shiny::downloadHandler(
      filename = function() "eda_statistics.xlsx",
      content = function(file) {
        res <- describe_obj()
        sheets <- purrr::compact(list(
          numeric = res$numeric,
          categorical = res$categorical,
          tests = res$tests$omnibus,
          pairwise = res$tests$pairwise
        ))
        openxlsx::write.xlsx(sheets, file)
      }
    )

    output$tests_info <- shiny::renderUI({
      if (is.null(nz(input$group))) {
        shiny::p(shiny::em("Select a grouping variable to test group differences."))
      }
    })
    output$table_omnibus <- DT::renderDT({
      tests <- describe_obj()$tests
      shiny::req(tests)
      eda_dt(tests$omnibus, digits = 3)
    })
    output$comparisons_title <- shiny::renderUI({
      title <- paste0(eda_comparison_title(input$reference), " (Holm-adjusted)")
      shiny::h5(title, style = "margin-top: 1rem;")
    })
    output$table_pairwise <- DT::renderDT({
      tests <- describe_obj()$tests
      shiny::req(tests)
      eda_dt(tests$pairwise, digits = 3)
    })

    ggstats_obj <- shiny::reactive({
      shiny::validate(
        shiny::need(
          requireNamespace("ggstatsplot", quietly = TRUE),
          "Install the ggstatsplot package for detailed plots: install.packages(\"ggstatsplot\")"
        ),
        shiny::need(nz(input$group), "Select a grouping variable."),
        shiny::need(nz(input$gs_var), "Select variables (the detailed plot shows one of them).")
      )
      do.call(eda_plot_detail, c(list(data = data()), detail_args()))
    })
    output$ggstats <- shiny::renderPlot(ggstats_obj(), height = function() input$gs_height, res = 96)

    output$download_ggstats <- shiny::downloadHandler(
      filename = function() paste0("eda_ggstatsplot_", input$gs_var, ".jpeg"),
      content = function(file) {
        ya_save_plot(
          ggstats_obj(), file,
          width = input$gs_dl_width, height = input$gs_dl_height, verbose = FALSE
        )
      }
    )

    output$table_codebook <- DT::renderDT({
      d <- data()
      v <- input$vars %||% names(d)
      eda_dt(eda_codebook(d, v, input$min_labels))
    })

    detail_args <- shiny::reactive({
      list(
        var = nz(input$gs_var),
        group = nz(input$group),
        weight = nz(input$weight),
        treat_as = input$treat_as,
        min_labels = input$min_labels,
        type = input$gs_type,
        violin = input$gs_violin,
        points = input$gs_points,
        boxplot = input$gs_boxplot,
        centrality = input$gs_centrality,
        pairwise_display = input$gs_pairwise,
        p_adjust = input$gs_p_adjust,
        results_subtitle = input$gs_subtitle,
        bar_label = input$gs_bar_label
      )
    })

    code_text <- shiny::reactive({
      detail <- detail_args()
      paste(
        c(
          eda_call_string("eda_plot", input$dataset, plot_args()),
          eda_call_string("eda_describe", input$dataset, describe_args()),
          if (!is.null(detail$var) && !is.null(detail$group)) {
            eda_call_string("eda_plot_detail", input$dataset, detail)
          }
        ),
        collapse = "\n\n"
      )
    })
    output$code <- shiny::renderText(code_text())

    shiny::observeEvent(input$done, {
      result <- tryCatch(
        list(plot = plot_obj(), describe = describe_obj(), code = code_text()),
        error = function(e) NULL
      )
      if (!is.null(result)) {
        cat(result$code, "\n")
      }
      shiny::stopApp(result)
    })
  }

  list(ui = ui, server = server)
}
