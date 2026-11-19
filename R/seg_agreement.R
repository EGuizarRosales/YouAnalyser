# Agreement between cluster solutions: which respondents are assigned to the
# same cluster by different algorithms (or settings)?


# ---- seg_agreement() ---------------------------------------------------------

#' Agreement between cluster solutions
#'
#' Compares the assignments of the same respondents by several cluster
#' solutions, e.g. different algorithms with the same number of clusters. As
#' cluster numbers are arbitrary (they only reflect the cluster sizes), the
#' clusters of the solutions are first matched to each other, so that
#' "cluster 2" stands for the same group of respondents in all solutions.
#'
#' @details
#' ## Matching the clusters
#'
#' For two solutions, the clusters are matched such that as many respondents
#' as possible are assigned to matched clusters (cross table with the largest
#' possible sum on the diagonal). This linear assignment problem is solved
#' with the Hungarian algorithm ([clue::solve_LSAP()]). If a solution has more
#' clusters than the reference, its unmatched clusters get new numbers after
#' the clusters of the reference (by size). Noise (cluster 0 of density-based
#' methods) is never matched to a cluster.
#'
#' ## Measures
#'
#' For every pair of solutions:
#'
#' * **Agreement**: share of respondents assigned to matched clusters (noise
#'   counts as agreement only if both solutions classify the respondent as
#'   noise). Easy to communicate, but depends on the matching and on the
#'   number of clusters (by chance alone, two random solutions with `k`
#'   equally large clusters agree on about `1 / k` of the respondents after
#'   matching, somewhat more due to the matching).
#' * **Corrected Rand index** (Hubert & Arabie, 1985): agreement of the two
#'   solutions on all pairs of respondents (same vs. different cluster),
#'   corrected for chance agreement. 1 = identical, about 0 = no more than by
#'   chance. Independent of the cluster numbers.
#' * **VI**, Meila's variation of information (Meila, 2007): information lost
#'   and gained when moving from one solution to the other. 0 = identical,
#'   larger values = more different.
#'
#' The corrected Rand index and VI are computed with
#' [fpc::cluster.stats()], with noise as a group of its own (as in
#' [seg_validation()]).
#'
#' ## Requirements
#'
#' The solutions must refer to the same respondents, i.e. be computed on the
#' same prepared data (e.g. the same output of [seg_prep_data()]). They are
#' matched by the identifier of the respondents. If some respondents are not
#' part of all solutions (e.g. different missing value strategies), only the
#' respondents of all solutions are compared (with a warning). The number of
#' clusters may differ (with a warning), but agreement is easiest to interpret
#' for solutions with the same number of clusters.
#'
#' @param object A named list of cluster solutions (`seg_cluster` objects, or
#'   `seg_cluster_set` objects whose solutions are all used), e.g.
#'   `list(hkmeans = cl_hk, PAM = cl_pam)`. The names are used as labels;
#'   unnamed solutions are labelled by their method.
#' @param reference The solution that the others are aligned to: its name or
#'   position in `object`. Defaults to the first solution.
#' @param verbose Logical. Whether to print the results. Defaults to `TRUE`.
#'
#' @returns An object of class `seg_agreement`, a list with the elements:
#'   * `pairwise`: tibble with one row per pair of solutions: number of
#'     clusters, `agreement`, `corrected_rand` and `vi`.
#'   * `matrix`: matrix of the pairwise agreement.
#'   * `respondents`: tibble with one row per respondent: the identifier, the
#'     aligned cluster of each solution, the most frequent cluster
#'     (`modal_cluster`; ties are resolved in favor of the reference), the
#'     number and share of solutions assigning the respondent to it
#'     (`n_agree`, `share_agree`) and whether all solutions agree
#'     (`all_agree`).
#'   * `aligned`: named list of the solutions with clusters renumbered to
#'     match the reference (sizes, centers, assignment, memberships and plots
#'     are renumbered accordingly; [predict.seg_cluster()] returns the aligned
#'     numbers). Cluster numbers can have gaps if a solution has fewer
#'     clusters than the reference.
#'   * `crosstabs`: named list of cross tables of the aligned clusters of
#'     each solution (rows) with the reference (columns); the diagonal
#'     contains the respondents assigned to matched clusters.
#'   * `plot`: heatmap of the pairwise agreement.
#'   * `settings`: list with the reference, the number of respondents and the
#'     share of respondents assigned to the same cluster by all solutions.
#'
#' @references
#' Hubert, L., & Arabie, P. (1985). Comparing partitions. *Journal of
#' Classification, 2*(1), 193-218. \doi{10.1007/BF01908075}
#'
#' Meila, M. (2007). Comparing clusterings - an information based distance.
#' *Journal of Multivariate Analysis, 98*(5), 873-895.
#' \doi{10.1016/j.jmva.2006.11.013}
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   id = "id",
#'   missing = "mean",
#'   verbose = FALSE
#' )
#' fit <- function(method) {
#'   seg_cluster(prep, method, k = 4, plots = FALSE, verbose = FALSE)
#' }
#'
#' agr <- seg_agreement(list(
#'   hkmeans = fit("hkmeans"),
#'   PAM = fit("pam"),
#'   Ward = fit("agnes")
#' ))
#' agr$pairwise
#' agr$plot
#' agr$crosstabs$PAM
#'
#' # Respondents assigned differently by the algorithms
#' dplyr::filter(agr$respondents, !all_agree)
#'
#' # Profiles of the aligned solutions: cluster 2 is the same group everywhere
#' agr$aligned$PAM$centers
#' }
#'
#' @export
seg_agreement <- function(object, reference = 1, verbose = TRUE) {
  rlang::check_installed("clue", reason = "to match the clusters of the solutions.")

  # ---- 1. Collect the solutions ----

  if (inherits(object, c("seg_cluster", "seg_cluster_set"))) {
    object <- list(object)
  }
  solutions <- seg_validation_solutions(object)
  objects <- purrr::map(solutions, "object")
  labels <- purrr::map_chr(solutions, "method")
  dup <- labels %in% labels[duplicated(labels)]
  labels[dup] <- paste0(
    labels[dup],
    ", k = ",
    purrr::map_int(objects[dup], "k_found")
  )
  labels <- make.unique(labels, sep = " ")
  names(objects) <- labels

  if (length(objects) < 2) {
    cli::cli_abort("{.arg object} must contain at least two cluster solutions.")
  }

  ref <- if (rlang::is_string(reference)) {
    match(reference, labels)
  } else if (rlang::is_scalar_integerish(reference)) {
    as.integer(reference)
  } else {
    NA_integer_
  }
  if (is.na(ref) || ref < 1 || ref > length(objects)) {
    cli::cli_abort(c(
      "{.arg reference} must be the name or position of a solution.",
      "i" = "Solutions: {.val {labels}}"
    ))
  }
  # Reference first
  objects <- c(objects[ref], objects[-ref])
  labels <- names(objects)

  k <- purrr::map_int(objects, "k_found")
  if (length(unique(k)) > 1) {
    cli::cli_warn(c(
      "The solutions have different numbers of clusters: {.val {paste0(labels, ' (', k, ')')}}.",
      "i" = "Agreement is easiest to interpret for the same number of clusters."
    ))
  }

  # ---- 2. Common respondents ----

  id_names <- purrr::map_chr(objects, \(o) names(o$assignment)[1])
  if (length(unique(id_names)) > 1) {
    cli::cli_abort(c(
      "The solutions use different respondent identifiers: {.val {unique(id_names)}}.",
      "i" = "Compute all solutions on the same prepared data (e.g. the same {.fn seg_prep_data} output)."
    ))
  }
  id_name <- id_names[[1]]
  ids <- purrr::map(objects, \(o) o$assignment[[1]])
  common <- purrr::reduce(ids, intersect)
  if (length(common) < 2) {
    cli::cli_abort(c(
      "The solutions have (almost) no respondents in common.",
      "i" = "Compute all solutions on the same prepared data (e.g. the same {.fn seg_prep_data} output)."
    ))
  }
  n_excluded <- length(unique(unlist(ids))) - length(common)
  if (n_excluded > 0) {
    cli::cli_warn(c(
      "{n_excluded} respondent{?s} {?is/are} not part of all solutions and {?is/are} excluded from the comparison.",
      "i" = "Compute all solutions on the same prepared data to compare all respondents."
    ))
  }
  clusters <- purrr::map2(objects, ids, \(o, id) o$cluster[match(common, id)])

  # ---- 3. Align to the reference ----

  maps <- purrr::map(clusters, \(cl) seg_match_clusters(cl, clusters[[1]]))
  aligned_clusters <- purrr::map2(clusters, maps, seg_recode_clusters)
  aligned <- purrr::map2(objects, maps, seg_recode_solution)

  crosstabs <- purrr::map(aligned_clusters[-1], \(cl) {
    seg_aligned_crosstab(cl, aligned_clusters[[1]], labels[[1]])
  })

  # ---- 4. Pairwise measures ----

  pairs <- utils::combn(length(objects), 2, simplify = FALSE)
  pairwise <- purrr::map(pairs, \(p) {
    a <- clusters[[p[1]]]
    b <- clusters[[p[2]]]
    cmp <- seg_compare_clusters(a, b)
    tibble::tibble(
      solution_1 = labels[p[1]],
      solution_2 = labels[p[2]],
      k_1 = k[[p[1]]],
      k_2 = k[[p[2]]],
      agreement = cmp$agreement,
      corrected_rand = cmp$corrected_rand,
      vi = cmp$vi
    )
  }) |>
    purrr::list_rbind()

  mat <- diag(1, length(objects))
  dimnames(mat) <- list(labels, labels)
  mat[cbind(pairwise$solution_1, pairwise$solution_2)] <- pairwise$agreement
  mat[cbind(pairwise$solution_2, pairwise$solution_1)] <- pairwise$agreement

  # ---- 5. Respondents ----

  cl_mat <- do.call(cbind, aligned_clusters)
  modal <- apply(cl_mat, 1, \(row) {
    counts <- table(row)
    best <- as.integer(names(counts)[counts == max(counts)])
    if (row[[1]] %in% best) row[[1]] else min(best)
  })
  n_agree <- rowSums(cl_mat == modal)
  respondents <- tibble::tibble(!!id_name := common) |>
    dplyr::bind_cols(tibble::as_tibble(cl_mat)) |>
    dplyr::mutate(
      modal_cluster = as.integer(modal),
      n_agree = as.integer(n_agree),
      share_agree = n_agree / ncol(cl_mat),
      all_agree = n_agree == ncol(cl_mat)
    )

  # ---- 6. Output ----

  out <- structure(
    list(
      pairwise = pairwise,
      matrix = mat,
      respondents = respondents,
      aligned = aligned,
      crosstabs = crosstabs,
      plot = seg_agreement_plot(mat),
      settings = list(
        reference = labels[[1]],
        n = length(common),
        n_excluded = n_excluded,
        share_all_agree = mean(respondents$all_agree)
      )
    ),
    class = c("seg_agreement", "list")
  )

  if (verbose) {
    print(out)
  }
  invisible(out)
}


