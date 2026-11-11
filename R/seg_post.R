# Post-clustering functions of the segmentation module: validation of the
# cluster solutions returned by seg_cluster() and its family functions.


# ---- Constants ---------------------------------------------------------------

# Validation measures: type, direction and description
seg_validation_measures <- tibble::tribble(
  ~measure, ~validation, ~better, ~description,
  "Silhouette", "internal", "higher", "Average silhouette width (-1 to 1)",
  "Dunn", "internal", "higher", "Dunn index (0 to Inf)",
  "Negative silhouette", "internal", "lower", "Share of respondents with a negative silhouette width (0 to 1)",
  "Corrected Rand", "external", "higher", "Corrected Rand index (-1 to 1)",
  "VI", "external", "lower", "Meila's variation of information (0 to Inf)",
  "Smallest cluster", "cluster size", "higher", "Share of respondents in the smallest cluster (0 to 1)"
)


# ---- Cluster validation ------------------------------------------------------

#' Validate cluster solutions
#'
#' Assesses the quality of one or several cluster solutions with internal
#' validation measures (silhouette width, Dunn index) and, if a reference
#' grouping is supplied, external validation measures (corrected Rand index,
#' Meila's variation of information), following the approach described by
#' [datanovia](https://www.datanovia.com/learn/machine-learning/clustering/cluster-validation-statistics).
#' Every solution gets a silhouette plot ([factoextra::fviz_silhouette()]),
#' and all measures are visualized with ggplot2, which makes it easy to
#' compare several numbers of clusters and/or algorithms.
#'
#' @details
#' Clustering algorithms always return clusters, even for data without any
#' cluster structure. Cluster validation checks whether the clusters found
#' are compact and well separated (*internal validation*), and whether they
#' agree with a known grouping (*external validation*). Comparing the
#' measures across numbers of clusters and algorithms (*relative validation*)
#' helps to choose the final solution.
#'
#' ## Internal measures
#'
#' Internal measures use only the clustering variables (via the distance
#' matrix) and the cluster assignment. They assess *compactness*
#' (respondents in the same cluster are similar) and *separation*
#' (respondents in different clusters are dissimilar).
#'
#' * **Silhouette width** (range -1 to 1, higher is better). For each
#'   respondent \eqn{i}, \eqn{a_i} is the average distance to the other
#'   members of its own cluster and \eqn{b_i} the average distance to the
#'   members of the nearest other cluster (the *neighbor*). The silhouette
#'   width is
#'   \eqn{s_i = (b_i - a_i) / \max(a_i, b_i)}{s_i = (b_i - a_i) / max(a_i, b_i)}.
#'   Values close to 1 indicate well clustered respondents, values around 0
#'   respondents between two clusters, and negative values respondents that
#'   are closer to another cluster than to their own, i.e. probably in the
#'   wrong cluster. The *silhouette coefficient* (`Silhouette`) is the
#'   average over all respondents; the averages per cluster are returned in
#'   `$cluster_silhouette`, and the values of each respondent in
#'   `$silhouette`. A common rule of thumb (Kaufman & Rousseeuw, 1990) for
#'   the silhouette coefficient is:
#'
#'   | Silhouette coefficient | Interpretation |
#'   |---|---|
#'   | > 0.70 | strong structure |
#'   | 0.51 to 0.70 | reasonable structure |
#'   | 0.26 to 0.50 | weak structure, could be artificial |
#'   | <= 0.25 | no substantial structure |
#'
#'   For attitudinal survey data with many correlated rating scales, values
#'   of 0.1 to 0.25 are common; a segmentation can still be useful (e.g. as a
#'   meaningful partition of a continuum), but the segments should then not
#'   be presented as clearly distinct groups.
#'
#' * **Negative silhouette** (range 0 to 1, lower is better). The share of
#'   respondents with a negative silhouette width. A few negative values at
#'   the borders between similar clusters are normal; a large share indicates
#'   that the solution does not fit the data well (or that a cluster should be
#'   split or merged).
#'
#' * **Dunn index** (range 0 to Inf, higher is better). The smallest distance
#'   between two respondents in different clusters (*minimum separation*),
#'   divided by the largest distance between two respondents in the same
#'   cluster (*maximum diameter*). It relates the worst-case separation to the
#'   worst-case compactness. As it relies on a single minimum and a single
#'   maximum, it is very sensitive to outliers; for survey data, values are
#'   typically close to 0 and best used to compare solutions on the same data
#'   rather than on their own.
#'
#' Further internal statistics of [fpc::cluster.stats()] are returned in
#' `$statistics`: the average distance within and between clusters and their
#' ratio (`wb_ratio`, lower is better), the within-cluster sum of squares,
#' the Calinski-Harabasz index (`ch`, higher is better), a more robust
#' variant of the Dunn index based on average distances (`dunn2`, higher is
#' better), the Pearson correlation between the distances and the
#' "same cluster" indicator (`pearson_gamma`, higher is better) and the
#' entropy of the cluster sizes (`entropy`, higher = more balanced).
#'
#' ## External measures
#'
#' If a reference grouping is supplied with `external` (e.g. a known
#' segmentation from a previous wave, a benchmark solution or a
#' sociodemographic grouping), the agreement of each solution with it is
#' measured. The number of groups does not need to be the same.
#'
#' * **Corrected Rand index** (Hubert & Arabie, 1985; also *adjusted Rand
#'   index*, range -1 to 1, higher is better). Considers all pairs of
#'   respondents and counts how often both groupings agree (both in the same
#'   group or both in different groups), corrected for the agreement expected
#'   by chance. 1 means identical groupings, 0 an agreement at chance level.
#'
#' * **Meila's variation of information** (VI, Meila, 2007; range 0 to Inf,
#'   lower is better). An information-theoretic distance between the two
#'   groupings: the information lost and gained when switching from one
#'   grouping to the other. 0 means identical groupings.
#'
#' The cross tabulations of each solution with the reference grouping are
#' returned in `$crosstabs`; they show which clusters correspond to which
#' reference groups. Respondents with a missing value in the reference
#' grouping are excluded from the external measures.
#'
#' External validation is mainly used to check whether a new segmentation
#' reproduces an existing one, or to compare algorithms on data with known
#' groups. Note that a solution may legitimately differ from a reference
#' grouping, e.g. if the clustering variables have changed.
#'
#' ## Cluster sizes
#'
#' The validation measures do not take the cluster sizes into account. The
#' share of the smallest cluster is therefore reported for each solution and
#' shown in the plots; solutions below `min_cluster_share` are flagged.
#'
#' ## Comparing several solutions
#'
#' With several solutions (e.g. `seg_cluster(prep, "kmeans", k = 2:6)`, or a
#' list of solutions of different algorithms), all measures are shown as
#' lines over the number of clusters, one line per algorithm (`$plot`), and
#' the best solution per measure is reported in `$optimal`. As with
#' [seg_compare_algorithms()], no single measure is decisive: prefer
#' solutions that perform well on several measures, have no too small
#' clusters and can be interpreted. The silhouette coefficient tends to favor
#' few clusters.
#'
#' All measures of a solution are computed on the distance matrix of the
#' prepared data (`object$dist`), or, if it is not available (e.g. after
#' [seg_prep_data()] with `compute_distance = FALSE`), on a distance matrix
#' computed with the distance measure of the prepared data. This is also the
#' case for methods that optimize Euclidean distances (k-means), so that all
#' solutions on the same prepared data are evaluated on the same distances.
#' Only compare solutions based on the same prepared data.
#'
#' ## Noise
#'
#' Respondents classified as noise by density-based methods (cluster 0) are
#' excluded from the internal measures and the silhouette plot. For the
#' external measures, noise is treated as a group of its own. Solutions with
#' fewer than two clusters (excluding noise) cannot be validated internally;
#' their internal measures are `NA`.
#'
#' @param object A cluster solution from [seg_cluster()] or one of its family
#'   functions (class `seg_cluster`), several solutions (class
#'   `seg_cluster_set`, e.g. from `k = 2:6`), or a list of such objects, e.g.
#'   `list(hkmeans = cl_hk, pam = cl_pam)`. The names of the list are used as
#'   the names of the algorithms in the output and plots (by default, the name
#'   of the clustering method).
#' @param external Optional reference grouping for the external measures:
#'   * a vector with one value per respondent of the prepared data,
#'   * a single string naming a column of the original data
#'     (`object$data_full`, e.g. `"cluster_benchmark"`), or
#'   * a cluster solution (class `seg_cluster`), e.g. an existing
#'     segmentation converted with [seg_as_cluster()].
#'
#'   Defaults to `NULL` (no external validation).
#' @param external_name Name of the reference grouping used in the output.
#'   Defaults to the column name (if `external` is a string), the title of
#'   the solution (if `external` is a cluster solution), or `"external"`.
#' @param min_cluster_share Solutions whose smallest cluster contains a lower
#'   share of respondents are flagged. Defaults to 0.05 (5%).
#' @param silhouette_plots Logical. Whether to create the silhouette plots
#'   (slow for many solutions with many respondents). Defaults to `TRUE`.
#' @param verbose Logical. Whether to print the results. Defaults to `TRUE`.
#'
#' @returns An object of class `seg_validation`, a list with the elements:
#'   * `summary`: tibble with one row per solution: the algorithm (`method`),
#'     the number of clusters (`k`), the solution, the number of respondents
#'     validated, the main measures and the share of the smallest cluster.
#'   * `measures`: the same measures in long format, as used for the plots.
#'   * `optimal`: tibble with the best solution per measure, with and without
#'     the solutions below `min_cluster_share` (only with several solutions).
#'   * `statistics`: tibble with further internal statistics of
#'     [fpc::cluster.stats()] per solution (see "Details").
#'   * `cluster_silhouette`: tibble with the size, average silhouette width
#'     and share of negative silhouette widths per solution and cluster.
#'   * `silhouette`: named list with one tibble per solution, with the
#'     respondent identifier, the cluster, the nearest other cluster
#'     (`neighbor`) and the silhouette width of each respondent. Respondents
#'     with a negative silhouette width are probably misclassified.
#'   * `crosstabs`: named list with the cross tabulation of each solution with
#'     the reference grouping (`NULL` without `external`).
#'   * `plot`: all measures in one faceted plot.
#'   * `plots`: list with the elements `measures` (one plot per measure) and
#'     `silhouette` (one silhouette plot per solution).
#'   * `plot_silhouette`: the silhouette plots of all solutions combined.
#'   * `settings`: list of the settings used.
#'
#' @references
#' Dunn, J. C. (1974). Well-separated clusters and optimal fuzzy partitions.
#' *Journal of Cybernetics, 4*(1), 95-104. \doi{10.1080/01969727408546059}
#'
#' Hubert, L. and Arabie, P. (1985). Comparing partitions. *Journal of
#' Classification, 2*, 193-218. \doi{10.1007/BF01908075}
#'
#' Kaufman, L. and Rousseeuw, P. J. (1990). *Finding Groups in Data: An
#' Introduction to Cluster Analysis*. Wiley.
#'
#' Meila, M. (2007). Comparing clusterings - an information based distance.
#' *Journal of Multivariate Analysis, 98*(5), 873-895.
#' \doi{10.1016/j.jmva.2006.11.013}
#'
#' Rousseeuw, P. J. (1987). Silhouettes: A graphical aid to the
#' interpretation and validation of cluster analysis. *Journal of
#' Computational and Applied Mathematics, 20*, 53-65.
#' \doi{10.1016/0377-0427(87)90125-7}
#'
#' @family validation
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   id = "id",
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#'
#' # Single solution
#' cl <- seg_cluster(prep, k = 4, plots = FALSE, verbose = FALSE)
#' val <- seg_validation(cl)
#' val$plots$silhouette[[1]]
#' val$cluster_silhouette
#'
#' # Several numbers of clusters, with the benchmark segmentation as
#' # reference grouping
#' cl_km <- seg_cluster(prep, "kmeans", k = 2:6, plots = FALSE, verbose = FALSE)
#' val_km <- seg_validation(cl_km, external = "cluster_benchmark")
#' val_km$plot
#' val_km$crosstabs$`k-means, k = 4`
#'
#' # Several algorithms
#' cl_pam <- seg_cluster(prep, "pam", k = 2:6, plots = FALSE, verbose = FALSE)
#' val_all <- seg_validation(list(`k-means` = cl_km, PAM = cl_pam))
#' val_all$plot
#' }
#'
#' @export
seg_validation <- function(
  object,
  external = NULL,
  external_name = NULL,
  min_cluster_share = 0.05,
  silhouette_plots = TRUE,
  verbose = TRUE
) {
  # ---- 1. Check arguments and collect the solutions ----

  solutions <- seg_validation_solutions(object)

  if (
    !is.numeric(min_cluster_share) ||
      length(min_cluster_share) != 1 ||
      min_cluster_share < 0 ||
      min_cluster_share >= 1
  ) {
    cli::cli_abort("{.arg min_cluster_share} must be a single number between 0 and 1.")
  }

  external_name <- external_name %||%
    if (rlang::is_string(external)) {
      external
    } else if (inherits(external, "seg_cluster")) {
      seg_solution_title(external)
    } else {
      "external"
    }

  # ---- 2. Validate each solution ----

  # The distance matrix is reused for consecutive solutions on the same data
  cache <- new.env(parent = emptyenv())

  results <- purrr::map(solutions, \(sol) {
    s <- sol$object
    if (is.null(cache$data) || !identical(cache$data, s$data)) {
      cache$data <- s$data
      cache$dist <- seg_validation_dist(s)
    }
    ext <- if (is.null(external)) NULL else seg_validation_external(external, s)
    seg_validate_solution(s, cache$dist, ext, external_name)
  })

  labels <- make.unique(purrr::map_chr(solutions, \(sol) {
    paste0(sol$method, ", k = ", sol$object$k_found)
  }))
  names(results) <- labels

  methods <- unique(purrr::map_chr(solutions, "method"))

  # ---- 3. Summary and measures ----

  summary_tbl <- purrr::pmap(
    list(solutions, results, labels),
    \(sol, res, lbl) {
      tibble::tibble(
        method = sol$method,
        k = sol$object$k_found,
        solution = lbl,
        n = res$n,
        noise = res$noise,
        silhouette = res$silhouette_avg,
        dunn = res$stats$dunn %||% NA_real_,
        negative_silhouette = res$negative_share,
        smallest_share = res$smallest_share,
        too_small = res$smallest_share < min_cluster_share,
        corrected_rand = res$external$corrected_rand %||% NA_real_,
        vi = res$external$vi %||% NA_real_
      )
    }
  ) |>
    purrr::list_rbind() |>
    dplyr::mutate(method = factor(.data$method, levels = methods))

  if (is.null(external)) {
    summary_tbl <- summary_tbl |> dplyr::select(-"corrected_rand", -"vi")
  }
  if (all(summary_tbl$noise == 0)) {
    summary_tbl <- summary_tbl |> dplyr::select(-"noise")
  }

  measure_cols <- c(
    Silhouette = "silhouette",
    Dunn = "dunn",
    `Negative silhouette` = "negative_silhouette",
    `Corrected Rand` = "corrected_rand",
    VI = "vi",
    `Smallest cluster` = "smallest_share"
  )
  measure_cols <- measure_cols[measure_cols %in% names(summary_tbl)]

  measures <- purrr::imap(measure_cols, \(col, ms) {
    summary_tbl |>
      dplyr::select("method", "k", "solution", "smallest_share", "too_small") |>
      dplyr::mutate(measure = ms, value = summary_tbl[[col]])
  }) |>
    purrr::list_rbind() |>
    dplyr::left_join(
      seg_validation_measures |> dplyr::select("measure", "validation", "better"),
      by = "measure"
    ) |>
    dplyr::mutate(
      measure = factor(.data$measure, levels = seg_validation_measures$measure)
    ) |>
    dplyr::filter(!is.na(.data$value)) |>
    dplyr::select(
      "validation",
      "measure",
      "better",
      "method",
      "k",
      "solution",
      "value",
      "smallest_share",
      "too_small"
    ) |>
    dplyr::arrange(.data$measure, .data$method, .data$k)

  # ---- 4. Best solution per measure ----

  optimal <- NULL
  if (length(results) > 1 && nrow(measures) > 0) {
    pick_best <- function(d) {
      if (nrow(d) == 0) {
        return(d)
      }
      d |>
        dplyr::slice(
          if (d$better[1] == "lower") which.min(d$value) else which.max(d$value)
        )
    }
    scored <- measures |> dplyr::filter(.data$measure != "Smallest cluster")
    best_all <- scored |>
      dplyr::group_by(.data$measure) |>
      dplyr::group_modify(\(d, g) pick_best(d)) |>
      dplyr::ungroup()
    best_valid <- scored |>
      dplyr::filter(!.data$too_small) |>
      dplyr::group_by(.data$measure) |>
      dplyr::group_modify(\(d, g) pick_best(d)) |>
      dplyr::ungroup()

    optimal <- best_all |>
      dplyr::select(
        "validation",
        "measure",
        "better",
        "method",
        "k",
        "solution",
        score = "value",
        "smallest_share"
      ) |>
      dplyr::left_join(
        best_valid |>
          dplyr::select(
            "measure",
            solution_valid = "solution",
            score_valid = "value"
          ),
        by = "measure"
      )
  }

  # ---- 5. Further statistics and silhouettes ----

  statistics <- purrr::map2(results, labels, \(res, lbl) {
    st <- res$stats
    if (is.null(st)) {
      return(NULL)
    }
    tibble::tibble(
      solution = lbl,
      n = res$n,
      average_within = st$average.within,
      average_between = st$average.between,
      wb_ratio = st$wb.ratio,
      within_ss = st$within.cluster.ss,
      min_separation = st$min.separation,
      max_diameter = st$max.diameter,
      dunn = st$dunn,
      dunn2 = st$dunn2,
      ch = st$ch,
      pearson_gamma = st$pearsongamma,
      entropy = st$entropy
    )
  }) |>
    purrr::list_rbind()

  cluster_silhouette <- purrr::map2(results, labels, \(res, lbl) {
    if (is.null(res$cluster_silhouette)) {
      return(NULL)
    }
    res$cluster_silhouette |> dplyr::mutate(solution = lbl, .before = 1)
  }) |>
    purrr::list_rbind()

  silhouette <- purrr::map(results, "silhouette_tbl")
  crosstabs <- if (is.null(external)) NULL else purrr::map(results, "crosstab")

  # ---- 6. Plots ----

  plots_measures <- purrr::map(
    rlang::set_names(levels(droplevels(measures$measure))),
    \(ms) {
      seg_clvalid_plot(
        measures |> dplyr::filter(.data$measure == ms),
        min_cluster_share = min_cluster_share,
        facet = FALSE,
        color_name = "Algorithm"
      )
    }
  )
  plot <- if (nrow(measures) > 0) {
    seg_clvalid_plot(
      measures,
      min_cluster_share = min_cluster_share,
      facet = TRUE,
      color_name = "Algorithm"
    ) +
      ggplot2::labs(
        title = "Cluster validation",
        subtitle = if (!is.null(external)) {
          paste0("External grouping: ", external_name)
        }
      )
  } else {
    NULL
  }

  plots_silhouette <- list()
  plot_silhouette <- NULL
  if (silhouette_plots) {
    plots_silhouette <- purrr::map2(results, solutions, \(res, sol) {
      if (is.null(res$sil)) {
        return(NULL)
      }
      seg_silhouette_plot(res$sil, sol$object)
    }) |>
      purrr::compact()
    if (length(plots_silhouette) > 0) {
      plot_silhouette <- do.call(
        see::plots,
        c(
          unname(plots_silhouette),
          list(n_columns = min(3, length(plots_silhouette)))
        )
      )
    }
  }

  # ---- 7. Output ----

  out <- structure(
    list(
      summary = summary_tbl,
      measures = measures,
      optimal = optimal,
      statistics = statistics,
      cluster_silhouette = cluster_silhouette,
      silhouette = silhouette,
      crosstabs = crosstabs,
      plot = plot,
      plots = list(measures = plots_measures, silhouette = plots_silhouette),
      plot_silhouette = plot_silhouette,
      settings = list(
        external_name = if (!is.null(external)) external_name,
        min_cluster_share = min_cluster_share,
        distance = unique(purrr::map_chr(solutions, \(sol) {
          sol$object$settings$distance %||% "euclidean"
        }))
      )
    ),
    class = c("seg_validation", "list")
  )

  if (verbose) {
    print(out)
  }

  invisible(out)
}


