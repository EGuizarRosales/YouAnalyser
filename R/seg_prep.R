# ---- Constants ---------------------------------------------------------------

# Distance measures supported by factoextra::get_dist()
seg_get_dist_methods <- c(
  "euclidean",
  "maximum",
  "manhattan",
  "canberra",
  "binary",
  "minkowski",
  "pearson",
  "spearman",
  "kendall"
)

# Distance measures supported by cluster::daisy()
seg_daisy_methods <- c("euclidean", "manhattan", "gower")


# ---- Data preparation --------------------------------------------------------

#' Prepare survey data for cluster analysis
#'
#' Prepares a (haven-labelled) data frame for segmentation: selects the
#' clustering variables, handles missing values, rescales the variables and
#' (optionally) computes a distance matrix using [factoextra::get_dist()] or
#' [cluster::daisy()].
#'
#' @details
#' Cluster analysis groups respondents that are *similar*. How similarity is
#' measured is defined by the distance measure, which is therefore one of the
#' most important choices of a segmentation. The descriptions below follow
#' [datanovia](https://www.datanovia.com/learn/machine-learning/clustering/distance-measures).
#' \eqn{x} and \eqn{y} denote the answers of two respondents on the \eqn{n}
#' clustering variables.
#'
#' ## Distance-based measures
#'
#' These measures compare the *values* of two respondents: respondents with
#' similar answers on all variables are close.
#'
#' * **Euclidean** (`"euclidean"`, default):
#'   \eqn{d(x, y) = \sqrt{\sum_{i=1}^n (x_i - y_i)^2}}{d(x, y) = sqrt(sum((x_i - y_i)^2))}.
#'   The straight-line distance. Large differences weigh more, as they are
#'   squared. *Use it* as the default, in particular with k-means and Ward's
#'   hierarchical clustering, which are built on it (k-means always uses
#'   Euclidean distances, whatever is specified here).
#'
#' * **Manhattan** (`"manhattan"`):
#'   \eqn{d(x, y) = \sum_{i=1}^n |x_i - y_i|}{d(x, y) = sum(|x_i - y_i|)}.
#'   The sum of the absolute differences ("city block" distance). Less
#'   sensitive to outliers and single extreme answers than Euclidean. *Use it*
#'   for rating scales, where differences of one scale point simply add up,
#'   or if the data contains outliers; works well with PAM.
#'
#' * **Maximum** (`"maximum"`, Chebyshev distance):
#'   \eqn{d(x, y) = \max_i |x_i - y_i|}{d(x, y) = max(|x_i - y_i|)}. Only the
#'   largest difference on any single variable counts. *Rarely useful* for
#'   survey data, as a single item dominates the distance.
#'
#' * **Minkowski** (`"minkowski"`):
#'   \eqn{d(x, y) = (\sum_{i=1}^n |x_i - y_i|^p)^{1/p}}{d(x, y) = (sum(|x_i - y_i|^p))^(1/p)},
#'   a generalization of Manhattan (\eqn{p = 1}) and Euclidean (\eqn{p = 2},
#'   used here).
#'
#' * **Canberra** (`"canberra"`):
#'   \eqn{d(x, y) = \sum_{i=1}^n |x_i - y_i| / (|x_i| + |y_i|)}{d(x, y) = sum(|x_i - y_i| / (|x_i| + |y_i|))}.
#'   A weighted Manhattan distance, in which differences between small values
#'   weigh more. *Use it* only for non-negative data (e.g. counts or shares,
#'   with `scale = "range"` or `"none"`), not with z-standardized data.
#'
#' * **Binary** (`"binary"`): the proportion of variables in which only one
#'   of the two respondents has a non-zero value, among the variables in
#'   which at least one has a non-zero value. *Use it* for 0/1 data, e.g.
#'   multiple-response questions (with `scale = "none"`).
#'
#' ## Correlation-based measures
#'
#' These measures compare the *profiles* of two respondents across the
#' variables: two respondents are close if their answers go up and down
#' together, regardless of their overall level. The distance is
#' \eqn{d(x, y) = 1 - r(x, y)}, where \eqn{r} is a correlation coefficient
#' between the answers of the two respondents (range 0 to 2).
#'
#' * **Pearson** (`"pearson"`): based on the Pearson correlation.
#' * **Spearman** (`"spearman"`): based on the rank correlation. More robust
#'   to outliers and only assumes a monotonic relation; well suited for
#'   ordinal rating scales.
#' * **Kendall** (`"kendall"`): based on the proportion of concordant pairs
#'   of ranks. Similar to Spearman, more robust with many ties, but slower.
#'
#' *Use them* when the *pattern* of answers matters more than their level,
#' e.g. to reduce the influence of response styles: a respondent who agrees
#' a bit more with every item (acquiescence) has the same profile as a
#' respondent with the same relative preferences. They require a fair number
#' of clustering variables, as the correlation is computed across them for
#' each pair of respondents.
#'
#' ## Gower distance
#'
#' **Gower** (`"gower"`, via [cluster::daisy()]): each variable contributes a
#' distance between 0 and 1 (the absolute difference divided by the range for
#' numeric variables, 0/1 for a mismatch for nominal variables, ranks for
#' ordinal variables), and the distance is the average over all variables
#' that both respondents answered. *Use it* for mixed data types (see
#' `daisy_args`) or to keep missing values (`missing = "none"`). Combine it
#' with PAM or hierarchical clustering, not with k-means.
#'
#' ## Choosing a distance measure and scaling
#'
#' * Typical attitude batteries on the same rating scale: Euclidean (default)
#'   or Manhattan; Spearman or Pearson to cluster on answer patterns.
#' * Data with outliers or extreme answers: Manhattan (with PAM).
#' * Binary data: binary; mixed data types or missing values: Gower.
#'
#' Distance-based measures depend on the scale of the variables: variables
#' with a large range or variance dominate the distance. Variables measured on
#' different scales must therefore be rescaled (`scale = "z"` or `"range"`).
#' For items on the same scale, z-standardization gives each item the same
#' weight; use `scale = "none"` if differences in variance are meaningful.
#'
#' @param data A data frame, typically a haven-labelled tibble (e.g. read in
#'   with `haven::read_sav(path, user_na = TRUE)`). User-defined missing values
#'   (e.g. 99 = "don't know") must already be recoded to `NA`, e.g. with
#'   [dp_recode_missing()].
#' @param vars <[`tidy-select`][dplyr::dplyr_tidy_select]> Clustering variables.
#'   Must be numeric (haven-labelled numeric variables are fine). Defaults to
#'   all variables.
#' @param id Optional single string naming an identifier column in `data`. Its
#'   values are used as row names of the prepared data and labels of the
#'   distance matrix (e.g. for [factoextra::fviz_dist()]).
#' @param missing How to handle missing values in the clustering variables.
#'   Respondents without any valid answer on the clustering variables are
#'   always removed first.
#'   * `"omit"` (default): listwise deletion of respondents with any missing value.
#'   * `"mean"` / `"median"`: replace missing values with the variable mean / median.
#'   * `"mice"`: single imputation with [mice::mice()] (predictive mean matching
#'     by default, see `imputation_args`). Preserves the relationships between
#'     variables better than mean/median imputation.
#'   * `"none"`: keep missing values. Only allowed with `distance_engine = "daisy"`,
#'     which computes dissimilarities from the available pairs of values.
#' @param max_missing_prop Optional number between 0 and 1. Respondents with a
#'   higher proportion of missing values across the clustering variables are
#'   removed *before* `missing` is applied. Useful to combine with imputation,
#'   e.g. `max_missing_prop = 0.2, missing = "mice"`. `NULL` (default) keeps
#'   all respondents.
#' @param scale How to rescale the clustering variables:
#'   * `"z"` (default): z-standardization (mean 0, SD 1), see [base::scale()].
#'   * `"range"`: min-max scaling to the range 0 to 1.
#'   * `"none"`: keep the original values, e.g. if all variables share the same
#'     response scale and differences in variance are meaningful.
#' @param distance Distance measure. With `distance_engine = "get_dist"` one of
#'   `"euclidean"`, `"maximum"`, `"manhattan"`, `"canberra"`, `"binary"`,
#'   `"minkowski"`, `"pearson"`, `"spearman"` or `"kendall"`. With
#'   `distance_engine = "daisy"` one of `"euclidean"`, `"manhattan"` or
#'   `"gower"`. Defaults to `"euclidean"`.
#' @param distance_engine Which function computes the distance matrix:
#'   `"auto"` (default) uses [cluster::daisy()] for `distance = "gower"` and
#'   [factoextra::get_dist()] otherwise; `"get_dist"` or `"daisy"` force the
#'   respective function.
#' @param compute_distance Logical. Whether to compute the distance matrix.
#'   Defaults to `TRUE`. Set to `FALSE` for large samples if only the prepared
#'   data is needed (e.g. for k-means), as the distance matrix grows with the
#'   square of the number of respondents.
#' @param imputation_args A list of arguments passed to [mice::mice()] when
#'   `missing = "mice"`. Only a single imputation (`m = 1`) is used.
#' @param daisy_args A list of further arguments passed to [cluster::daisy()],
#'   e.g. `list(type = list(ordratio = c("F50_0_1", "F50_0_2")))` to treat
#'   variables as ordinal when using Gower distance.
#' @param verbose Logical. Whether to print a summary of the preparation steps.
#'   Defaults to `TRUE`.
#'
#' @returns An object of class `seg_prep`, a list with the elements:
#'   * `data`: tibble with the prepared (cleaned, imputed, rescaled) clustering
#'     variables, keeping their variable labels. Use this as input for
#'     clustering algorithms such as k-means.
#'   * `data_full`: the original `data` (all columns, labels intact) restricted
#'     to the respondents retained in `data`, in the same order. Use this to
#'     profile the resulting segments.
#'   * `dist`: the distance matrix (class `dist`), or `NULL` if
#'     `compute_distance = FALSE`.
#'   * `row_index`: integer positions of the retained respondents in `data`.
#'   * `settings`: list of the settings used.
#'   * `info`: list with the number of respondents before and after the
#'     preparation, the number of imputed values and dropped constant variables.
#'
#' @seealso [seg_distance()] to compute a distance matrix on already prepared data.
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   id = "id",
#'   missing = "mice",
#'   max_missing_prop = 0.2
#' )
#' }
#'
#' @export
seg_prep_data <- function(
  data,
  vars = dplyr::everything(),
  id = NULL,
  missing = c("omit", "mean", "median", "mice", "none"),
  max_missing_prop = NULL,
  scale = c("z", "range", "none"),
  distance = "euclidean",
  distance_engine = c("auto", "get_dist", "daisy"),
  compute_distance = TRUE,
  imputation_args = list(method = "pmm", seed = 123, printFlag = FALSE),
  daisy_args = list(),
  verbose = TRUE
) {
  # ---- 1. Check arguments ----

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }

  missing <- rlang::arg_match(missing)
  scale <- rlang::arg_match(scale)
  distance_engine <- rlang::arg_match(distance_engine)
  distance_engine <- seg_resolve_engine(distance, distance_engine)

  if (missing == "none" && distance_engine != "daisy") {
    cli::cli_abort(c(
      "{.code missing = \"none\"} requires {.code distance_engine = \"daisy\"}.",
      "i" = "{.fn factoextra::get_dist} cannot handle missing values reliably.",
      "i" = "Choose another {.arg missing} strategy or use {.code distance_engine = \"daisy\"}."
    ))
  }

  if (
    !is.null(max_missing_prop) &&
      (!is.numeric(max_missing_prop) ||
        length(max_missing_prop) != 1 ||
        max_missing_prop < 0 ||
        max_missing_prop > 1)
  ) {
    cli::cli_abort("{.arg max_missing_prop} must be a single number between 0 and 1.")
  }

  if (!is.null(id)) {
    if (!rlang::is_string(id) || !id %in% names(data)) {
      cli::cli_abort("{.arg id} must be the name of a column in {.arg data}.")
    }
    if (anyDuplicated(data[[id]]) || anyNA(data[[id]])) {
      cli::cli_abort("{.arg id} column {.val {id}} must be unique and contain no missing values.")
    }
  }

  # ---- 2. Select clustering variables ----

  x <- dplyr::select(data, {{ vars }})

  if (!is.null(id)) {
    x <- dplyr::select(x, -dplyr::any_of(id))
  }

  if (ncol(x) < 2) {
    cli::cli_abort("At least two clustering variables must be selected in {.arg vars}.")
  }

  non_numeric <- names(x)[!purrr::map_lgl(x, is.numeric)]
  if (length(non_numeric) > 0) {
    cli::cli_abort(c(
      "All clustering variables must be numeric.",
      "x" = "Non-numeric variable{?s}: {.val {non_numeric}}"
    ))
  }

  # Save variable labels and strip haven classes
  var_labels <- sjlabelled::get_label(x, def.value = names(x))
  x <- x |>
    dplyr::mutate(dplyr::across(dplyr::everything(), \(v) {
      as.numeric(haven::zap_labels(v))
    }))

  n_input <- nrow(x)
  row_index <- seq_len(n_input)

  # ---- 3. Handle missing values ----

  # 3a. Always remove respondents without any valid answer: they carry no
  # information and would otherwise be imputed as the "average respondent"
  # or produce NA distances
  keep <- rowSums(!is.na(x)) > 0
  n_dropped_all_missing <- sum(!keep)
  x <- x[keep, , drop = FALSE]
  row_index <- row_index[keep]

  # 3b. Remove respondents with too many missing values
  n_dropped_max_missing <- 0L
  if (!is.null(max_missing_prop)) {
    keep <- rowMeans(is.na(x)) <= max_missing_prop
    n_dropped_max_missing <- sum(!keep)
    x <- x[keep, , drop = FALSE]
    row_index <- row_index[keep]
  }

  # 3c. Apply missing strategy
  n_imputed <- sum(is.na(x))
  n_dropped_omit <- 0L

  if (missing == "omit") {
    keep <- stats::complete.cases(x)
    n_dropped_omit <- sum(!keep)
    n_imputed <- 0L
    x <- x[keep, , drop = FALSE]
    row_index <- row_index[keep]
  } else if (missing %in% c("mean", "median")) {
    fun <- if (missing == "mean") mean else stats::median
    x <- x |>
      dplyr::mutate(dplyr::across(dplyr::everything(), \(v) {
        v[is.na(v)] <- fun(v, na.rm = TRUE)
        v
      }))
  } else if (missing == "mice" && n_imputed > 0) {
    imputation_args$m <- 1
    imp <- do.call(mice::mice, c(list(data = as.data.frame(x)), imputation_args))
    x <- tibble::as_tibble(mice::complete(imp, 1))
    if (anyNA(x)) {
      cli::cli_abort(c(
        "Imputation with {.fn mice::mice} left missing values.",
        "i" = "Check for (nearly) collinear or constant variables, or use another {.arg missing} strategy."
      ))
    }
  } else if (missing == "none") {
    n_imputed <- 0L
  }

  if (nrow(x) < 3) {
    cli::cli_abort("Fewer than 3 respondents remain after handling missing values.")
  }

  # ---- 4. Drop constant variables ----

  is_constant <- purrr::map_lgl(x, \(v) {
    length(unique(v[!is.na(v)])) < 2
  })
  dropped_constant <- names(x)[is_constant]
  if (length(dropped_constant) > 0) {
    cli::cli_warn(c(
      "Constant variable{?s} removed from the clustering variables: {.val {dropped_constant}}"
    ))
    x <- x[, !is_constant, drop = FALSE]
  }

  # ---- 5. Rescale ----

  x <- x |>
    dplyr::mutate(dplyr::across(dplyr::everything(), \(v) {
      seg_rescale(v, scale)
    }))

  # Add back variable labels
  x <- sjlabelled::set_label(x, label = unname(var_labels[names(x)]))

  # ---- 6. Distance matrix ----

  row_ids <- if (is.null(id)) row_index else data[[id]][row_index]
  dist_obj <- NULL
  if (compute_distance) {
    dist_obj <- seg_distance(
      x,
      distance = distance,
      distance_engine = distance_engine,
      labels = row_ids,
      daisy_args = daisy_args
    )
    n_na_dist <- sum(is.na(dist_obj))
    if (n_na_dist > 0) {
      cli::cli_warn(c(
        "The distance matrix contains {n_na_dist} missing value{?s}.",
        "i" = "Some respondents have no clustering variable answered in common.",
        "i" = "Set {.arg max_missing_prop} or use another {.arg missing} strategy."
      ))
    }
  }

  # ---- 7. Output ----

  out <- structure(
    list(
      data = x,
      data_full = data[row_index, , drop = FALSE],
      dist = dist_obj,
      row_index = row_index,
      settings = list(
        vars = names(x),
        id = id,
        missing = missing,
        max_missing_prop = max_missing_prop,
        scale = scale,
        distance = distance,
        distance_engine = distance_engine,
        daisy_args = daisy_args
      ),
      info = list(
        n_input = n_input,
        n_dropped_all_missing = n_dropped_all_missing,
        n_dropped_max_missing = n_dropped_max_missing,
        n_dropped_omit = n_dropped_omit,
        n_output = nrow(x),
        n_imputed_values = n_imputed,
        dropped_constant_vars = dropped_constant
      )
    ),
    class = c("seg_prep", "list")
  )

  if (verbose) {
    print(out)
  }

  invisible(out)
}