#' @export
print.seg_agreement <- function(x, ...) {
  s <- x$settings
  p <- x$pairwise
  cli::cli_h2("Agreement of {nrow(x$matrix)} cluster solutions")
  cli::cli_text(
    "{s$n} respondents | reference: {.val {s$reference}}",
    if (s$n_excluded > 0) " | {s$n_excluded} excluded (not in all solutions)"
  )
  fmt <- function(v, digits = 2) {
    ifelse(is.na(v), "NA", formatC(v, format = "f", digits = digits))
  }
  cli::cli_ul(paste0(
    "{.strong ", p$solution_1, "} vs. {.strong ", p$solution_2, "}: ",
    round(100 * p$agreement), "% agreement, corrected Rand = ",
    fmt(p$corrected_rand), ", VI = ", fmt(p$vi)
  ))
  cli::cli_text(
    "Same cluster in all solutions: {round(100 * s$share_all_agree)}% of the respondents"
  )
  cli::cli_text(
    "{.emph Results: {.code $pairwise}, {.code $respondents}, {.code $aligned}, {.code $crosstabs}, {.code $plot}}"
  )
  invisible(x)
}


# ---- Helpers -----------------------------------------------------------------

# Match the clusters of x to the clusters of y (Hungarian algorithm), such
# that as many respondents as possible are in matched clusters. Returns a
# named integer vector: names = clusters of x, values = matched clusters of
# y; unmatched clusters of x get new numbers after the clusters of y (by
# size). Noise (0) is not matched.
seg_match_clusters <- function(x, y) {
  lx <- sort(setdiff(unique(x), 0))
  ly <- sort(setdiff(unique(y), 0))
  if (length(lx) == 0) {
    return(stats::setNames(integer(0), character(0)))
  }
  if (length(ly) == 0) {
    return(stats::setNames(seq_along(lx), lx))
  }

  ok <- x != 0 & y != 0
  tab <- unclass(table(factor(x[ok], lx), factor(y[ok], ly)))
  n <- max(dim(tab))
  square <- matrix(0, n, n)
  square[seq_along(lx), seq_along(ly)] <- tab
  matched <- as.integer(clue::solve_LSAP(square, maximum = TRUE))[seq_along(lx)]

  map <- rep(NA_integer_, length(lx))
  is_matched <- matched <= length(ly)
  map[is_matched] <- ly[matched[is_matched]]
  if (any(!is_matched)) {
    size <- vapply(lx[!is_matched], \(cc) sum(x == cc), numeric(1))
    unmatched <- which(!is_matched)[order(-size)]
    map[unmatched] <- max(ly) + seq_along(unmatched)
  }
  stats::setNames(as.integer(map), lx)
}