#' Silhouette plot of a cluster solution
#'
#' Plots the silhouette width of each respondent, sorted by cluster and
#' silhouette width, with [factoextra::fviz_silhouette()]. The dashed line
#' shows the average silhouette width (silhouette coefficient). Long bars
#' indicate well clustered respondents, bars around 0 respondents between two
#' clusters, and negative bars respondents that are closer to another cluster
#' than to their own (probably misclassified). See [seg_validation()] for the
#' definition and interpretation of the silhouette width.
#'
#' The silhouette widths are computed on the distance matrix of the prepared
#' data (or with its distance measure, if the matrix is not available).
#' Respondents classified as noise (cluster 0) are excluded.
#'
#' @inheritParams seg_plot_cluster
#' @param ... Arguments passed to [factoextra::fviz_silhouette()] (and on to
#'   `ggpubr::ggpar()`), overriding the defaults, e.g. `label = TRUE` or
#'   `ggtheme = ggplot2::theme_minimal()`.
#'
#' @returns A ggplot object, or `NULL` (with a message) for solutions with
#'   fewer than two clusters.
#'
#' @family validation
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
#' cl <- seg_cluster(prep, k = 3, plots = FALSE, verbose = FALSE)
#' seg_plot_silhouette(cl)
#' }
#'
#' @export
seg_plot_silhouette <- function(object, ...) {
  seg_check_cluster_object(object)
  keep <- object$cluster != 0
  if (length(unique(object$cluster[keep])) < 2) {
    cli::cli_inform(
      "No silhouette plot for {.val {seg_solution_title(object)}}: at least two clusters are needed."
    )
    return(invisible(NULL))
  }
  d <- seg_validation_dist(object)
  if (any(!keep)) {
    d <- seg_subset_dist(d, keep)
  }
  sil <- cluster::silhouette(object$cluster[keep], d)
  seg_silhouette_plot(sil, object, ...)
}


