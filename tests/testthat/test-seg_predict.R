# Fixtures --------------------------------------------------------------------

d_train <- sm_synthetic[1:400, ]
d_new <- sm_synthetic[401:600, ]

# Deterministic preparation (mean imputation): predicting the original sample
# must reproduce the original assignment
prep_mean <- seg_prep_data(
  d_train,
  vars = dplyr::starts_with("F50_0_"),
  id = "id",
  missing = "mean",
  verbose = FALSE
)

fit <- function(prep, method, ...) {
  seg_cluster(prep, method, ..., plots = FALSE, verbose = FALSE)
}

agreement <- function(cl, ...) {
  p <- predict(cl, cl$data_full, verbose = FALSE, ...)
  mean(p$cluster == cl$cluster)
}


# Distances -------------------------------------------------------------------

test_that("seg_cross_dist() matches seg_distance() for all distances", {
  set.seed(1)
  m <- matrix(rnorm(60), nrow = 15)
  for (d in seg_get_dist_methods) {
    ref <- unname(as.matrix(seg_distance(m, d, "get_dist")))
    expect_equal(seg_cross_dist(m, m, d, "get_dist"), ref, info = d)
  }
  for (d in seg_daisy_methods) {
    ref <- unname(as.matrix(seg_distance(m, d, "daisy")))
    expect_equal(seg_cross_dist(m, m, d, "daisy"), ref, info = d)
  }
  m[3, 2] <- NA
  ref <- unname(as.matrix(seg_distance(m, "gower", "daisy")))
  expect_equal(seg_cross_dist(m, m, "gower", "daisy"), ref)
})

test_that("Gower distances of new respondents use the ranges of the original sample", {
  train <- matrix(c(0, 10, 5, 0, 1, 2), ncol = 2)
  new <- matrix(c(20, 0), ncol = 2)
  # Ranges 10 and 2: (|20 - 0| / 10 + |0 - 0| / 2) / 2 = 1
  expect_equal(seg_cross_dist(new, train, "gower", "daisy")[1, 1], 1)
})


# Preparation -----------------------------------------------------------------

test_that("seg_prep_data() stores the rescaling and imputation parameters", {
  s <- prep_mean$settings
  expect_s3_class(s$scaling, "tbl_df")
  expect_equal(s$scaling$var, names(prep_mean$data))
  expect_named(s$impute_values, names(prep_mean$data))

  raw <- seg_numeric_vars(prep_mean$data_full, names(prep_mean$data), "x")
  for (v in names(raw)) {
    raw[[v]][is.na(raw[[v]])] <- s$impute_values[[v]]
  }
  expect_equal(
    seg_apply_scaling(raw, s$scaling),
    tibble::as_tibble(prep_mean$data),
    ignore_attr = TRUE
  )
})

test_that("seg_cluster objects carry the preparation settings", {
  cl <- fit(prep_mean, "kmeans", k = 3)
  expect_equal(cl$prep$vars, names(prep_mean$data))
  expect_equal(cl$prep$missing, "mean")
  expect_length(cl$cluster_map, 3)
})


# Consistency with the original assignment ------------------------------------

test_that("centroid, medoid, fuzzy and model rules reproduce the original assignment", {
  for (m in c("kmeans", "hkmeans", "pam", "fuzzy")) {
    expect_equal(agreement(fit(prep_mean, m, k = 3)), 1, info = m)
  }
  skip_if_not_installed("mclust")
  expect_equal(agreement(fit(prep_mean, "mclust", k = 3)), 1)
})

test_that("fuzzy and model-based probabilities reproduce the memberships", {
  cl <- fit(prep_mean, "fuzzy", k = 3)
  p <- predict(cl, cl$data_full, type = "prob", verbose = FALSE)
  prob <- as.matrix(dplyr::select(p, dplyr::starts_with("prob_")))
  expect_equal(prob, cl$membership, ignore_attr = TRUE, tolerance = 1e-6)
  expect_equal(rowSums(prob), rep(1, nrow(prob)))

  skip_if_not_installed("mclust")
  # Posteriors from the final parameters vs. the last E-step of the EM
  # algorithm: small differences
  cl <- fit(prep_mean, "mclust", k = 3)
  p <- predict(cl, cl$data_full, type = "prob", verbose = FALSE)
  prob <- as.matrix(dplyr::select(p, dplyr::starts_with("prob_")))
  expect_lt(max(abs(prob - cl$membership)), 0.05)
})

test_that("density rules reproduce the original assignment", {
  skip_if_not_installed("dbscan")
  prep_sim <- seg_prep_data(
    sim_segments,
    vars = dplyr::starts_with("item_"),
    id = "id",
    verbose = FALSE
  )
  for (m in c("dbscan", "hdbscan")) {
    cl <- suppressWarnings(fit(prep_sim, m))
    expect_equal(agreement(cl), 1, info = m)
  }
})

test_that("linkage rules mostly reproduce hierarchical solutions", {
  for (lk in c("ward", "average", "complete", "single")) {
    cl <- fit(prep_mean, "agnes", k = 3, linkage = lk)
    expect_gt(agreement(cl), 0.6)
  }
  expect_gt(agreement(fit(prep_mean, "diana", k = 3)), 0.6)
})

test_that("the Ward criterion equals the size-weighted distance to the center", {
  cl <- fit(prep_mean, "agnes", k = 3, linkage = "ward")
  x <- as.matrix(cl$data)[1:5, ]
  centers <- as.matrix(cl$centers[-1])
  n <- cl$sizes$n[order(cl$sizes$cluster)]
  direct <- vapply(
    seq_len(nrow(centers)),
    \(v) sqrt(2 * n[v] / (n[v] + 1) * colSums((t(x) - centers[v, ])^2)),
    numeric(nrow(x))
  )
  expect_equal(seg_assign_linkage(cl, x)$extra$distance, apply(direct, 1, min))
})