#' Compute a distance matrix for cluster analysis
#'
#' Thin wrapper around [factoextra::get_dist()] and [cluster::daisy()] with a
#' common interface. Usually called via [seg_prep_data()], but can be used on
#' its own on already prepared (e.g. standardized) data.
#'
#' @param x A data frame or numeric matrix with the (prepared) clustering
#'   variables.
#' @param distance Distance measure, see [seg_prep_data()].
#' @param distance_engine `"auto"`, `"get_dist"` or `"daisy"`, see
#'   [seg_prep_data()].
#' @param labels Optional vector of labels for the observations (length
#'   `nrow(x)`), used as labels of the distance matrix.
#' @param daisy_args A list of further arguments passed to [cluster::daisy()].
#'
#' @returns A distance matrix of class `dist` (for `"daisy"` additionally of
#'   class `dissimilarity`).
#'
#' @examples
#' x <- scale(datasets::USArrests)
#' d <- seg_distance(x, distance = "manhattan")
#' d_gower <- seg_distance(datasets::USArrests, distance = "gower")
#'
#' @export
seg_distance <- function(
  x,
  distance = "euclidean",
  distance_engine = c("auto", "get_dist", "daisy"),
  labels = NULL,
  daisy_args = list()
) {
  distance_engine <- rlang::arg_match(distance_engine)
  distance_engine <- seg_resolve_engine(distance, distance_engine)

  x <- as.data.frame(x)
  x[] <- lapply(x, \(v) as.numeric(haven::zap_labels(v)))

  if (!is.null(labels)) {
    if (length(labels) != nrow(x)) {
      cli::cli_abort("{.arg labels} must have the same length as {.code nrow(x)}.")
    }
    rownames(x) <- as.character(labels)
  }

  if (distance_engine == "get_dist") {
    if (anyNA(x)) {
      cli::cli_abort(c(
        "{.arg x} contains missing values.",
        "i" = "Handle them first or use {.code distance_engine = \"daisy\"}."
      ))
    }
    factoextra::get_dist(x, method = distance, stand = FALSE)
  } else {
    do.call(
      cluster::daisy,
      c(list(x = x, metric = distance, stand = FALSE), daisy_args)
    )
  }
}


#' @export
print.seg_prep <- function(x, ...) {
  s <- x$settings
  i <- x$info
  dist_txt <- if (is.null(x$dist)) {
    "not computed"
  } else {
    paste0(s$distance, " (", s$distance_engine, ")")
  }

  max_missing_txt <- if (is.null(s$max_missing_prop)) {
    "not applied"
  } else {
    paste0(
      i$n_dropped_max_missing,
      " respondent(s) with more than ",
      round(100 * s$max_missing_prop),
      "% missing removed"
    )
  }

  cli::cli_h2("Data prepared for cluster analysis")
  cli::cli_ul(c(
    "Clustering variables: {length(s$vars)}",
    "Respondents: {i$n_input} in, {i$n_output} retained",
    "Without any valid answer: {i$n_dropped_all_missing} respondent{?s} removed",
    "Missing threshold: {max_missing_txt}",
    "Missing values: {.val {s$missing}} ({i$n_dropped_omit} respondent{?s} removed, {i$n_imputed_values} value{?s} imputed)",
    "Scaling: {.val {s$scale}}",
    "Distance: {dist_txt}"
  ))
  if (length(i$dropped_constant_vars) > 0) {
    cli::cli_alert_warning(
      "Dropped constant variable{?s}: {.val {i$dropped_constant_vars}}"
    )
  }
  invisible(x)
}