#' @export
print.seg_validation <- function(x, ...) {
  s <- x$summary
  cli::cli_h2("Cluster validation")
  ext <- x$settings$external_name
  cli::cli_text(
    "{nrow(s)} solution{?s} | distance: {.val {x$settings$distance}}",
    if (!is.null(ext)) " | external grouping: {.val {ext}}"
  )

  fmt <- function(v, digits = 2) {
    ifelse(is.na(v), "NA", formatC(v, format = "f", digits = digits))
  }
  lines <- paste0(
    "{.strong ", s$solution, "}: silhouette = ", fmt(s$silhouette),
    ", Dunn = ", fmt(s$dunn, 3),
    ", negative silhouette = ", fmt(100 * s$negative_silhouette, 0), "%",
    ", smallest cluster = ", round(100 * s$smallest_share), "%",
    ifelse(s$too_small, " {.emph (too small)}", "")
  )
  if ("noise" %in% names(s)) {
    lines <- paste0(lines, ifelse(s$noise > 0, paste0(", noise = ", s$noise, " (excluded)"), ""))
  }
  if ("corrected_rand" %in% names(s)) {
    lines <- paste0(
      lines,
      " | corrected Rand = ", fmt(s$corrected_rand),
      ", VI = ", fmt(s$vi)
    )
  }
  cli::cli_ul(lines)

  o <- x$optimal
  if (!is.null(o) && nrow(o) > 0) {
    cli::cli_text("")
    cli::cli_text("{.strong Best solution per measure}")
    best <- purrr::pmap_chr(o, function(...) {
      r <- list(...)
      txt <- paste0(
        r$measure, " (", r$better, " = better): ", r$solution,
        " (", fmt(r$score, 3), ")"
      )
      if (!is.na(r$solution_valid) && r$solution_valid != r$solution) {
        txt <- paste0(
          txt, " {.emph | without too small clusters: ", r$solution_valid, "}"
        )
      }
      txt
    })
    cli::cli_ul(best)
  }

  max_sil <- suppressWarnings(max(s$silhouette, na.rm = TRUE))
  if (is.finite(max_sil)) {
    strength <- dplyr::case_when(
      max_sil > 0.70 ~ "strong",
      max_sil > 0.50 ~ "reasonable",
      max_sil > 0.25 ~ "weak",
      TRUE ~ "no substantial"
    )
    cli::cli_alert_info(
      "Highest silhouette coefficient {fmt(max_sil)}: {strength} cluster structure (Kaufman & Rousseeuw)."
    )
  }
  n_small <- sum(s$too_small)
  if (n_small > 0) {
    cli::cli_alert_warning(
      "{n_small} solution{?s} with a cluster below {round(100 * x$settings$min_cluster_share)}% of respondents."
    )
  }
  plot_txt <- c(
    if (!is.null(x$plot)) "$plot (measures)",
    if (length(x$plots$silhouette) > 0) "$plot_silhouette",
    "$plots"
  )
  cli::cli_text("{.emph Plots: {.code {plot_txt}}}")
  invisible(x)
}


