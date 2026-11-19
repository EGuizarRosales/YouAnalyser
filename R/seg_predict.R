# Assignment of new respondents to an existing cluster solution:
# predict() methods for seg_cluster and seg_cluster_set


# ---- predict() ---------------------------------------------------------------

#' Assign new respondents to the clusters of a solution
#'
#' Assigns new respondents (e.g. a new survey wave, a holdout sample or a
#' short "golden question" screener) to the clusters of an existing cluster
#' solution from [seg_cluster()], and optionally returns their membership
#' probabilities.
#'
#' @details
#' ## Preparation of the new data
#'
#' The new respondents are prepared exactly like the respondents of the
#' solution in [seg_prep_data()], using the parameters of the original sample
#' (never statistics of the new data):
#'
#' 1. The clustering variables are selected from `newdata` (other columns are
#'    ignored) and value labels are removed.
#' 2. Respondents without any valid answer, or with more missing values than
#'    `max_missing_prop`, are not assigned (`NA`).
#' 3. Missing values are handled with the strategy of [seg_prep_data()]:
#'    * `"omit"`: respondents with missing values are not assigned (`NA`).
#'    * `"mean"` / `"median"`: imputed with the means / medians of the
#'      original sample.
#'    * `"mice"`: the new respondents are appended to the original sample
#'      and imputed with [mice::mice()], where the imputation model is
#'      estimated on the original sample only (argument `ignore`) and the
#'      settings of `imputation_args` and the `seed` of [seg_prep_data()] are
#'      reused, so that the imputation is reproducible.
#' 4. The variables are rescaled with the means and standard deviations
#'    (`scale = "z"`) or the minima and ranges (`scale = "range"`) of the
#'    original sample.
#'
#' ## Assignment rules
#'
#' Each method assigns new respondents in the way that is consistent with how
#' it formed the clusters (`rule = NULL`, the default):
#'
#' * k-means and hierarchical k-means (`"centroid"`): the cluster with the
#'   nearest center (Euclidean distance), as in the assignment step of
#'   k-means. Additional column: `distance` to that center.
#' * PAM (`"medoid"`): the cluster with the nearest medoid, using the distance
#'   measure of [seg_prep_data()]. Additional column: `distance` to that
#'   medoid.
#' * AGNES and DIANA (`"linkage"`): the cluster the respondent would be merged
#'   with first under the linkage of the solution:
#'   * `"ward"`: the smallest increase of the within-cluster sum of squares,
#'     \eqn{\frac{n_c}{n_c + 1}(\bar{d^2}(x, c) - W_c)}{n_c / (n_c + 1) *
#'     (mean d(x, c)^2 - W_c)}, computed from the distances only (for
#'     Euclidean distances: the nearest center, weighted by cluster size),
#'   * `"average"`, `"weighted"`, `"gaverage"` and DIANA: the smallest
#'     average distance to the members of the cluster,
#'   * `"complete"`: the smallest maximum distance,
#'   * `"single"`: the nearest member.
#'
#'   Additional column: `distance`, the linkage distance (for Ward on the
#'   scale of the dendrogram heights).
#' * Fuzzy clustering (`"membership"`): membership degrees that minimize the
#'   objective function of [cluster::fanny()] for the new respondent, with
#'   the memberships of the original sample fixed. With the membership
#'   exponent \eqn{r}{r} and \eqn{a_c(x) = \sum_j u_{jc}^r d(x, j) / \sum_j
#'   u_{jc}^r - \sum_{i,j} u_{ic}^r u_{jc}^r d(i, j) / (2 (\sum_j
#'   u_{jc}^r)^2)}{a_c(x) = sum_j u_jc^r d(x, j) / sum_j u_jc^r - sum_ij
#'   u_ic^r u_jc^r d(i, j) / (2 (sum_j u_jc^r)^2)}, the membership in cluster
#'   \eqn{c}{c} is proportional to \eqn{a_c(x)^{-1/(r-1)}}{a_c(x)^(-1 / (r -
#'   1))}. The respondent is assigned to the cluster with the highest
#'   membership. Additional column: `membership_max`.
#' * Model-based clustering (`"model"`): posterior probabilities of the
#'   fitted Gaussian mixture model ([mclust::predict.Mclust()]); the
#'   respondent is assigned to the most probable cluster. Additional column:
#'   `uncertainty` (1 - highest probability).
#' * DBSCAN (`"density"`): the cluster of the nearest clustered (non-noise)
#'   respondent of the original sample if it lies within `eps`, otherwise
#'   noise (0), as in `dbscan::predict()`.
#' * HDBSCAN (`"density"`): the cluster of the nearest clustered respondent of
#'   the original sample if it lies within that respondent's core distance,
#'   otherwise noise (0), as in `dbscan::predict()`. Both density rules use the
#'   distance measure of [seg_prep_data()]. Additional column: `distance` to
#'   the nearest clustered respondent.
#' * Existing segmentations from [seg_as_cluster()] (`"centroid"`).
#'
#' Two alternative rules can be chosen for every method:
#'
#' * `rule = "centroid"`: nearest cluster center (Euclidean distance).
#' * `rule = "knn"`: majority vote of the `neighbors` nearest respondents of
#'   the original sample (distance measure of [seg_prep_data()]; ties are
#'   resolved by the smallest summed distance). The share of votes per
#'   cluster is returned as probabilities with `type = "prob"`, the highest
#'   share as `knn_share`.
#'
#' ## Consistency with the original assignment
#'
#' Applied to the respondents of the original sample, the rules of k-means,
#' hierarchical k-means, PAM, fuzzy clustering (memberships), model-based
#' clustering (probabilities) and the density-based methods reproduce the
#' original assignment. For AGNES and DIANA, the linkage rule reproduces it
#' for most, but not all respondents (typically 80-90%), as the clusters are
#' formed by successively merging groups and cutting the tree, so that their
#' borders do not follow a simple rule for single respondents. `rule = "knn"`
#' often agrees more closely with the original assignment of these methods.
#'
#' With `missing = "mice"`, passing the original sample as `newdata`
#' re-imputes its missing values, so that respondents with imputed values may
#' be assigned differently. Use `newdata = NULL` for the original assignment.
#'
#' @param object A cluster solution of class `seg_cluster`, e.g. from
#'   [seg_cluster()].
#' @param newdata A data frame with the new respondents. It must contain the
#'   (original, unprepared) clustering variables, e.g. the same columns as the
#'   data passed to [seg_prep_data()]. If `NULL` (default), the assignment of
#'   the original sample is returned.
#' @param type `"cluster"` (default) for the assigned cluster, or `"prob"` to
#'   add the membership probabilities (`prob_cluster_1`, `prob_cluster_2`,
#'   ...). Probabilities are available for fuzzy clustering, model-based
#'   clustering and `rule = "knn"`.
#' @param rule Assignment rule: `NULL` (default) for the rule of the
#'   clustering method (see "Assignment rules"), `"centroid"`, `"knn"`, or
#'   `"linkage"` (AGNES and DIANA only).
#' @param neighbors Number of nearest neighbors for `rule = "knn"`. Defaults
#'   to 10.
#' @param id Name of an identifier column in `newdata` to be included in the
#'   result. Defaults to the identifier of [seg_prep_data()] if `newdata`
#'   contains it, otherwise the row number (column `row`).
#' @param labels Logical. Whether to add the cluster labels of an existing
#'   segmentation ([seg_as_cluster()]) as value labels to `cluster`. Defaults
#'   to `TRUE`.
#' @param verbose Logical. Whether to report respondents that could not be
#'   assigned. Defaults to `TRUE`.
#' @param ... Not used.
#'
#' @returns A tibble with one row per row of `newdata` (in the same order),
#'   with the identifier, the assigned `cluster` (`NA` for respondents who
#'   could not be assigned, 0 for noise of density-based methods), the
#'   rule-specific information (see "Assignment rules") and, for
#'   `type = "prob"`, the membership probabilities.
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' # Solution on one half of the sample, assignment of the other half
#' train <- sm_synthetic[1:600, ]
#' new <- sm_synthetic[601:nrow(sm_synthetic), ]
#'
#' prep <- seg_prep_data(
#'   train,
#'   vars = dplyr::starts_with("F50_0_"),
#'   id = "id",
#'   missing = "mean",
#'   verbose = FALSE
#' )
#' cl <- seg_cluster(prep, k = 4, plots = FALSE, verbose = FALSE)
#'
#' pred <- predict(cl, new)
#' pred
#' table(pred$cluster, useNA = "ifany")
#'
#' # Membership probabilities of fuzzy clustering
#' cl_fuzzy <- seg_cluster(prep, "fuzzy", k = 3, plots = FALSE, verbose = FALSE)
#' predict(cl_fuzzy, new, type = "prob")
#'
#' # Alternative rule: 10 nearest neighbors
#' predict(cl, new, rule = "knn", type = "prob")
#' }
#'
#' @export
predict.seg_cluster <- function(
  object,
  newdata = NULL,
  type = c("cluster", "prob"),
  rule = NULL,
  neighbors = 10,
  id = NULL,
  labels = TRUE,
  verbose = TRUE,
  ...
) {
  type <- rlang::arg_match(type)
  if (is.null(object$prep)) {
    cli::cli_abort(c(
      "{.arg object} does not contain the preparation settings needed for {.fn predict}.",
      "i" = "It was probably created with an older version of YouAnalyser: re-run {.fn seg_cluster}."
    ))
  }
  rule <- seg_predict_rule(object, rule)
  if (
    !rlang::is_scalar_integerish(neighbors) ||
      neighbors < 1 ||
      neighbors > nrow(object$data)
  ) {
    cli::cli_abort(
      "{.arg neighbors} must be an integer between 1 and the number of respondents of the solution."
    )
  }
  if (type == "prob" && !rule %in% c("membership", "model", "knn")) {
    cli::cli_abort(c(
      "Probabilities are not available for {.val {object$method}} with rule {.val {rule}}.",
      "i" = "Use {.code type = \"prob\"} with fuzzy or model-based clustering, or {.code rule = \"knn\"}."
    ))
  }

  # Original sample
  if (is.null(newdata)) {
    if (rule != seg_predict_rule(object, NULL)) {
      cli::cli_abort(
        "{.arg rule} can only be changed for {.arg newdata}; without it, the original assignment is returned."
      )
    }
    out <- object$assignment
    if (type == "prob") {
      out <- dplyr::bind_cols(out, seg_prob_tibble(object$membership))
    }
    return(seg_label_clusters(out, object, labels))
  }

  new <- seg_prep_newdata(object, newdata)
  ids <- seg_predict_ids(object, newdata, id)

  res <- if (any(new$valid)) {
    seg_assign(
      object,
      as.matrix(new$data[new$valid, , drop = FALSE]),
      rule = rule,
      neighbors = as.integer(neighbors)
    )
  } else {
    list(cluster = integer(0), extra = NULL, prob = NULL)
  }

  n <- nrow(newdata)
  cluster <- rep(NA_integer_, n)
  cluster[new$valid] <- res$cluster
  out <- tibble::tibble(!!ids$name := ids$values, cluster = cluster)

  if (!is.null(res$extra)) {
    extra <- purrr::map(res$extra, \(v) {
      full <- rep(NA_real_, n)
      full[new$valid] <- v
      full
    })
    out <- dplyr::bind_cols(out, tibble::as_tibble(extra))
  }
  if (type == "prob") {
    k <- ncol(res$prob %||% object$membership)
    prob <- matrix(NA_real_, nrow = n, ncol = k)
    if (any(new$valid)) {
      prob[new$valid, ] <- res$prob
    }
    out <- dplyr::bind_cols(out, seg_prob_tibble(prob))
  }

  if (verbose && any(!new$valid)) {
    cli::cli_inform(c(
      "i" = "{sum(!new$valid)} of {n} respondent{?s} could not be assigned (missing values) and {?has/have} {.code cluster = NA}."
    ))
  }

  seg_label_clusters(out, object, labels)
}