# New respondents -------------------------------------------------------------

test_that("predictions have one row per new respondent, in order", {
  cl <- fit(prep_mean, "kmeans", k = 3)
  p <- predict(cl, d_new, verbose = FALSE)
  expect_s3_class(p, "tbl_df")
  expect_equal(nrow(p), nrow(d_new))
  expect_equal(p$id, as.vector(d_new$id), ignore_attr = TRUE)
  expect_named(p, c("id", "cluster", "distance"))
  expect_true(all(p$cluster %in% 1:3))
})

test_that("new respondents are rescaled with the parameters of the original sample", {
  cl <- fit(prep_mean, "kmeans", k = 3)
  # A single respondent (own SD undefined) is predicted like within a batch
  expect_equal(
    predict(cl, d_new[1, ], verbose = FALSE)$cluster,
    predict(cl, d_new, verbose = FALSE)$cluster[1]
  )
})

test_that("missing values are handled with the strategy of seg_prep_data()", {
  vars <- names(prep_mean$data)
  new <- d_new[1:3, ]
  new[[vars[1]]][1] <- NA

  # mean: imputed with the mean of the original sample
  cl <- fit(prep_mean, "kmeans", k = 3)
  filled <- new
  filled[[vars[1]]][1] <- prep_mean$settings$impute_values[[vars[1]]]
  expect_equal(
    predict(cl, new, verbose = FALSE)$cluster,
    predict(cl, filled, verbose = FALSE)$cluster
  )

  # omit: not assigned
  prep_omit <- seg_prep_data(
    d_train,
    vars = dplyr::starts_with("F50_0_"),
    id = "id",
    verbose = FALSE
  )
  cl_omit <- fit(prep_omit, "kmeans", k = 3)
  expect_message(p <- predict(cl_omit, new), "could not be assigned")
  expect_true(is.na(p$cluster[1]))
  expect_false(anyNA(p$cluster[-1]))

  # Respondents without any answer are never assigned
  empty <- new
  empty[1, vars] <- NA
  expect_true(is.na(predict(cl, empty, verbose = FALSE)$cluster[1]))
})

test_that("mice imputes new respondents with the model of the original sample", {
  prep_mice <- seg_prep_data(
    d_train,
    vars = dplyr::starts_with("F50_0_"),
    id = "id",
    missing = "mice",
    max_missing_prop = 0.2,
    verbose = FALSE
  )
  expect_false(is.null(prep_mice$settings$imputation_args))
  cl <- fit(prep_mice, "kmeans", k = 3)

  vars <- names(prep_mice$data)
  new <- d_new[stats::complete.cases(d_new[vars]), ][1:20, ]
  new[[vars[1]]][1:5] <- NA
  p1 <- predict(cl, new, verbose = FALSE)
  p2 <- predict(cl, new, verbose = FALSE)
  expect_identical(p1, p2) # reproducible (seed of seg_prep_data())
  expect_false(anyNA(p1$cluster[1:5]))

  # Complete respondents are not affected by the imputation
  complete <- stats::complete.cases(new[vars])
  expect_equal(
    p1$cluster[complete],
    predict(cl, new[complete, ], verbose = FALSE)$cluster
  )
})


# Rules, types and output -----------------------------------------------------

test_that("alternative rules and probabilities work", {
  cl <- fit(prep_mean, "agnes", k = 3)
  p <- predict(cl, d_new, rule = "knn", type = "prob", verbose = FALSE)
  prob <- as.matrix(dplyr::select(p, dplyr::starts_with("prob_")))
  expect_equal(ncol(prob), 3)
  expect_equal(unname(rowSums(prob)), rep(1, nrow(p)))
  expect_equal(p$knn_share, apply(prob, 1, max))

  p_c <- predict(cl, d_new, rule = "centroid", verbose = FALSE)
  expect_true(all(p_c$cluster %in% 1:3))
})

test_that("newdata = NULL returns the original assignment", {
  cl <- fit(prep_mean, "fuzzy", k = 3)
  expect_equal(predict(cl)$cluster, cl$cluster)
  expect_equal(ncol(predict(cl, type = "prob")), ncol(cl$assignment) + 3)
})

test_that("cluster labels of existing segmentations are kept", {
  bm <- seg_as_cluster(
    prep_mean,
    "cluster_benchmark",
    plots = FALSE,
    verbose = FALSE
  )
  p <- predict(bm, d_new, verbose = FALSE)
  expect_s3_class(p$cluster, "haven_labelled")
  expect_equal(
    sort(unname(sjlabelled::get_labels(p$cluster))),
    sort(unname(bm$cluster_labels))
  )
  expect_false(inherits(predict(bm, d_new, labels = FALSE)$cluster, "haven_labelled"))
})

test_that("informative errors", {
  cl <- fit(prep_mean, "kmeans", k = 3)
  expect_error(predict(cl, d_new, type = "prob"), "not available")
  expect_error(predict(cl, d_new, rule = "linkage"), "Invalid")
  expect_error(predict(cl, d_new[, 1:3]), "all clustering variables")
  expect_error(predict(cl, d_new, id = "nope"), "column")

  set <- seg_cluster(prep_mean, "kmeans", k = 2:3, plots = FALSE, verbose = FALSE)
  expect_error(predict(set, d_new), "several cluster solutions")

  old <- cl
  old$prep <- NULL
  expect_error(predict(old, d_new), "older version")
})