# ---- Internal helpers --------------------------------------------------------

# Flatten the input of seg_validation() to a list of single solutions, each
# with the name of its algorithm
seg_validation_solutions <- function(object) {
  is_solution <- function(o) inherits(o, c("seg_cluster", "seg_cluster_set"))

  if (is_solution(object)) {
    object <- list(object)
  } else if (
    !is.list(object) ||
      length(object) == 0 ||
      !all(purrr::map_lgl(object, is_solution))
  ) {
    cli::cli_abort(c(
      "{.arg object} must be a cluster solution or a list of cluster solutions.",
      "i" = "Use the output of {.fn seg_cluster}, its family functions or {.fn seg_as_cluster}."
    ))
  }

  nms <- names(object) %||% rep("", length(object))
  nms[is.na(nms)] <- ""

  purrr::map2(object, nms, \(o, nm) {
    sols <- if (inherits(o, "seg_cluster_set")) unname(o$solutions) else list(o)
    purrr::map(sols, \(s) {
      list(object = s, method = if (nzchar(nm)) nm else seg_method_label(s))
    })
  }) |>
    purrr::list_flatten() |>
    unname()
}

# Distance matrix of a solution: the stored one, or computed with the
# distance measure of the prepared data
seg_validation_dist <- function(object) {
  object$dist %||%
    seg_distance(
      object$data,
      distance = object$settings$distance %||% "euclidean",
      distance_engine = object$settings$distance_engine %||% "auto"
    )
}