#' @rdname predict.seg_cluster
#' @export
predict.seg_cluster_set <- function(object, ...) {
  cli::cli_abort(c(
    "{.arg object} contains several cluster solutions.",
    "i" = "Choose one solution, e.g. {.code predict(object$solutions${names(object$solutions)[1]}, newdata)}."
  ))
}


# ---- Preparation of new data -------------------------------------------------

# Prepare new respondents with the settings of the original preparation.
# Returns the prepared clustering variables (all rows) and which rows can be
# assigned.
seg_prep_newdata <- function(object, newdata) {
  if (!is.data.frame(newdata)) {
    cli::cli_abort("{.arg newdata} must be a data frame.")
  }
  prep <- object$prep
  vars <- prep$vars

  missing_vars <- setdiff(vars, names(newdata))
  if (length(missing_vars) > 0) {
    cli::cli_abort(c(
      "{.arg newdata} must contain all clustering variables.",
      "x" = "Missing: {.val {missing_vars}}"
    ))
  }

  x <- seg_numeric_vars(newdata, vars, "newdata")

  # Respondents without valid answers or with too many missing values
  valid <- rowSums(!is.na(x)) > 0
  if (!is.null(prep$max_missing_prop)) {
    valid <- valid & rowMeans(is.na(x)) <= prep$max_missing_prop
  }

  # Missing values
  if (prep$missing == "omit") {
    valid <- valid & stats::complete.cases(x)
  } else if (prep$missing %in% c("mean", "median")) {
    for (v in vars) {
      x[[v]][is.na(x[[v]])] <- prep$impute_values[[v]]
    }
  } else if (prep$missing == "mice") {
    x <- seg_impute_newdata(object, x, valid)
  } else {
    cli::cli_abort(
      "New respondents cannot be prepared with {.code missing = \"{prep$missing}\"}."
    )
  }

  list(data = seg_apply_scaling(x, prep$scaling), valid = valid)
}