# ---- Clustering tendency -----------------------------------------------------

#' Assess the clustering tendency of the data
#'
#' Before running a cluster analysis, check whether the data contains
#' meaningful clusters at all (cluster algorithms always return clusters, even
#' for random data). Following the approach described by
#' [datanovia](https://www.datanovia.com/learn/machine-learning/clustering/clustering-tendency),
#' the function compares the actual data with a random dataset drawn from a
#' uniform distribution within the range of each clustering variable, using
#'
#' * the **Hopkins statistic** (via [factoextra::get_clust_tendency()]), and
#' * a **VAT plot** (Visual Assessment of cluster Tendency, via
#'   [factoextra::fviz_dist()]): an ordered dissimilarity matrix in which
#'   clusters appear as squares along the diagonal.
#'
#' @section Interpretation:
#' factoextra (>= 2.0) uses the corrected Hopkins statistic (Wright, 2022).
#' Values close to 0.5 indicate uniformly distributed (random) data, values
#' close to 1 indicate a clustering tendency. As a rule of thumb, values above
#' 0.75 indicate a clear clustering tendency. The statistic of the actual data
#' should be clearly higher than the one of the random data, and its VAT plot
#' should show more structure (squares along the diagonal).
#'
#' The Hopkins statistic measures the deviation from *uniformly distributed*
#' data, not the presence of well separated clusters. With many (correlated)
#' variables, as typical for attitude batteries in surveys, it is often close
#' to 1 even if the VAT plot shows little block structure. Always inspect the
#' VAT plot as well: if it shows no clear squares along the diagonal, the
#' segments should be regarded as a useful partition of a continuum rather
#' than naturally separated groups.
#'
#' @param x The output of [seg_prep_data()] (recommended), or a data frame or
#'   numeric matrix with already prepared clustering variables (no missing
#'   values). A distance matrix alone (e.g. from [seg_distance()]) is not
#'   sufficient, as the Hopkins statistic requires the data.
#' @param n Number of points sampled for the Hopkins statistic. `NULL`
#'   (default) uses `nrow(data) - 1`, as in the datanovia article.
#' @param distance,distance_engine Distance measure and engine for the VAT
#'   plots, see [seg_prep_data()]. If `NULL` (default), the settings of the
#'   [seg_prep_data()] output are used, otherwise `"euclidean"` and `"auto"`.
#' @param vat_n Number of respondents randomly sampled for the VAT plots, as
#'   these plots grow with the square of the number of respondents and become
#'   slow to render. Defaults to 500. `NULL` uses all respondents.
#' @param gradient A list with the colors `low`, `mid` and `high` for the VAT
#'   plots, passed to [factoextra::fviz_dist()]. Small distances (similar
#'   respondents) are shown in the `low` color.
#' @param seed Random seed for the random dataset, the Hopkins sampling and the
#'   VAT sampling. The global random seed is left untouched. Defaults to 123.
#' @param verbose Logical. Whether to print the results. Defaults to `TRUE`.
#'
#' @returns An object of class `seg_tendency`, a list with the elements:
#'   * `hopkins`: tibble with the Hopkins statistic of the actual and the
#'     random data.
#'   * `plot`: both VAT plots side by side.
#'   * `plot_actual`, `plot_random`: the individual VAT plots (ggplot objects).
#'   * `random_data`: the generated random dataset.
#'   * `settings`: list of the settings used.
#'
#' @references Wright, K. (2022). Will the real Hopkins statistic please stand
#'   up? *The R Journal, 14*(3), 282-292. \doi{10.32614/RJ-2022-055}
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#' tendency <- seg_clustering_tendency(prep)
#' tendency$plot
#' }
#'
#' @export
seg_clustering_tendency <- function(
  x,
  n = NULL,
  distance = NULL,
  distance_engine = NULL,
  vat_n = 500,
  gradient = list(
    low = yougov_colors[["Red 1"]],
    mid = "white",
    high = yougov_colors[["Blue 1"]]
  ),
  seed = 123,
  verbose = TRUE
) {
  # ---- 1. Get data and settings ----

  input <- seg_extract_input(x, distance, distance_engine)
  data <- input$data
  dist_actual <- input$dist
  distance <- input$distance
  distance_engine <- input$distance_engine
  scale <- input$scale
  daisy_args <- input$daisy_args

  n <- n %||% (nrow(data) - 1)

  # ---- 2. Random dataset ----

  # Uniformly distributed within the range of each variable, rescaled in the
  # same way as the actual data
  random_data <- seg_with_seed(seed, {
    purrr::map(data, \(v) stats::runif(length(v), min(v), max(v)))
  }) |>
    tibble::as_tibble() |>
    dplyr::mutate(dplyr::across(dplyr::everything(), \(v) {
      seg_rescale(v, scale)
    }))

  # ---- 3. Hopkins statistic ----

  hopkins <- function(d) {
    # factoextra warns once about the corrected formula; documented above
    withr_opts <- options(factoextra.warn_hopkins = FALSE)
    on.exit(options(withr_opts), add = TRUE)
    factoextra::get_clust_tendency(
      d,
      n = n,
      graph = FALSE,
      seed = seed
    )$hopkins_stat
  }

  # Computed first: inside tibble(), the column `data` would mask the object
  h_values <- c(hopkins(data), hopkins(random_data))
  hopkins_tbl <- tibble::tibble(
    data = c("actual", "random"),
    hopkins = h_values
  )

  # ---- 4. VAT plots ----

  vat_rows <- function(d) {
    if (is.null(vat_n) || vat_n >= nrow(d)) {
      return(seq_len(nrow(d)))
    }
    seg_with_seed(seed, sort(sample.int(nrow(d), vat_n)))
  }

  vat_plot <- function(d, dist_obj, title, h) {
    rows <- vat_rows(d)
    if (is.null(dist_obj) || length(rows) < nrow(d)) {
      dist_obj <- seg_distance(
        d[rows, , drop = FALSE],
        distance = distance,
        distance_engine = distance_engine,
        daisy_args = daisy_args
      )
    }
    if (anyNA(dist_obj)) {
      cli::cli_abort("The distance matrix contains missing values; the VAT plot cannot be drawn.")
    }
    factoextra::fviz_dist(
      dist_obj,
      order = TRUE,
      show_labels = FALSE,
      gradient = gradient
    ) +
      ggplot2::labs(
        title = title,
        subtitle = paste0(
          "Hopkins statistic: ",
          format(round(h, 2), nsmall = 2),
          " | n = ",
          length(rows),
          " | ",
          distance,
          " distance"
        ),
        fill = "Distance"
      ) +
      ggplot2::coord_fixed()
  }

  plot_actual <- vat_plot(
    data,
    dist_actual,
    "Actual data",
    hopkins_tbl$hopkins[1]
  )
  plot_random <- vat_plot(
    random_data,
    NULL,
    "Random data",
    hopkins_tbl$hopkins[2]
  )

  # ---- 5. Output ----

  out <- structure(
    list(
      hopkins = hopkins_tbl,
      plot = see::plots(plot_actual, plot_random, n_columns = 2),
      plot_actual = plot_actual,
      plot_random = plot_random,
      random_data = random_data,
      settings = list(
        n = n,
        distance = distance,
        distance_engine = distance_engine,
        scale = scale,
        vat_n = vat_n,
        seed = seed
      )
    ),
    class = c("seg_tendency", "list")
  )

  if (verbose) {
    print(out)
  }

  invisible(out)
}


#' @export
print.seg_tendency <- function(x, ...) {
  h_actual <- x$hopkins$hopkins[x$hopkins$data == "actual"]
  h_random <- x$hopkins$hopkins[x$hopkins$data == "random"]

  verdict <- if (h_actual > 0.75) {
    "data clearly deviates from random data"
  } else if (h_actual > 0.6) {
    "data moderately deviates from random data"
  } else {
    "data is close to random data (weak or no clustering tendency)"
  }

  cli::cli_h2("Clustering tendency")
  cli::cli_ul(c(
    "Hopkins statistic, actual data: {.strong {format(round(h_actual, 3), nsmall = 3)}}",
    "Hopkins statistic, random data: {format(round(h_random, 3), nsmall = 3)}",
    "Interpretation: {verdict}"
  ))
  cli::cli_text(
    "{.emph Values close to 0.5 indicate random data, values close to 1 a clustering tendency. With many correlated variables, Hopkins is often close to 1 even without well separated clusters: check whether the VAT plot in {.code $plot} shows squares along the diagonal.}"
  )
  invisible(x)
}


# ---- Optimal number of clusters ----------------------------------------------