# Renumber cluster codes with a map from seg_match_clusters() (0 stays 0)
seg_recode_clusters <- function(cluster, map) {
  out <- as.integer(cluster)
  nz <- out != 0
  out[nz] <- unname(map[as.character(out[nz])])
  out
}

# Agreement after matching, corrected Rand index and VI of two groupings
seg_compare_clusters <- function(a, b) {
  agreement <- mean(seg_recode_clusters(a, seg_match_clusters(a, b)) == b)
  if (length(unique(a)) < 2 && length(unique(b)) < 2) {
    return(list(agreement = agreement, corrected_rand = NA_real_, vi = NA_real_))
  }
  cmp <- fpc::cluster.stats(
    NULL,
    as.integer(factor(a)),
    as.integer(factor(b)),
    compareonly = TRUE
  )
  list(
    agreement = agreement,
    corrected_rand = cmp$corrected.rand,
    vi = max(cmp$vi, 0)
  )
}

# Renumber the clusters of a solution (sizes, centers, assignment,
# memberships, labels, mapping of the fit and plots)
seg_recode_solution <- function(object, map) {
  if (length(map) == 0 || all(names(map) == as.character(map))) {
    return(object)
  }
  recode <- function(cl) seg_recode_clusters(cl, map)

  object$cluster <- recode(object$cluster)
  object$assignment$cluster <- recode(object$assignment$cluster)
  object$sizes <- object$sizes |>
    dplyr::mutate(cluster = recode(.data$cluster)) |>
    dplyr::arrange(.data$cluster == 0, .data$cluster)
  object$centers <- object$centers |>
    dplyr::mutate(cluster = recode(.data$cluster)) |>
    dplyr::arrange(.data$cluster)

  if (!is.null(object$membership)) {
    membership <- seg_place_columns(object$membership, map)
    colnames(membership) <- paste0("cluster_", seq_len(ncol(membership)))
    object$membership <- membership
  }
  if (!is.null(object$cluster_labels)) {
    names(object$cluster_labels) <- recode(as.integer(names(object$cluster_labels)))
  }
  # Codes of the fit -> aligned codes (used by predict())
  object$cluster_map <- if (is.null(object$cluster_map)) {
    map
  } else {
    stats::setNames(
      unname(map[as.character(object$cluster_map)]),
      names(object$cluster_map)
    )
  }

  if (length(object$plots) > 0) {
    object$plots <- seg_cluster_plots(
      object,
      seg_plot_opts(TRUE, list(), list(), 200),
      object$settings$seed
    )
  }
  object
}