# Clustering variables as numeric columns (value labels removed)
seg_numeric_vars <- function(data, vars, arg) {
  x <- tibble::as_tibble(as.data.frame(data)[vars])
  non_numeric <- vars[!purrr::map_lgl(x, is.numeric)]
  if (length(non_numeric) > 0) {
    cli::cli_abort(c(
      "All clustering variables in {.arg {arg}} must be numeric.",
      "x" = "Non-numeric variable{?s}: {.val {non_numeric}}"
    ))
  }
  x[] <- lapply(x, \(v) as.numeric(haven::zap_labels(v)))
  x
}

# mice imputation of the new respondents: appended to the original sample,
# with the imputation model estimated on the original sample only
seg_impute_newdata <- function(object, x, valid) {
  if (!anyNA(x[valid, , drop = FALSE])) {
    return(x)
  }
  train <- seg_numeric_vars(object$data_full, object$prep$vars, "object")
  new <- x[valid, , drop = FALSE]
  n_train <- nrow(train)

  args <- object$prep$imputation_args %||%
    list(method = "pmm", printFlag = FALSE)
  args$m <- 1
  args$ignore <- c(rep(FALSE, n_train), rep(TRUE, nrow(new)))

  imp <- seg_with_seed(
    object$prep$seed,
    do.call(
      mice::mice,
      c(list(data = as.data.frame(dplyr::bind_rows(train, new))), args)
    )
  )
  completed <- mice::complete(imp, 1)[n_train + seq_len(nrow(new)), , drop = FALSE]
  if (anyNA(completed)) {
    cli::cli_abort(c(
      "Imputation of the new respondents with {.fn mice::mice} left missing values.",
      "i" = "Check for (nearly) collinear or constant variables."
    ))
  }
  x[valid, ] <- tibble::as_tibble(completed)
  x
}