#' Determine the optimal number of clusters
#'
#' Runs several methods to determine the optimal number of clusters (k) and
#' summarizes their suggestions, following the approach described by
#' [datanovia](https://www.datanovia.com/learn/machine-learning/clustering/optimal-clusters):
#'
#' * `"wss"`: Elbow method on the total within-cluster sum of squares, see
#'   [seg_nbclust_wss()].
#' * `"silhouette"`: Average silhouette width, see [seg_nbclust_silhouette()].
#' * `"gap_stat"`: Gap statistic, see [seg_nbclust_gap()].
#' * `"nbclust"`: Majority vote of up to 26 indices from the NbClust package,
#'   see [seg_nbclust_indices()].
#'
#' The methods often disagree. Use the suggestions as a starting point and
#' compare a few candidate solutions in terms of interpretability, segment
#' sizes and usefulness for the client.
#'
#' @section Computation time:
#' The defaults are chosen to keep the computation time moderate (about one
#' minute for 1,400 respondents and 20 variables with all methods). The gap
#' statistic (`nboot`, `nstart_gap`) and NbClust are by far the most expensive
#' methods; drop them from `methods` for quick explorations.
#'
#' @param x The output of [seg_prep_data()] (recommended), or a data frame or
#'   numeric matrix with already prepared clustering variables (no missing
#'   values).
#' @param methods Methods to run. Defaults to all of `"wss"`, `"silhouette"`,
#'   `"gap_stat"` and `"nbclust"`.
#' @param cluster_method Clustering algorithm used to evaluate the solutions:
#'   `"kmeans"` (default, [stats::kmeans()]), `"hclust"` (hierarchical
#'   clustering via [factoextra::hcut()]) or `"pam"` (partitioning around
#'   medoids, [cluster::pam()]). k-means always uses Euclidean distances.
#'   NbClust does not support `"pam"` and is skipped in that case.
#' @param k_max Maximum number of clusters to consider. Defaults to 10.
#' @param nstart Number of random starts for k-means (WSS, silhouette).
#'   Defaults to 25.
#' @param nboot Number of bootstrap samples for the gap statistic. Defaults to
#'   50 (factoextra uses 100), which keeps the computation time moderate.
#' @param nstart_gap Number of random starts for k-means within the gap
#'   statistic, which runs k-means `k_max * (nboot + 1)` times. Defaults to 10.
#' @param nbclust_index Index (or indices) computed by NbClust. Defaults to
#'   `"all"` (26 indices). See [NbClust::NbClust()] for other options, e.g.
#'   `"alllong"` (30 indices, much slower).
#' @param hc_method Agglomeration method for `cluster_method = "hclust"`.
#'   Defaults to `"ward.D2"`.
#' @param seed Random seed. The global random seed is left untouched. Defaults
#'   to 123.
#' @param verbose Logical. Whether to show progress and print the results.
#'   Defaults to `TRUE`.
#'
#' @returns An object of class `seg_optimal`, a list with the elements:
#'   * `summary`: tibble with the suggested number of clusters per method.
#'   * `plot`: all plots combined.
#'   * `plots`: named list with the individual plots (ggplot objects).
#'   * `results`: named list with the full results of the individual methods.
#'   * `settings`: list of the settings used.
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#' # Quick exploration without the expensive methods
#' optimal <- seg_optimal_clusters(prep, methods = c("wss", "silhouette"))
#' optimal$plot
#' }
#'
#' @export
seg_optimal_clusters <- function(
  x,
  methods = c("wss", "silhouette", "gap_stat", "nbclust"),
  cluster_method = c("kmeans", "hclust", "pam"),
  k_max = 10,
  nstart = 25,
  nboot = 50,
  nstart_gap = 10,
  nbclust_index = "all",
  hc_method = "ward.D2",
  seed = 123,
  verbose = TRUE
) {
  methods <- rlang::arg_match(methods, multiple = TRUE)
  cluster_method <- rlang::arg_match(cluster_method)

  # Validate the input once before running the (possibly slow) methods
  seg_extract_input(x)

  if (cluster_method == "pam" && "nbclust" %in% methods) {
    cli::cli_warn("NbClust does not support {.code cluster_method = \"pam\"}; skipped.")
    methods <- setdiff(methods, "nbclust")
  }

  run_method <- function(method) {
    if (verbose) {
      cli::cli_progress_step("Running {.val {method}}")
    }
    switch(
      method,
      wss = seg_nbclust_wss(
        x,
        cluster_method = cluster_method,
        k_max = k_max,
        nstart = nstart,
        hc_method = hc_method,
        seed = seed
      ),
      silhouette = seg_nbclust_silhouette(
        x,
        cluster_method = cluster_method,
        k_max = k_max,
        nstart = nstart,
        hc_method = hc_method,
        seed = seed
      ),
      gap_stat = seg_nbclust_gap(
        x,
        cluster_method = cluster_method,
        k_max = k_max,
        nboot = nboot,
        nstart = nstart_gap,
        hc_method = hc_method,
        seed = seed
      ),
      nbclust = seg_nbclust_indices(
        x,
        cluster_method = cluster_method,
        k_max = k_max,
        index = nbclust_index,
        hc_method = hc_method,
        seed = seed
      )
    )
  }

  results <- purrr::map(rlang::set_names(methods), run_method)
  if (verbose) {
    cli::cli_progress_done()
  }

  summary_tbl <- purrr::map(results, \(r) {
    tibble::tibble(
      method = r$method,
      optimal_k = r$optimal_k,
      criterion = r$criterion
    )
  }) |>
    purrr::list_rbind()

  plots <- purrr::map(results, "plot")

  out <- structure(
    list(
      summary = summary_tbl,
      plot = do.call(
        see::plots,
        c(unname(plots), list(n_columns = min(2, length(plots))))
      ),
      plots = plots,
      results = results,
      settings = list(
        methods = methods,
        cluster_method = cluster_method,
        k_max = k_max,
        nstart = nstart,
        nboot = nboot,
        nstart_gap = nstart_gap,
        nbclust_index = nbclust_index,
        hc_method = hc_method,
        seed = seed
      )
    ),
    class = c("seg_optimal", "list")
  )

  if (verbose) {
    print(out)
  }

  invisible(out)
}


#' @export
print.seg_optimal <- function(x, ...) {
  s <- x$summary
  cli::cli_h2("Optimal number of clusters ({x$settings$cluster_method})")
  cli::cli_ul(paste0(
    "{.strong ",
    s$method,
    "}: k = ",
    s$optimal_k,
    " {.emph (",
    s$criterion,
    ")}"
  ))

  ks <- s$optimal_k[!is.na(s$optimal_k)]
  if (length(ks) > 0) {
    votes <- table(ks)
    top <- names(votes)[votes == max(votes)]
    cli::cli_text(
      "Most frequent suggestion: k = {.strong {top}} ({max(votes)} of {length(ks)} method{?s}). See the plots in {.code $plot}."
    )
  }
  invisible(x)
}


#' Optimal number of clusters: Elbow method (WSS)
#'
#' Computes the total within-cluster sum of squares (WSS) for 1 to `k_max`
#' clusters using [factoextra::fviz_nbclust()]. The optimal number of
#' clusters is located at the "elbow" (bend) of the curve, where adding
#' another cluster no longer reduces the WSS much.
#'
#' @details
#' ## How it works
#'
#' For each k, the respondents are clustered and the total within-cluster sum
#' of squares is computed:
#' \deqn{WSS(k) = \sum_{c=1}^{k} \sum_{i \in C_c} d(x_i, \mu_c)^2}{WSS(k) = sum over clusters c of sum over respondents i in c of d(x_i, mu_c)^2}
#' where \eqn{\mu_c}{mu_c} is the center of cluster \eqn{c}. WSS measures the
#' compactness of the clusters: the smaller, the more similar the respondents
#' within the clusters. If a distance matrix other than Euclidean was computed
#' by [seg_prep_data()], it is used to compute the WSS.
#'
#' Since WSS always decreases when clusters are added (with k = n respondents
#' it is 0), its minimum is meaningless. Instead, the elbow method looks for
#' the k after which adding clusters brings only small improvements. Here, the
#' elbow is determined automatically as the point with the largest distance
#' below the straight line between the first and the last point of the
#' (normalized) curve.
#'
#' ## Interpretation
#'
#' * A sharp bend indicates a natural number of clusters.
#' * A smooth curve without a clear bend, which is common for survey data,
#'   indicates that the data has no clear cluster structure. The automatically
#'   determined elbow is then only a rough guide and may change with `k_max`.
#' * The elbow method is the most widely used but also the most subjective
#'   method. Combine it with the other methods of [seg_optimal_clusters()].
#'
#' @inheritParams seg_optimal_clusters
#'
#' @returns A list with the elements `method`, `optimal_k`, `criterion`,
#'   `values` (tibble with the criterion per k) and `plot` (ggplot object).
#'
#' @family optimal number of clusters
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
#' seg_nbclust_wss(prep)$plot
#' }
#'
#' @export
seg_nbclust_wss <- function(
  x,
  cluster_method = c("kmeans", "hclust", "pam"),
  k_max = 10,
  nstart = 25,
  hc_method = "ward.D2",
  seed = 123
) {
  seg_nbclust_fviz(
    x,
    method = "wss",
    cluster_method = rlang::arg_match(cluster_method),
    k_max = k_max,
    nstart = nstart,
    hc_method = hc_method,
    seed = seed
  )
}


#' Optimal number of clusters: Average silhouette method
#'
#' Computes the average silhouette width for 2 to `k_max` clusters using
#' [factoextra::fviz_nbclust()]. The silhouette width measures how well each
#' respondent fits into its own cluster compared to the nearest other cluster.
#' The optimal number of clusters maximizes the average silhouette width.
#'
#' @details
#' ## How it works
#'
#' For each k, the respondents are clustered. For each respondent \eqn{i},
#' \eqn{a_i} is the average distance to the other members of its own cluster
#' (compactness) and \eqn{b_i} the average distance to the members of the
#' nearest other cluster (separation). The silhouette width of the respondent
#' is
#' \deqn{s_i = \frac{b_i - a_i}{\max(a_i, b_i)}}{s_i = (b_i - a_i) / max(a_i, b_i)}
#' and the average silhouette width is the mean of \eqn{s_i} over all
#' respondents. The silhouette is not defined for k = 1, so the method cannot
#' indicate that there are no clusters. The distance matrix computed by
#' [seg_prep_data()] is used if available.
#'
#' ## Interpretation
#'
#' Values of \eqn{s_i} close to 1 indicate respondents that are well
#' clustered, values around 0 respondents between two clusters, and negative
#' values respondents that are probably in the wrong cluster. For the average
#' silhouette width, Kaufman and Rousseeuw (1990) suggest:
#'
#' * above 0.70: strong structure,
#' * 0.51 to 0.70: reasonable structure,
#' * 0.26 to 0.50: weak structure, could be artificial,
#' * 0.25 or below: no substantial structure.
#'
#' Attitudinal survey data mostly falls in the last category (values of 0.1
#' to 0.25 are common); segmentations can still be useful, but the segments
#' then partition a continuum rather than separating natural groups. The
#' silhouette method often favors k = 2; also look at the second-best k.
#'
#' @references Kaufman, L. and Rousseeuw, P. J. (1990). *Finding Groups in
#'   Data: An Introduction to Cluster Analysis*. Wiley.
#'   \doi{10.1002/9780470316801}
#'
#' @inheritParams seg_optimal_clusters
#'
#' @inherit seg_nbclust_wss return
#'
#' @family optimal number of clusters
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
#' seg_nbclust_silhouette(prep)$plot
#' }
#'
#' @export
seg_nbclust_silhouette <- function(
  x,
  cluster_method = c("kmeans", "hclust", "pam"),
  k_max = 10,
  nstart = 25,
  hc_method = "ward.D2",
  seed = 123
) {
  seg_nbclust_fviz(
    x,
    method = "silhouette",
    cluster_method = rlang::arg_match(cluster_method),
    k_max = k_max,
    nstart = nstart,
    hc_method = hc_method,
    seed = seed
  )
}