# Move the columns of a matrix to new positions: column j (names(map)) to
# column map[j]; columns without a new position fill the free positions in
# their original order
seg_place_columns <- function(m, map) {
  n_col <- max(ncol(m), map, 0)
  out <- matrix(0, nrow = nrow(m), ncol = n_col)
  old <- as.integer(names(map))
  keep <- old <= ncol(m)
  out[, map[keep]] <- m[, old[keep]]
  rest <- setdiff(seq_len(ncol(m)), old)
  free <- setdiff(seq_len(n_col), map[keep])
  out[, free[seq_along(rest)]] <- m[, rest]
  out
}

# Cross table of the aligned clusters of a solution with the reference
seg_aligned_crosstab <- function(cl, ref, ref_name) {
  codes <- sort(unique(c(cl, ref)))
  codes <- c(codes[codes != 0], codes[codes == 0])
  code_names <- ifelse(codes == 0, "Noise", paste("Cluster", codes))
  table(
    factor(cl, levels = codes, labels = code_names),
    factor(ref, levels = codes, labels = code_names),
    dnn = c("Cluster", ref_name)
  )
}

# Heatmap of the pairwise agreement
seg_agreement_plot <- function(mat) {
  labels <- rownames(mat)
  d <- tibble::tibble(
    solution_1 = factor(rep(labels, times = length(labels)), levels = labels),
    solution_2 = factor(rep(labels, each = length(labels)), levels = rev(labels)),
    agreement = as.vector(mat)
  )
  ggplot2::ggplot(
    d,
    ggplot2::aes(x = .data$solution_1, y = .data$solution_2, fill = .data$agreement)
  ) +
    ggplot2::geom_tile(color = "white", linewidth = 0.8) +
    ggplot2::geom_text(
      ggplot2::aes(label = paste0(round(100 * .data$agreement), "%")),
      size = 3.5
    ) +
    ggplot2::scale_fill_gradient(
      low = "white",
      high = yougov_colors[["Red 1"]],
      limits = c(0, 1),
      labels = \(v) paste0(100 * v, "%"),
      name = "Agreement"
    ) +
    ggplot2::labs(
      title = "Agreement between cluster solutions",
      subtitle = "Share of respondents in matched clusters",
      x = NULL,
      y = NULL
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.line = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(angle = 30, hjust = 1)
    )
}