# Identifier column of the result
seg_predict_ids <- function(object, newdata, id) {
  if (!is.null(id)) {
    if (!rlang::is_string(id) || !id %in% names(newdata)) {
      cli::cli_abort("{.arg id} must be the name of a column in {.arg newdata}.")
    }
  } else if (!is.null(object$prep$id) && object$prep$id %in% names(newdata)) {
    id <- object$prep$id
  }
  if (is.null(id)) {
    list(name = "row", values = seq_len(nrow(newdata)))
  } else {
    list(name = id, values = as.vector(haven::zap_labels(newdata[[id]])))
  }
}


# ---- Assignment rules --------------------------------------------------------

# Default rule of a method, or check of a user-supplied rule
seg_predict_rule <- function(object, rule) {
  default <- switch(
    object$family,
    partitioning = if (object$method == "pam") "medoid" else "centroid",
    hierarchical = "linkage",
    fuzzy = "membership",
    model = "model",
    density = "density",
    "centroid"
  )
  if (is.null(rule)) {
    return(default)
  }
  allowed <- unique(c(
    default,
    "centroid",
    "knn",
    if (object$family == "hierarchical") "linkage"
  ))
  if (!rlang::is_string(rule) || !rule %in% allowed) {
    cli::cli_abort(c(
      "Invalid {.arg rule} for {.val {object$method}}.",
      "i" = "Must be one of {.val {allowed}}."
    ))
  }
  rule
}