#' Optimal number of clusters: Gap statistic
#'
#' Computes the gap statistic for 1 to `k_max` clusters using
#' [cluster::clusGap()] and plots it with [factoextra::fviz_gap_stat()]. The
#' gap statistic compares the within-cluster dispersion of the data with the
#' one expected under a reference distribution without clusters.
#'
#' @details
#' ## How it works
#'
#' For each k, the data is clustered and the (pooled) within-cluster
#' dispersion \eqn{W_k} is computed. The same is done for `nboot` reference
#' datasets without cluster structure, generated uniformly within the range of
#' the data (along its principal components). The gap statistic is the
#' difference between the expected and the observed log dispersion:
#' \deqn{Gap(k) = E^*[\log W_k] - \log W_k}{Gap(k) = E*[log(W_k)] - log(W_k)}
#' where \eqn{E^*}{E*} is the average over the reference datasets. Its standard
#' error \eqn{s_k} is derived from the standard deviation of the reference
#' values. A large gap means that the clustering structure is far from what is
#' expected for random data.
#'
#' The optimal k is the smallest k whose gap is within one standard error of
#' the first local maximum (`method = "firstSEmax"` in [cluster::maxSE()],
#' also used for the plot). In contrast to the silhouette method, the gap
#' statistic can also suggest k = 1, i.e. that the data has no cluster
#' structure.
#'
#' ## Interpretation
#'
#' * A clear peak indicates a natural number of clusters.
#' * A curve that keeps increasing (common for survey data with many
#'   variables) indicates that more clusters always fit better than random
#'   data; the suggested k then marks where the curve flattens and is often
#'   large. Treat it as an upper bound rather than a recommendation.
#' * The result depends on the random reference datasets; with few bootstrap
#'   samples (`nboot`), the standard errors are larger.
#'
#' The gap statistic is the most time-consuming method, as the clustering is
#' repeated `nboot + 1` times for each k. Note that [cluster::clusGap()]
#' always uses Euclidean distances.
#'
#' @references Tibshirani, R., Walther, G. and Hastie, T. (2001). Estimating
#'   the number of clusters in a data set via the gap statistic. *Journal of
#'   the Royal Statistical Society: Series B, 63*(2), 411-423.
#'   \doi{10.1111/1467-9868.00293}
#'
#' @inheritParams seg_optimal_clusters
#' @param nstart Number of random starts for k-means. Defaults to 10 (lower
#'   than for the other methods to keep the computation time moderate).
#'
#' @returns A list with the elements `method`, `optimal_k`, `criterion`,
#'   `values` (tibble with the gap statistic and its standard error per k),
#'   `plot` (ggplot object) and `gap` (the [cluster::clusGap()] output).
#'
#' @family optimal number of clusters
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
#' seg_nbclust_gap(prep, nboot = 20)$plot
#' }
#'
#' @export
seg_nbclust_gap <- function(
  x,
  cluster_method = c("kmeans", "hclust", "pam"),
  k_max = 10,
  nboot = 50,
  nstart = 10,
  hc_method = "ward.D2",
  seed = 123
) {
  cluster_method <- rlang::arg_match(cluster_method)
  input <- seg_extract_input(x)
  seg_check_k_max(k_max, input$data)

  fun <- seg_cluster_fun(cluster_method, input$distance, nstart, hc_method)

  gap <- seg_with_seed(seed, {
    cluster::clusGap(
      as.matrix(input$data),
      FUNcluster = fun,
      K.max = k_max,
      B = nboot,
      verbose = FALSE
    )
  })

  tab <- tibble::as_tibble(gap$Tab)
  optimal_k <- cluster::maxSE(tab$gap, tab$SE.sim, method = "firstSEmax")

  plot <- factoextra::fviz_gap_stat(
    gap,
    linecolor = yougov_colors[["Red 1"]],
    maxSE = list(method = "firstSEmax", SE.factor = 1)
  ) +
    ggplot2::labs(
      title = "Gap statistic",
      subtitle = paste0("Optimal k = ", optimal_k, " | ", nboot, " bootstrap samples")
    )

  list(
    method = "gap_stat",
    optimal_k = as.integer(optimal_k),
    criterion = "first gap within 1 SE of the first local maximum",
    values = tibble::tibble(k = seq_len(k_max), gap = tab$gap, se = tab$SE.sim),
    plot = plot,
    gap = gap
  )
}


#' Optimal number of clusters: NbClust indices
#'
#' Computes up to 26 indices for determining the number of clusters with
#' [NbClust::NbClust()] and visualizes the number of indices that support each
#' k with [factoextra::fviz_nbclust()]. The optimal number of clusters is the
#' one supported by most indices (majority rule).
#'
#' @details
#' ## How it works
#'
#' The NbClust package implements many of the indices proposed in the
#' literature to determine the number of clusters. For each k from `k_min` to
#' `k_max`, the data is clustered and every index is computed. Each index then
#' proposes its best k according to its own rule (e.g. maximum, minimum or
#' largest change), and the proposals are counted. The default `index = "all"`
#' computes 26 indices: KL, CH, Hartigan, CCC, Scott, Marriot, TrCovW,
#' TraceW, Friedman, Rubin, Cindex, DB, Silhouette, Duda, PseudoT2, Beale,
#' Ratkowsky, Ball, PtBiserial, Frey, McClain, Dunn, Hubert, SDindex, Dindex
#' and SDbw. `"alllong"` adds Gap, Gamma, Gplus and Tau (much slower).
#'
#' Most indices compare the dispersion *within* clusters with the dispersion
#' *between* clusters, in different ways. Examples:
#'
#' * **CH** (Calinski-Harabasz, higher is better): ratio of the between- to
#'   the within-cluster dispersion, corrected for the number of clusters.
#' * **DB** (Davies-Bouldin, lower is better): average similarity of each
#'   cluster with its most similar other cluster.
#' * **Silhouette** (higher is better): see [seg_nbclust_silhouette()].
#' * **Duda**, **PseudoT2**, **Beale**: test whether a cluster should be
#'   split into two; these can also suggest k = 1 (no clusters).
#'
#' See Charrad et al. (2014) for the definitions of all indices.
#'
#' The Hubert and D index are graphical methods without a direct proposal
#' (shown as k = 0 in the plot); some indices can fail for a given dataset.
#' Both are not counted, so the number of votes is often lower than 26.
#' Proposals outside `k_min` to `k_max` (such as k = 1) are not counted for
#' the optimal k either, but are shown in the plot. The console output and
#' the plots that NbClust produces itself are suppressed.
#'
#' With a single `index` (e.g. `"ch"` or `"silhouette"`), there is no vote:
#' the values of the index per k are plotted instead, and the optimal k is the
#' best value of that index.
#'
#' ## Interpretation
#'
#' * A k supported by a clear majority of the indices is a strong candidate.
#' * Votes spread over several values of k (common for survey data) indicate
#'   that the data has no clear cluster structure; consider all values of k
#'   with many votes as candidates.
#' * Many indices are biased towards small numbers of clusters, so k = 2 often
#'   receives many votes. Also look at the second most supported k.
#'
#' @references Charrad, M., Ghazzali, N., Boiteau, V. and Niknafs, A. (2014).
#'   NbClust: An R Package for Determining the Relevant Number of Clusters in
#'   a Data Set. *Journal of Statistical Software, 61*(6), 1-36.
#'   \doi{10.18637/jss.v061.i06}
#'
#' @inheritParams seg_optimal_clusters
#' @param cluster_method `"kmeans"` (default) or `"hclust"`. NbClust does not
#'   support PAM.
#' @param k_min Minimum number of clusters to consider. Defaults to 2.
#' @param index Index computed by NbClust. Defaults to `"all"` (26 indices,
#'   majority vote). A single index (e.g. `"silhouette"` or `"ch"`) can be
#'   given as well; its values per k are plotted then. See
#'   [NbClust::NbClust()] for the options.
#'
#' @returns A list with the elements `method`, `optimal_k`, `criterion`,
#'   `values` (tibble with the number of indices supporting each k, or with the
#'   index values per k for a single index), `plot` (ggplot object) and
#'   `nbclust` (the [NbClust::NbClust()] output).
#'
#' @family optimal number of clusters
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
#' seg_nbclust_indices(prep)$plot
#' }
#'
#' @export
seg_nbclust_indices <- function(
  x,
  cluster_method = c("kmeans", "hclust"),
  k_min = 2,
  k_max = 10,
  index = "all",
  hc_method = "ward.D2",
  seed = 123
) {
  cluster_method <- rlang::arg_match(cluster_method)
  input <- seg_extract_input(x)
  seg_check_k_max(k_max, input$data)

  nb_method <- if (cluster_method == "kmeans") "kmeans" else hc_method

  # NbClust supports the stats::dist() measures; otherwise pass the
  # dissimilarity matrix
  nb_distances <- c(
    "euclidean",
    "maximum",
    "manhattan",
    "canberra",
    "binary",
    "minkowski"
  )
  if (input$distance %in% nb_distances) {
    nb_distance <- input$distance
    nb_diss <- NULL
  } else {
    nb_distance <- NULL
    nb_diss <- input$dist %||%
      seg_distance(
        input$data,
        distance = input$distance,
        distance_engine = input$distance_engine,
        daisy_args = input$daisy_args
      )
  }

  # NbClust prints a lot and draws plots for the Hubert and D index:
  # send both to nowhere
  old_dev <- grDevices::dev.cur()
  grDevices::pdf(NULL)
  on.exit(
    {
      grDevices::dev.off()
      if (old_dev > 1) grDevices::dev.set(old_dev)
    },
    add = TRUE
  )

  nb <- NULL
  utils::capture.output({
    nb <- suppressWarnings(seg_with_seed(seed, {
      NbClust::NbClust(
        data = as.matrix(input$data),
        diss = nb_diss,
        distance = nb_distance,
        min.nc = k_min,
        max.nc = k_max,
        method = nb_method,
        index = index
      )
    }))
  })

  col <- yougov_colors[["Red 1"]]

  # A single index: no vote, plot the index values per k instead
  # (factoextra::fviz_nbclust() returns NULL in that case)
  if (!is.matrix(nb$Best.nc)) {
    optimal_k <- as.integer(nb$Best.nc[["Number_clusters"]])
    values <- tibble::tibble(
      k = as.integer(names(nb$All.index)),
      value = unname(nb$All.index)
    )

    plot <- ggplot2::ggplot(
      values,
      ggplot2::aes(x = .data$k, y = .data$value)
    ) +
      ggplot2::geom_line(color = col) +
      ggplot2::geom_point(color = col) +
      ggplot2::geom_vline(xintercept = optimal_k, linetype = 2, color = col) +
      ggplot2::scale_x_continuous(breaks = values$k) +
      ggplot2::labs(
        title = paste0("NbClust index: ", index),
        subtitle = paste0("Optimal k = ", optimal_k),
        x = "Number of clusters k",
        y = "Index value"
      ) +
      ggplot2::theme_classic()

    return(list(
      method = "nbclust",
      optimal_k = optimal_k,
      criterion = paste0("best value of the NbClust index \"", index, "\""),
      values = values,
      plot = plot,
      nbclust = nb
    ))
  }

  best <- nb$Best.nc["Number_clusters", ]
  best <- best[!is.na(best) & best >= k_min & best <= k_max]
  votes <- table(factor(best, levels = k_min:k_max))
  optimal_k <- as.integer(names(votes)[which.max(votes)])

  plot <- factoextra::fviz_nbclust(
    nb,
    barfill = yougov_colors[["Red 1"]],
    barcolor = yougov_colors[["Red 1"]],
    print.summary = FALSE
  ) +
    ggplot2::labs(
      title = "NbClust indices",
      subtitle = paste0(
        "Optimal k = ",
        optimal_k,
        " (",
        max(votes),
        " of ",
        length(best),
        " indices)"
      )
    )

  list(
    method = "nbclust",
    optimal_k = optimal_k,
    criterion = paste0(
      "majority of ",
      length(best),
      " NbClust indices (",
      max(votes),
      " votes)"
    ),
    values = tibble::tibble(
      k = as.integer(names(votes)),
      n_indices = as.integer(votes)
    ),
    plot = plot,
    nbclust = nb
  )
}