seg_subset_dist <- function(d, keep) {
  stats::as.dist(as.matrix(d)[keep, keep, drop = FALSE])
}

# Reference grouping for one solution (vector, column name or seg_cluster)
seg_validation_external <- function(external, object) {
  n <- nrow(object$data)
  if (rlang::is_string(external)) {
    if (!external %in% names(object$data_full)) {
      cli::cli_abort("Column {.val {external}} not found in the original data ({.code $data_full}).")
    }
    external <- object$data_full[[external]]
  } else if (inherits(external, "seg_cluster")) {
    external <- external$cluster
  } else if (inherits(external, "seg_cluster_set")) {
    cli::cli_abort(c(
      "{.arg external} must be a single cluster solution.",
      "i" = "Use e.g. {.code external$solutions$k4}."
    ))
  }
  if (!is.atomic(external) || length(external) != n) {
    cli::cli_abort(c(
      "{.arg external} must have one value per respondent of the prepared data.",
      "x" = "Expected {n} values, got {length(external)}."
    ))
  }
  if (all(is.na(external))) {
    cli::cli_abort("{.arg external} contains only missing values.")
  }
  external
}

# Validation measures of a single solution
seg_validate_solution <- function(object, d, external, external_name) {
  cl <- object$cluster
  keep <- cl != 0
  cl_valid <- cl[keep]
  k <- length(unique(cl_valid))
  ids <- object$assignment[[1]]

  out <- list(
    n = sum(keep),
    noise = sum(!keep),
    sil = NULL,
    stats = NULL,
    silhouette_avg = NA_real_,
    negative_share = NA_real_,
    silhouette_tbl = NULL,
    cluster_silhouette = NULL,
    smallest_share = min(object$sizes$share[object$sizes$cluster != 0]),
    external = NULL,
    crosstab = NULL
  )

  # ---- Internal measures ----

  if (k >= 2) {
    d_valid <- if (any(!keep)) seg_subset_dist(d, keep) else d
    sil <- cluster::silhouette(cl_valid, d_valid)
    widths <- sil[, "sil_width"]

    out$sil <- sil
    out$silhouette_avg <- mean(widths)
    out$negative_share <- mean(widths < 0)
    out$stats <- fpc::cluster.stats(
      d_valid,
      as.integer(factor(cl_valid)),
      silhouette = FALSE,
      wgap = FALSE,
      sepindex = FALSE
    )
    out$silhouette_tbl <- tibble::tibble(
      id = ids[keep],
      cluster = as.integer(sil[, "cluster"]),
      neighbor = as.integer(sil[, "neighbor"]),
      sil_width = widths
    ) |>
      dplyr::rename(!!names(object$assignment)[1] := "id")
    out$cluster_silhouette <- tibble::tibble(
      cluster = as.integer(sil[, "cluster"]),
      sil_width = widths
    ) |>
      dplyr::summarise(
        n = dplyr::n(),
        avg_width = mean(.data$sil_width),
        negative_share = mean(.data$sil_width < 0),
        .by = "cluster"
      ) |>
      dplyr::arrange(.data$cluster)
  } else {
    cli::cli_warn(c(
      "{.val {seg_solution_title(object)}} has fewer than two clusters (excluding noise).",
      "i" = "The internal measures cannot be computed."
    ))
  }

  # ---- External measures ----

  if (!is.null(external)) {
    ok <- !is.na(external)
    ext_codes <- as.integer(factor(as.vector(haven::zap_labels(external[ok]))))
    cl_codes <- as.integer(factor(cl[ok]))
    if (length(unique(ext_codes)) < 2 && length(unique(cl_codes)) < 2) {
      out$external <- list(corrected_rand = NA_real_, vi = NA_real_)
    } else {
      cmp <- fpc::cluster.stats(NULL, cl_codes, ext_codes, compareonly = TRUE)
      # VI can be slightly negative for identical groupings (rounding)
      out$external <- list(corrected_rand = cmp$corrected.rand, vi = max(cmp$vi, 0))
    }

    labels <- attr(external, "labels", exact = TRUE)
    ext_display <- if (!is.null(labels)) {
      values <- as.vector(haven::zap_labels(external))
      haven::as_factor(haven::labelled(values, labels = labels))
    } else {
      factor(external)
    }
    codes <- sort(unique(cl))
    codes <- c(codes[codes != 0], codes[codes == 0])
    cl_display <- factor(cl, levels = codes, labels = seg_cluster_names(object, codes))
    out$crosstab <- table(cl_display[ok], ext_display[ok], dnn = c("Cluster", external_name))
  }

  out
}

# Silhouette plot from a silhouette object, colored like the other plots
seg_silhouette_plot <- function(sil, object, ...) {
  codes <- sort(unique(as.integer(sil[, "cluster"])))
  widths <- sil[, "sil_width"]

  base <- list(
    sil.obj = sil,
    label = FALSE,
    print.summary = FALSE,
    palette = seg_palette(max(codes))[codes],
    ggtheme = ggplot2::theme_classic()
  )
  args <- utils::modifyList(base, list(...))

  do.call(factoextra::fviz_silhouette, args) +
    ggplot2::labs(
      title = paste0("Silhouette plot: ", seg_solution_title(object)),
      subtitle = paste0(
        "Average width: ", formatC(mean(widths), format = "f", digits = 2),
        " | negative: ", round(100 * mean(widths < 0)), "%"
      ),
      y = "Silhouette width",
      fill = "Cluster",
      color = "Cluster"
    )
}