# Assign prepared new respondents (matrix) to the clusters of object.
# Returns the cluster codes, a list of additional columns and probabilities.
seg_assign <- function(object, new, rule, neighbors) {
  switch(
    rule,
    centroid = seg_assign_centroid(object, new),
    medoid = seg_assign_medoid(object, new),
    linkage = seg_assign_linkage(object, new),
    membership = seg_assign_fuzzy(object, new),
    model = seg_assign_model(object, new),
    density = seg_assign_density(object, new),
    knn = seg_assign_knn(object, new, neighbors)
  )
}

seg_assign_centroid <- function(object, new) {
  centers <- object$centers
  d <- seg_cross_dist(
    new,
    as.matrix(centers[colnames(new)]),
    distance = "euclidean",
    distance_engine = "get_dist"
  )
  nearest <- max.col(-d, ties.method = "first")
  list(
    cluster = as.integer(centers$cluster[nearest]),
    extra = list(distance = d[cbind(seq_len(nrow(d)), nearest)])
  )
}

seg_assign_medoid <- function(object, new) {
  train <- as.matrix(object$data)
  is_medoid <- object$assignment$is_medoid
  d <- seg_predict_dist(object, new, train[is_medoid, , drop = FALSE])
  nearest <- max.col(-d, ties.method = "first")
  list(
    cluster = object$cluster[is_medoid][nearest],
    extra = list(distance = d[cbind(seq_len(nrow(d)), nearest)])
  )
}

seg_assign_linkage <- function(object, new) {
  linkage <- if (object$method == "diana") "average" else object$settings$linkage
  d <- seg_predict_dist(object, new)
  clusters <- sort(unique(object$cluster))
  d_train <- if (linkage == "ward") as.matrix(object$dist) else NULL

  crit <- vapply(
    clusters,
    \(cc) {
      members <- object$cluster == cc
      dm <- d[, members, drop = FALSE]
      switch(
        linkage,
        ward = {
          n_c <- sum(members)
          w_c <- sum(d_train[members, members]^2) / (2 * n_c^2)
          # Increase in the within-cluster sum of squares, on the scale of
          # the dendrogram heights
          sqrt(pmax(2 * n_c / (n_c + 1) * (rowMeans(dm^2) - w_c), 0))
        },
        complete = apply(dm, 1, max),
        single = apply(dm, 1, min),
        rowMeans(dm)
      )
    },
    numeric(nrow(new))
  )
  crit <- matrix(crit, nrow = nrow(new))
  nearest <- max.col(-crit, ties.method = "first")
  list(
    cluster = as.integer(clusters[nearest]),
    extra = list(distance = crit[cbind(seq_len(nrow(crit)), nearest)])
  )
}

seg_assign_fuzzy <- function(object, new) {
  r <- object$settings$memb_exp
  # Columns without members (e.g. gaps after seg_agreement()) get membership 0
  used <- which(colSums(object$membership) > 0)
  u <- object$membership[, used, drop = FALSE]^r
  d_train <- as.matrix(object$dist)
  d <- seg_predict_dist(object, new)

  s <- colSums(u)
  within <- colSums(u * (d_train %*% u))
  a <- sweep(d %*% u, 2, s, "/")
  a <- sweep(a, 2, within / (2 * s^2), "-")

  # Membership proportional to a^(-1 / (r - 1)), computed on the log scale;
  # a value <= 0 (respondent at the core of a cluster) gives full membership
  prob <- t(apply(a, 1, \(ac) {
    if (any(ac <= 0)) {
      return(as.numeric(seq_along(ac) == which.min(ac)))
    }
    logu <- -log(ac) / (r - 1)
    w <- exp(logu - max(logu))
    w / sum(w)
  }))
  prob_used <- matrix(prob, nrow = nrow(new))
  prob <- matrix(0, nrow = nrow(new), ncol = ncol(object$membership))
  prob[, used] <- prob_used

  list(
    cluster = max.col(prob, ties.method = "first"),
    extra = list(membership_max = apply(prob, 1, max)),
    prob = prob
  )
}