# ---- Choosing the best clustering algorithm ----------------------------------

# Validation measures of clValid: direction and description
seg_clvalid_measures <- tibble::tribble(
  ~measure, ~validation, ~better, ~description,
  "Connectivity", "internal", "lower", "Connectivity (0 to Inf)",
  "Dunn", "internal", "higher", "Dunn index (0 to Inf)",
  "Silhouette", "internal", "higher", "Average silhouette width (-1 to 1)",
  "APN", "stability", "lower", "Average proportion of non-overlap (0 to 1)",
  "AD", "stability", "lower", "Average distance (0 to Inf)",
  "ADM", "stability", "lower", "Average distance between means (0 to Inf)",
  "FOM", "stability", "lower", "Figure of merit (0 to Inf)"
)

#' Compare clustering algorithms
#'
#' Compares several clustering algorithms and numbers of clusters with the
#' [clValid][clValid::clValid()] package, following the approach described by
#' [datanovia](https://www.datanovia.com/learn/machine-learning/clustering/choosing-best-algorithm).
#' All results are visualized with ggplot2.
#'
#' @details
#' Each algorithm is run for each number of clusters in `k`, and every
#' solution is scored with several validation measures. Two families of
#' measures are available.
#'
#' ## Internal measures
#'
#' Internal measures (`validation = "internal"`, fast) use only the data and
#' the clustering itself. They assess the two properties a good partition
#' should have: *compactness* (respondents in the same cluster are similar)
#' and *separation* (respondents in different clusters are dissimilar).
#'
#' * **Connectivity** (range 0 to Inf, lower is better). For each respondent
#'   \eqn{i}, the `neighb_size` nearest neighbors are determined. If the
#'   \eqn{j}-th nearest neighbor of \eqn{i} is not in the same cluster as
#'   \eqn{i}, a penalty of \eqn{1/j} is added, so that close neighbors in
#'   another cluster are penalized more than distant ones. The connectivity is
#'   the sum of these penalties over all respondents.
#'   *Rationale:* neighbors should end up in the same cluster
#'   (connectedness). *When to use:* to check that the clusters are coherent
#'   regions of the data rather than arbitrary cuts. As more clusters create
#'   more boundaries, connectivity almost always increases with k and
#'   therefore favors few clusters; compare algorithms at the same k rather
#'   than across k. The result depends on `neighb_size`.
#'
#' * **Silhouette width** (range -1 to 1, higher is better). For each
#'   respondent \eqn{i}, \eqn{a_i} is the average distance to the other
#'   members of its own cluster and \eqn{b_i} the average distance to the
#'   members of the nearest other cluster. The silhouette is
#'   \eqn{s_i = (b_i - a_i) / \max(a_i, b_i)}{s_i = (b_i - a_i) / max(a_i, b_i)};
#'   the measure is its average over
#'   all respondents. Values close to 1 indicate well clustered respondents,
#'   values around 0 respondents between two clusters, and negative values
#'   respondents that are probably in the wrong cluster.
#'   *Rationale:* combines compactness and separation in a single,
#'   easy-to-interpret number. *When to use:* the most widely used general
#'   purpose measure and a good default for comparing solutions across
#'   algorithms and k. It tends to favor few, roughly spherical clusters.
#'   For attitudinal survey data, values of 0.1 to 0.25 are common.
#'
#' * **Dunn index** (range 0 to Inf, higher is better). The smallest distance
#'   between two respondents in different clusters, divided by the largest
#'   distance between two respondents in the same cluster (the largest
#'   cluster diameter).
#'   *Rationale:* relates the worst-case separation to the worst-case
#'   compactness. *When to use:* when well separated clusters are expected.
#'   As it relies on a single minimum and a single maximum, it is very
#'   sensitive to outliers and noise; for survey data it is best used as a
#'   secondary measure.
#'
#' ## Stability measures
#'
#' Stability measures (`validation = "stability"`, slow) compare the
#' clustering of the full data with the clusterings obtained after removing
#' one clustering variable at a time, averaged over all variables. A stable
#' solution should not change much when a single variable is left out. All
#' stability measures are better when lower.
#'
#' * **APN** (average proportion of non-overlap, range 0 to 1). The average
#'   proportion of respondents that are *not* placed in the same cluster in
#'   the full and in the reduced data.
#'   *Rationale:* stability of the cluster assignment of individual
#'   respondents. *When to use:* to make sure that the segment membership
#'   does not depend on a single item, e.g. if the item battery might be
#'   shortened in later waves or if a typing tool will be built.
#'
#' * **AD** (average distance, range 0 to Inf). The average distance between
#'   respondents placed in the same cluster in both the full and the reduced
#'   data.
#'   *Rationale:* combines stability and compactness. *When to use:* together
#'   with APN. Like any within-cluster distance, it decreases with more
#'   clusters and thus favors larger k.
#'
#' * **ADM** (average distance between means, range 0 to Inf). The average
#'   distance between the cluster centers of respondents placed in the same
#'   cluster in the full and the reduced data.
#'   *Rationale:* stability of the cluster *profiles* (centers) rather than of
#'   individual assignments. *When to use:* when the segment profiles (e.g.
#'   for personas or reporting) should be robust to the selection of items.
#'
#' * **FOM** (figure of merit, range 0 to Inf). The average within-cluster
#'   variance of the left-out variable, when the clustering is based on the
#'   remaining variables only.
#'   *Rationale:* measures how well the clusters predict a variable that was
#'   not used to build them. *When to use:* to assess whether the segments
#'   reflect a general structure in the data rather than a few items. It
#'   decreases with more clusters and thus favors larger k.
#'
#' ## Choosing an algorithm
#'
#' No single measure is decisive, and the measures often disagree, as they
#' value different properties. Prefer algorithms that rank well on several
#' measures at the same k, use the internal measures for a quick screening and
#' add the stability measures for the short list. Measures that mechanically
#' improve with k (connectivity favors few, AD and FOM favor many clusters)
#' should be read as curves rather than by their optimum. Finally, combine the
#' results with [seg_optimal_clusters()], the cluster sizes and the
#' interpretability of the segments.
#'
#' @section Cluster sizes:
#' The validation measures do not consider the size of the clusters. Linkage
#' methods such as `"average"` or `"single"` often produce one very large
#' cluster and a few tiny ones, which can score well on connectivity and Dunn
#' but is useless as a segmentation. The share of the smallest cluster is
#' therefore reported for each solution (`$cluster_sizes`) and shown in the
#' plots; solutions below `min_cluster_share` are flagged.
#'
#' @param x The output of [seg_prep_data()] (recommended), or a data frame or
#'   numeric matrix with already prepared clustering variables (no missing
#'   values).
#' @param cl_methods Clustering algorithms to compare. Any of
#'   `"hierarchical"` ([stats::hclust()]), `"kmeans"` ([stats::kmeans()]),
#'   `"pam"` ([cluster::pam()]), `"diana"` ([cluster::diana()]) and `"clara"`
#'   ([cluster::clara()]). Defaults to `c("hierarchical", "kmeans", "pam")`.
#' @param k Numbers of clusters to compare. Defaults to `2:6`.
#' @param validation `"internal"` (default), `"stability"` or both. Stability
#'   measures re-run all clusterings once per clustering variable and are
#'   therefore much slower (about 10 times for 20 variables).
#' @param linkage Agglomeration method for hierarchical clustering: one of
#'   `"ward"`, `"complete"`, `"average"` or `"single"` (the options supported by
#'   clValid). Note that clValid also uses the hierarchical solution to
#'   initialize k-means. Defaults to `"ward"` (clValid's default `"average"`
#'   tends to produce one large cluster and a few tiny ones). clValid's
#'   `"ward"` corresponds to `"ward.D"` in [stats::hclust()], a slightly
#'   different variant than the `"ward.D2"` used in [seg_optimal_clusters()].
#' @param metric Distance metric used by clValid: `"euclidean"`,
#'   `"manhattan"` or `"correlation"`. If `NULL` (default), it is taken from
#'   the [seg_prep_data()] output where possible (`"pearson"` becomes
#'   `"correlation"`), otherwise `"euclidean"`.
#' @param neighb_size Number of neighbors considered for the connectivity
#'   measure. Defaults to 10.
#' @param min_cluster_share Solutions whose smallest cluster contains a lower
#'   share of respondents are flagged. Defaults to 0.05 (5%).
#' @param seed Random seed (only relevant for `"clara"`). The global random
#'   seed is left untouched. Defaults to 123.
#' @param verbose Logical. Whether to print the results. Defaults to `TRUE`.
#'
#' @returns An object of class `seg_algorithms`, a list with the elements:
#'   * `measures`: tibble (long format) with all validation measures per
#'     algorithm and number of clusters, incl. the share of the smallest
#'     cluster.
#'   * `optimal`: tibble with the best algorithm and number of clusters per
#'     measure ([clValid::optimalScores()]), with and without the solutions
#'     below `min_cluster_share`.
#'   * `cluster_sizes`: tibble with the cluster sizes of each solution.
#'   * `plot`: all measures in one faceted plot.
#'   * `plots`: named list with one plot per measure.
#'   * `clvalid`: list with the [clValid::clValid()] output(s).
#'   * `settings`: list of the settings used.
#'
#' @references Brock, G., Pihur, V., Datta, S. and Datta, S. (2008). clValid:
#'   An R Package for Cluster Validation. *Journal of Statistical Software,
#'   25*(4), 1-22. \doi{10.18637/jss.v025.i04}
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#' algorithms <- seg_compare_algorithms(prep)
#' algorithms$plot
#' }
#'
#' @export
seg_compare_algorithms <- function(
  x,
  cl_methods = c("hierarchical", "kmeans", "pam"),
  k = 2:6,
  validation = "internal",
  linkage = c("ward", "complete", "average", "single"),
  metric = NULL,
  neighb_size = 10,
  min_cluster_share = 0.05,
  seed = 123,
  verbose = TRUE
) {
  # ---- 1. Check arguments and get data ----

  cl_methods <- rlang::arg_match(
    cl_methods,
    values = c("hierarchical", "kmeans", "pam", "diana", "clara"),
    multiple = TRUE
  )
  validation <- rlang::arg_match(
    validation,
    values = c("internal", "stability"),
    multiple = TRUE
  )
  linkage <- rlang::arg_match(linkage)

  input <- seg_extract_input(x)
  data <- as.matrix(input$data)
  rownames(data) <- seq_len(nrow(data))

  if (
    !is.numeric(k) ||
      any(k != round(k)) ||
      any(k < 2) ||
      any(k >= nrow(data))
  ) {
    cli::cli_abort(
      "{.arg k} must contain integers between 2 and the number of respondents - 1."
    )
  }
  k <- sort(unique(as.integer(k)))

  if (is.null(metric)) {
    metric <- switch(
      input$distance,
      euclidean = "euclidean",
      manhattan = "manhattan",
      pearson = "correlation",
      {
        cli::cli_inform(c(
          "i" = "{.val {input$distance}} distance is not available in clValid; {.val euclidean} is used."
        ))
        "euclidean"
      }
    )
  }
  metric <- rlang::arg_match(
    metric,
    values = c("euclidean", "manhattan", "correlation")
  )

  # ---- 2. Run clValid ----

  run_clvalid <- function(v) {
    withCallingHandlers(
      seg_with_seed(seed, {
        clValid::clValid(
          data,
          nClust = k,
          clMethods = cl_methods,
          validation = v,
          maxitems = nrow(data) + 1,
          metric = metric,
          method = linkage,
          neighbSize = neighb_size
        )
      }),
      # k-means (initialized by clValid) may need more than 10 iterations;
      # the solutions are still usable
      warning = \(w) {
        if (grepl("did not converge", conditionMessage(w))) {
          invokeRestart("muffleWarning")
        }
      },
      # hclust() notes that "ward" has been renamed to "ward.D" (documented)
      message = \(m) {
        if (grepl("has been renamed", conditionMessage(m))) {
          invokeRestart("muffleMessage")
        }
      }
    )
  }

  clvalid <- purrr::map(rlang::set_names(validation), run_clvalid)

  # ---- 3. Cluster sizes ----

  cluster_sizes <- seg_clvalid_cluster_sizes(clvalid[[1]], cl_methods, k)

  smallest <- cluster_sizes |>
    dplyr::summarise(
      value = min(.data$share),
      .by = c("method", "k")
    ) |>
    dplyr::mutate(measure = "Smallest cluster")

  # ---- 4. Measures (long format) ----

  measures <- purrr::map(clvalid, \(cv) {
    # 3-dimensional array: measure x k x method
    m <- clValid::measures(cv)
    tibble::as_tibble(as.data.frame.table(
      m,
      responseName = "value",
      stringsAsFactors = FALSE
    )) |>
      rlang::set_names(c("measure", "k", "method", "value")) |>
      dplyr::mutate(k = as.integer(.data$k))
  }) |>
    purrr::list_rbind() |>
    dplyr::bind_rows(smallest) |>
    dplyr::left_join(
      smallest |> dplyr::select("method", "k", smallest_share = "value"),
      by = c("method", "k")
    ) |>
    dplyr::left_join(
      seg_clvalid_measures |> dplyr::select("measure", "validation", "better"),
      by = "measure"
    ) |>
    dplyr::mutate(
      validation = dplyr::coalesce(.data$validation, "cluster size"),
      better = dplyr::coalesce(.data$better, "higher"),
      too_small = .data$smallest_share < min_cluster_share,
      method = factor(.data$method, levels = cl_methods),
      measure = factor(
        .data$measure,
        levels = c(seg_clvalid_measures$measure, "Smallest cluster")
      )
    ) |>
    dplyr::filter(!is.na(.data$value)) |>
    dplyr::select(
      "validation",
      "measure",
      "better",
      "method",
      "k",
      "value",
      "smallest_share",
      "too_small"
    ) |>
    dplyr::arrange(.data$measure, .data$method, .data$k)

  # ---- 5. Optimal scores ----

  pick_best <- function(d) {
    d |>
      dplyr::slice(
        if (d$better[1] == "lower") which.min(d$value) else which.max(d$value)
      )
  }

  optimal_all <- measures |>
    dplyr::filter(.data$measure != "Smallest cluster") |>
    dplyr::group_by(.data$measure) |>
    dplyr::group_modify(\(d, g) pick_best(d)) |>
    dplyr::ungroup()

  optimal_valid <- measures |>
    dplyr::filter(.data$measure != "Smallest cluster", !.data$too_small) |>
    dplyr::group_by(.data$measure) |>
    dplyr::group_modify(\(d, g) pick_best(d)) |>
    dplyr::ungroup()

  optimal <- optimal_all |>
    dplyr::select(
      "validation",
      "measure",
      "better",
      method = "method",
      k = "k",
      score = "value",
      smallest_share = "smallest_share"
    ) |>
    dplyr::left_join(
      optimal_valid |>
        dplyr::select(
          "measure",
          method_valid = "method",
          k_valid = "k",
          score_valid = "value"
        ),
      by = "measure"
    )

  # ---- 6. Plots ----

  plots <- purrr::map(
    rlang::set_names(levels(droplevels(measures$measure))),
    \(ms) {
      seg_clvalid_plot(
        measures |> dplyr::filter(.data$measure == ms),
        min_cluster_share = min_cluster_share,
        facet = FALSE
      )
    }
  )
  plot <- seg_clvalid_plot(
    measures,
    min_cluster_share = min_cluster_share,
    facet = TRUE
  )

  # ---- 7. Output ----

  out <- structure(
    list(
      measures = measures,
      optimal = optimal,
      cluster_sizes = cluster_sizes,
      plot = plot,
      plots = plots,
      clvalid = clvalid,
      settings = list(
        cl_methods = cl_methods,
        k = k,
        validation = validation,
        linkage = linkage,
        metric = metric,
        neighb_size = neighb_size,
        min_cluster_share = min_cluster_share,
        seed = seed
      )
    ),
    class = c("seg_algorithms", "list")
  )

  if (verbose) {
    print(out)
  }

  invisible(out)
}