seg_assign_model <- function(object, new) {
  rlang::check_installed("mclust", reason = "to assign respondents with model-based clustering.")
  z <- stats::predict(object$fit, newdata = new)$z
  z <- matrix(z, nrow = nrow(new))
  prob <- seg_map_membership(z, object$cluster_map)
  list(
    cluster = max.col(prob, ties.method = "first"),
    extra = list(uncertainty = 1 - apply(prob, 1, max)),
    prob = prob
  )
}

seg_assign_density <- function(object, new) {
  train <- as.matrix(object$data)
  clustered <- object$cluster != 0
  if (!any(clustered)) {
    return(list(
      cluster = rep(0L, nrow(new)),
      extra = list(distance = rep(NA_real_, nrow(new)))
    ))
  }
  d <- seg_predict_dist(object, new, train[clustered, , drop = FALSE])
  nearest <- max.col(-d, ties.method = "first")
  d_nearest <- d[cbind(seq_len(nrow(d)), nearest)]

  limit <- if (object$method == "dbscan") {
    object$settings$eps
  } else {
    object$fit$coredist[clustered][nearest]
  }
  cluster <- ifelse(
    d_nearest <= limit,
    object$cluster[clustered][nearest],
    0L
  )
  list(cluster = as.integer(cluster), extra = list(distance = d_nearest))
}

seg_assign_knn <- function(object, new, neighbors) {
  d <- seg_predict_dist(object, new)
  clusters <- sort(unique(object$cluster))
  k_cols <- max(ncol(object$membership %||% matrix(nrow = 0, ncol = 0)), max(clusters))

  votes <- t(apply(d, 1, \(di) {
    nn <- order(di)[seq_len(neighbors)]
    cl_nn <- object$cluster[nn]
    count <- vapply(clusters, \(cc) sum(cl_nn == cc), numeric(1))
    # Ties: smallest summed distance to the neighbors of the cluster
    dist_sum <- vapply(clusters, \(cc) sum(di[nn][cl_nn == cc]), numeric(1))
    winner <- order(-count, dist_sum)[1]
    c(winner = clusters[winner], count / neighbors)
  }))
  votes <- matrix(votes, nrow = nrow(new))

  # Probabilities of clusters 1..k (noise is not a cluster)
  prob <- matrix(0, nrow = nrow(new), ncol = k_cols)
  pos <- clusters > 0
  prob[, clusters[pos]] <- votes[, -1, drop = FALSE][, pos, drop = FALSE]

  list(
    cluster = as.integer(votes[, 1]),
    extra = list(knn_share = apply(votes[, -1, drop = FALSE], 1, max)),
    prob = prob
  )
}


# ---- Helpers -----------------------------------------------------------------

# Distances between new respondents and (a subset of) the original sample,
# with the distance measure of the solution
seg_predict_dist <- function(object, new, train = as.matrix(object$data)) {
  # Density-based methods without a stored distance matrix used Euclidean
  # distances on the prepared data
  if (object$family == "density" && is.null(object$dist)) {
    distance <- "euclidean"
    engine <- "get_dist"
  } else {
    distance <- object$settings$distance
    engine <- object$settings$distance_engine
  }
  seg_cross_dist(
    new,
    train,
    distance = distance,
    distance_engine = engine,
    ref = as.matrix(object$data),
    daisy_args = object$prep$daisy_args
  )
}