#' @export
print.seg_algorithms <- function(x, ...) {
  o <- x$optimal
  s <- x$settings

  cli::cli_h2("Comparison of clustering algorithms")
  cli::cli_text(
    "Algorithms: {.val {s$cl_methods}} | k = {min(s$k)} to {max(s$k)} | linkage: {.val {s$linkage}} | metric: {.val {s$metric}}"
  )

  lines <- purrr::pmap_chr(o, function(...) {
    r <- list(...)
    txt <- paste0(
      "{.strong ", r$measure, "} (", r$better, " = better): ",
      r$method, ", k = ", r$k,
      " (smallest cluster: ", round(100 * r$smallest_share), "%)"
    )
    if (
      !is.na(r$method_valid) &&
        (r$method_valid != as.character(r$method) || r$k_valid != r$k)
    ) {
      txt <- paste0(
        txt,
        " {.emph | without too small clusters: ",
        r$method_valid, ", k = ", r$k_valid, "}"
      )
    }
    txt
  })
  cli::cli_ul(lines)

  n_small <- x$measures |>
    dplyr::filter(.data$measure == "Smallest cluster", .data$too_small) |>
    nrow()
  if (n_small > 0) {
    cli::cli_alert_warning(
      "{n_small} solution{?s} with a cluster below {round(100 * s$min_cluster_share)}% of respondents (see {.code $cluster_sizes})."
    )
  }
  cli::cli_text("{.emph See the plots in {.code $plot}.}")
  invisible(x)
}


# ---- Internal helpers --------------------------------------------------------

# Cluster sizes of all solutions stored in a clValid object
seg_clvalid_cluster_sizes <- function(cv, cl_methods, k) {
  objs <- cv@clusterObjs

  get_clusters <- function(method, kk) {
    obj <- objs[[method]]
    switch(
      method,
      hierarchical = stats::cutree(obj, kk),
      diana = stats::cutree(stats::as.hclust(obj), kk),
      kmeans = obj[[as.character(kk)]]$cluster,
      pam = obj[[as.character(kk)]]$clustering,
      clara = obj[[as.character(kk)]]$clustering
    )
  }

  grid <- expand.grid(k = k, method = cl_methods, stringsAsFactors = FALSE)

  purrr::map2(grid$method, grid$k, \(m, kk) {
    cl <- get_clusters(m, kk)
    tab <- table(cl)
    tibble::tibble(
      method = m,
      k = as.integer(kk),
      cluster = as.integer(names(tab)),
      n = as.integer(tab),
      share = as.numeric(tab) / length(cl)
    )
  }) |>
    purrr::list_rbind()
}