# Distance matrix between the rows of new and the rows of train (n_new x
# n_train), consistent with seg_distance(). The ranges of the Gower distance
# are taken from ref (the original sample).
seg_cross_dist <- function(
  new,
  train,
  distance = "euclidean",
  distance_engine = "get_dist",
  ref = train,
  daisy_args = list()
) {
  new <- as.matrix(new)
  train <- as.matrix(train)
  storage.mode(new) <- "double"
  storage.mode(train) <- "double"

  if (distance %in% c("pearson", "spearman", "kendall")) {
    d <- 1 - stats::cor(t(new), t(train), method = distance)
    return(matrix(d, nrow = nrow(new)))
  }

  if (distance_engine == "daisy") {
    unsupported <- setdiff(names(daisy_args), "weights")
    if (length(unsupported) > 0) {
      cli::cli_warn(c(
        "The {.fn cluster::daisy} argument{?s} {.arg {unsupported}} {?is/are} not used to assign new respondents.",
        "i" = "All clustering variables are treated as interval-scaled."
      ))
    }
    if (distance == "gower") {
      ranges <- apply(ref, 2, \(v) diff(range(v, na.rm = TRUE)))
      weights <- daisy_args$weights %||% rep(1, ncol(ref))
      weights <- rep_len(weights, ncol(ref))
      new <- sweep(new, 2, ranges, "/")
      train <- sweep(train, 2, ranges, "/")
      return(seg_rowwise_dist(new, train, \(diff) {
        ok <- !is.na(diff)
        w <- matrix(weights, nrow(diff), ncol(diff), byrow = TRUE) * ok
        rowSums(abs(diff) * w, na.rm = TRUE) / rowSums(w)
      }))
    }
  }

  if (distance == "canberra") {
    return(seg_canberra(new, train))
  }
  if (distance == "binary") {
    return(seg_binary(new, train))
  }

  p <- ncol(new)
  fun <- switch(
    distance,
    euclidean = ,
    minkowski = \(diff) sqrt(seg_scaled_sum(diff^2, p)),
    manhattan = \(diff) seg_scaled_sum(abs(diff), p),
    maximum = \(diff) apply(abs(diff), 1, max, na.rm = TRUE),
    cli::cli_abort("Distance {.val {distance}} is not supported for the assignment.")
  )
  seg_rowwise_dist(new, train, fun)
}

# Apply a distance function to the differences between each new respondent
# and all rows of train
seg_rowwise_dist <- function(new, train, fun) {
  d <- vapply(
    seq_len(nrow(new)),
    \(i) fun(sweep(train, 2, new[i, ])),
    numeric(nrow(train))
  )
  matrix(d, nrow = nrow(train)) |> t()
}

# Sum over the non-missing variables, scaled up to all p variables (as in
# stats::dist() and cluster::daisy())
seg_scaled_sum <- function(x, p) {
  n_ok <- rowSums(!is.na(x))
  rowSums(x, na.rm = TRUE) * p / n_ok
}

seg_canberra <- function(new, train) {
  p <- ncol(new)
  d <- vapply(
    seq_len(nrow(new)),
    \(i) {
      num <- abs(sweep(train, 2, new[i, ]))
      den <- sweep(abs(train), 2, abs(new[i, ]), "+")
      terms <- num / den
      terms[num == 0 & den == 0] <- NA
      seg_scaled_sum(terms, p)
    },
    numeric(nrow(train))
  )
  t(matrix(d, nrow = nrow(train)))
}

seg_binary <- function(new, train) {
  d <- vapply(
    seq_len(nrow(new)),
    \(i) {
      a <- matrix(new[i, ] != 0, nrow(train), ncol(train), byrow = TRUE)
      b <- train != 0
      any_on <- rowSums(a | b, na.rm = TRUE)
      differ <- rowSums(xor(a, b), na.rm = TRUE)
      ifelse(any_on == 0, 0, differ / any_on)
    },
    numeric(nrow(train))
  )
  t(matrix(d, nrow = nrow(train)))
}

# Reorder membership columns of the original clustering to the renumbered
# clusters (as in seg_relabel(); also for clusters aligned by seg_agreement())
seg_map_membership <- function(membership, map) {
  if (is.null(map)) {
    return(membership)
  }
  seg_place_columns(membership, map)
}

# Probabilities as tibble columns prob_cluster_1, prob_cluster_2, ...
seg_prob_tibble <- function(prob) {
  if (is.null(prob)) {
    cli::cli_abort("The solution has no membership probabilities.")
  }
  prob <- as.data.frame(unname(prob))
  names(prob) <- paste0("prob_cluster_", seq_len(ncol(prob)))
  tibble::as_tibble(prob)
}

# Cluster labels of existing segmentations as value labels
seg_label_clusters <- function(out, object, labels) {
  if (isTRUE(labels) && !is.null(object$cluster_labels)) {
    codes <- stats::setNames(
      as.integer(names(object$cluster_labels)),
      unname(object$cluster_labels)
    )
    out$cluster <- sjlabelled::set_labels(out$cluster, labels = codes) |>
      sjlabelled::as_labelled()
  }
  out
}