# Line plot of clValid measures by algorithm and number of clusters
seg_clvalid_plot <- function(
  measures,
  min_cluster_share,
  facet,
  color_name = "Algorithm"
) {
  measures <- measures |>
    dplyr::mutate(
      label = paste0(.data$measure, " (", .data$better, " = better)"),
      label = factor(.data$label, levels = unique(.data$label))
    )

  p <- ggplot2::ggplot(
    measures,
    ggplot2::aes(
      x = .data$k,
      y = .data$value,
      color = .data$method,
      group = .data$method
    )
  ) +
    ggplot2::geom_line() +
    ggplot2::geom_point(
      ggplot2::aes(shape = .data$too_small),
      size = 2
    ) +
    ggplot2::scale_color_manual(values = yougov_palette, name = color_name) +
    ggplot2::scale_shape_manual(
      values = c(`FALSE` = 16, `TRUE` = 4),
      labels = c(
        `FALSE` = "ok",
        `TRUE` = paste0("< ", round(100 * min_cluster_share), "%")
      ),
      name = "Smallest cluster",
      drop = FALSE
    ) +
    ggplot2::scale_x_continuous(breaks = unique(measures$k)) +
    ggplot2::labs(x = "Number of clusters k", y = NULL) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      legend.position = "bottom",
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold", hjust = 0)
    )

  if ("Smallest cluster" %in% measures$measure) {
    p <- p +
      ggplot2::geom_hline(
        data = measures |>
          dplyr::filter(.data$measure == "Smallest cluster") |>
          dplyr::distinct(.data$label),
        ggplot2::aes(yintercept = min_cluster_share),
        linetype = 2,
        color = "grey50"
      )
  }

  if (facet) {
    p + ggplot2::facet_wrap(ggplot2::vars(.data$label), scales = "free_y")
  } else {
    p + ggplot2::labs(title = as.character(measures$label[1]))
  }
}

# WSS and silhouette via factoextra::fviz_nbclust()
seg_nbclust_fviz <- function(
  x,
  method,
  cluster_method,
  k_max,
  nstart,
  hc_method,
  seed
) {
  input <- seg_extract_input(x)
  seg_check_k_max(k_max, input$data)

  fun <- seg_cluster_fun(cluster_method, input$distance, nstart, hc_method)

  # Evaluate the solutions with the chosen distance measure
  diss <- input$dist
  if (is.null(diss) && input$distance != "euclidean") {
    diss <- seg_distance(
      input$data,
      distance = input$distance,
      distance_engine = input$distance_engine,
      daisy_args = input$daisy_args
    )
  }

  col <- yougov_colors[["Red 1"]]
  fviz_args <- list(
    x = as.data.frame(input$data),
    FUNcluster = fun,
    method = method,
    diss = diss,
    k.max = k_max,
    linecolor = col,
    barfill = col,
    barcolor = col,
    verbose = FALSE
  )
  # `mark_optimal` only exists in newer factoextra versions (>= 2.1); in older
  # versions it would be passed on to FUNcluster and cause an error. The
  # optimal k is marked below in any case.
  if ("mark_optimal" %in% names(formals(factoextra::fviz_nbclust))) {
    fviz_args$mark_optimal <- FALSE
  }

  plot <- seg_with_seed(seed, {
    do.call(factoextra::fviz_nbclust, fviz_args)
  })

  values <- tibble::tibble(
    k = as.integer(as.character(plot$data$clusters)),
    value = plot$data$y
  )

  if (method == "wss") {
    optimal_k <- seg_elbow(values$k, values$value)
    criterion <- "elbow of the within-cluster sum of squares"
    title <- "Elbow method"
    names(values)[2] <- "wss"
  } else {
    valid <- values$k >= 2
    optimal_k <- values$k[valid][which.max(values$value[valid])]
    criterion <- "maximum average silhouette width"
    title <- "Average silhouette method"
    names(values)[2] <- "silhouette"
  }

  # The x axis is discrete (and starts at k = 2 for the silhouette method):
  # place the line at the position of the optimal k
  x_pos <- match(as.character(optimal_k), levels(factor(plot$data$clusters)))

  plot <- plot +
    ggplot2::geom_vline(xintercept = x_pos, linetype = 2, color = col) +
    ggplot2::labs(
      title = title,
      subtitle = paste0("Optimal k = ", optimal_k)
    )

  list(
    method = method,
    optimal_k = as.integer(optimal_k),
    criterion = criterion,
    values = values,
    plot = plot
  )
}

# Clustering function with the interface function(x, k) -> list(cluster = ...)
# as required by factoextra::fviz_nbclust() and cluster::clusGap()
seg_cluster_fun <- function(cluster_method, distance, nstart, hc_method) {
  switch(
    cluster_method,
    kmeans = function(x, k) {
      stats::kmeans(x, centers = k, nstart = nstart, iter.max = 50)
    },
    hclust = {
      hc_metric <- if (distance %in% seg_get_dist_methods) distance else "euclidean"
      function(x, k) {
        # k = 1 (needed for the WSS curve) is rejected by older factoextra
        # versions of hcut(): all respondents form a single cluster anyway
        if (k == 1) {
          return(list(cluster = rep(1L, nrow(x))))
        }
        factoextra::hcut(x, k = k, hc_method = hc_method, hc_metric = hc_metric)
      }
    },
    pam = {
      pam_metric <- if (distance == "manhattan") "manhattan" else "euclidean"
      function(x, k) {
        list(cluster = cluster::pam(x, k = k, metric = pam_metric, cluster.only = TRUE))
      }
    }
  )
}

# Elbow of a decreasing curve: point with the largest distance below the
# straight line between the first and the last point (normalized scales)
seg_elbow <- function(k, y) {
  if (length(k) < 3) {
    return(k[1])
  }
  kn <- (k - min(k)) / (max(k) - min(k))
  yn <- (y - min(y)) / (max(y) - min(y))
  k[which.max(1 - kn - yn)]
}

seg_check_k_max <- function(k_max, data) {
  if (!rlang::is_scalar_integerish(k_max) || k_max < 2) {
    cli::cli_abort("{.arg k_max} must be a single integer of at least 2.")
  }
  if (k_max >= nrow(data)) {
    cli::cli_abort("{.arg k_max} must be smaller than the number of respondents ({nrow(data)}).")
  }
  invisible(TRUE)
}

# Extract the prepared clustering data (and, if reusable, the distance matrix)
# from the output of seg_prep_data() or a data frame / matrix
seg_extract_input <- function(x, distance = NULL, distance_engine = NULL) {
  if (inherits(x, "dist")) {
    cli::cli_abort(c(
      "{.arg x} is a distance matrix.",
      "i" = "This function needs the data itself.",
      "i" = "Pass the output of {.fn seg_prep_data} or a data frame instead."
    ))
  }

  scale <- "none"
  daisy_args <- list()
  dist_obj <- NULL

  if (inherits(x, "seg_prep")) {
    data <- x$data
    scale <- x$settings$scale
    daisy_args <- x$settings$daisy_args %||% list()
    distance <- distance %||% x$settings$distance
    distance_engine <- distance_engine %||% x$settings$distance_engine
    # Reuse the stored distance matrix if the settings are unchanged
    if (
      identical(distance, x$settings$distance) &&
        identical(distance_engine, x$settings$distance_engine)
    ) {
      dist_obj <- x$dist
    }
  } else if (is.data.frame(x) || is.matrix(x)) {
    data <- as.data.frame(x)
  } else {
    cli::cli_abort(
      "{.arg x} must be the output of {.fn seg_prep_data}, a data frame or a matrix."
    )
  }

  distance <- distance %||% "euclidean"
  distance_engine <- seg_resolve_engine(distance, distance_engine %||% "auto")

  data[] <- lapply(data, \(v) {
    if (is.numeric(v)) as.numeric(haven::zap_labels(v)) else v
  })
  data <- tibble::as_tibble(data)

  non_numeric <- names(data)[!purrr::map_lgl(data, is.numeric)]
  if (length(non_numeric) > 0) {
    cli::cli_abort(c(
      "All clustering variables must be numeric.",
      "x" = "Non-numeric variable{?s}: {.val {non_numeric}}"
    ))
  }
  if (anyNA(data)) {
    cli::cli_abort(c(
      "{.arg x} contains missing values.",
      "i" = "Use {.fn seg_prep_data} with {.code missing = \"omit\"}, {.val mean}, {.val median} or {.val mice}."
    ))
  }

  list(
    data = data,
    dist = dist_obj,
    distance = distance,
    distance_engine = distance_engine,
    scale = scale,
    daisy_args = daisy_args
  )
}

# Rescale a numeric vector (used for the prepared data and the random data)
seg_rescale <- function(v, scale) {
  switch(
    scale,
    z = (v - mean(v, na.rm = TRUE)) / stats::sd(v, na.rm = TRUE),
    range = (v - min(v, na.rm = TRUE)) /
      (max(v, na.rm = TRUE) - min(v, na.rm = TRUE)),
    none = v
  )
}

# Evaluate an expression with a given seed, leaving the global seed untouched
seg_with_seed <- function(seed, expr) {
  if (is.null(seed)) {
    return(expr)
  }
  has_seed <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  if (has_seed) {
    old_seed <- get(".Random.seed", envir = globalenv())
  }
  on.exit(
    {
      if (has_seed) {
        assign(".Random.seed", old_seed, envir = globalenv())
      } else if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
        rm(".Random.seed", envir = globalenv())
      }
    },
    add = TRUE
  )
  set.seed(seed)
  expr
}

seg_resolve_engine <- function(distance, distance_engine) {
  all_methods <- union(seg_get_dist_methods, seg_daisy_methods)
  if (!rlang::is_string(distance) || !distance %in% all_methods) {
    cli::cli_abort(c(
      "Invalid {.arg distance}: {.val {distance}}.",
      "i" = "Must be one of {.val {all_methods}}."
    ))
  }

  if (distance_engine == "auto") {
    distance_engine <- if (distance == "gower") "daisy" else "get_dist"
  }

  allowed <- if (distance_engine == "daisy") {
    seg_daisy_methods
  } else {
    seg_get_dist_methods
  }
  if (!distance %in% allowed) {
    cli::cli_abort(c(
      "{.code distance = \"{distance}\"} is not available with {.code distance_engine = \"{distance_engine}\"}.",
      "i" = "Allowed for {.val {distance_engine}}: {.val {allowed}}."
    ))
  }

  distance_engine
}
