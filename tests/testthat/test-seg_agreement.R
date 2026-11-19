skip_if_not_installed("clue")

prep <- seg_prep_data(
  sm_synthetic[1:400, ],
  vars = dplyr::starts_with("F50_0_"),
  id = "id",
  missing = "mean",
  verbose = FALSE
)
fit <- function(method, k = 3, ...) {
  seg_cluster(prep, method, k = k, ..., plots = FALSE, verbose = FALSE)
}
cl_km <- fit("kmeans")
cl_pam <- fit("pam")

# The k-means solution with permuted cluster numbers (not renumbered by size)
permuted <- function(cl, perm = c(3, 1, 2)) {
  seg_as_cluster(
    prep,
    perm[cl$cluster],
    relabel = FALSE,
    plots = FALSE,
    verbose = FALSE
  )
}


# Matching ---------------------------------------------------------------------

test_that("seg_match_clusters() recovers permuted cluster numbers", {
  y <- c(1, 1, 2, 2, 3, 3)
  x <- c(3, 3, 1, 1, 2, 2)
  map <- seg_match_clusters(x, y)
  expect_equal(map, c(`1` = 2L, `2` = 3L, `3` = 1L))
  expect_equal(seg_recode_clusters(x, map), as.integer(y))

  cmp <- seg_compare_clusters(x, y)
  expect_equal(cmp$agreement, 1)
  expect_equal(cmp$corrected_rand, 1)
  expect_equal(cmp$vi, 0)
})

test_that("unmatched clusters get new numbers by size, noise stays noise", {
  y <- c(1, 1, 1, 2, 2, 2, 2)
  x <- c(5, 5, 5, 7, 7, 9, 0)
  map <- seg_match_clusters(x, y)
  expect_equal(unname(map[c("5", "7")]), c(1L, 2L))
  expect_equal(unname(map["9"]), 3L)
  expect_equal(seg_recode_clusters(x, map)[7], 0L)
  expect_equal(seg_compare_clusters(x, y)$agreement, 5 / 7)
})

test_that("seg_place_columns() moves columns and fills gaps", {
  m <- matrix(1:6, nrow = 2) # columns 1, 2, 3
  expect_equal(seg_place_columns(m, c(`1` = 2L, `2` = 3L, `3` = 1L)), m[, c(3, 1, 2)])
  # Gap: clusters 1 and 2 moved to 1 and 3, column 3 without a cluster
  out <- seg_place_columns(m, c(`1` = 1L, `2` = 3L))
  expect_equal(out[, 1], m[, 1])
  expect_equal(out[, 3], m[, 2])
  expect_equal(out[, 2], m[, 3])
})


# seg_agreement() --------------------------------------------------------------

test_that("identical solutions with permuted numbers agree completely", {
  agr <- seg_agreement(list(km = cl_km, perm = permuted(cl_km)), verbose = FALSE)
  expect_s3_class(agr, "seg_agreement")
  expect_equal(agr$pairwise$agreement, 1)
  expect_equal(agr$pairwise$corrected_rand, 1)
  expect_equal(agr$aligned$perm$cluster, cl_km$cluster)
  expect_true(all(agr$respondents$all_agree))
  expect_equal(agr$settings$share_all_agree, 1)
})

test_that("aligned solutions are renumbered consistently", {
  agr <- seg_agreement(list(km = cl_km, pam = cl_pam), verbose = FALSE)
  pam <- agr$aligned$pam
  expect_equal(
    pam$sizes$n[match(1:3, pam$sizes$cluster)],
    as.vector(table(pam$cluster))
  )
  centers <- pam$data |>
    dplyr::mutate(cluster = pam$cluster) |>
    dplyr::summarise(dplyr::across(dplyr::everything(), mean), .by = "cluster") |>
    dplyr::arrange(.data$cluster)
  expect_equal(pam$centers, centers, ignore_attr = TRUE)
  expect_equal(pam$assignment$cluster, pam$cluster)

  # Diagonal of the cross table = agreement
  ct <- agr$crosstabs$pam
  expect_equal(sum(diag(ct)) / sum(ct), agr$pairwise$agreement)

  # predict() returns the aligned numbers
  expect_equal(predict(pam, pam$data_full, verbose = FALSE)$cluster, pam$cluster)
})

test_that("aligned fuzzy and model-based solutions keep consistent memberships", {
  cl_fz <- fit("fuzzy")
  agr <- seg_agreement(list(km = cl_km, fz = cl_fz), verbose = FALSE)
  fz <- agr$aligned$fz
  expect_equal(max.col(fz$membership, ties.method = "first"), fz$cluster)
  expect_equal(predict(fz, fz$data_full, verbose = FALSE)$cluster, fz$cluster)

  skip_if_not_installed("mclust")
  cl_mc <- fit("mclust")
  agr <- seg_agreement(list(km = cl_km, mc = cl_mc), verbose = FALSE)
  mc <- agr$aligned$mc
  expect_equal(max.col(mc$membership, ties.method = "first"), mc$cluster)
  expect_equal(predict(mc, mc$data_full, verbose = FALSE)$cluster, mc$cluster)
})

test_that("respondents, pairwise results and the matrix are consistent", {
  agr <- seg_agreement(
    list(km = cl_km, pam = cl_pam, ward = fit("agnes")),
    verbose = FALSE
  )
  expect_equal(nrow(agr$pairwise), 3)
  expect_equal(dim(agr$matrix), c(3, 3))
  expect_equal(unname(diag(agr$matrix)), rep(1, 3))
  expect_equal(agr$matrix["pam", "ward"], agr$matrix["ward", "pam"])

  r <- agr$respondents
  expect_named(
    r,
    c("id", "km", "pam", "ward", "modal_cluster", "n_agree", "share_agree", "all_agree")
  )
  expect_equal(r$id, cl_km$assignment$id)
  expect_equal(r$km, cl_km$cluster)
  expect_true(all(r$n_agree >= 2))
  expect_equal(r$all_agree, r$n_agree == 3)
  expect_s3_class(agr$plot, "ggplot")
})

test_that("the reference can be chosen by name", {
  agr <- seg_agreement(list(km = cl_km, pam = cl_pam), reference = "pam", verbose = FALSE)
  expect_equal(agr$settings$reference, "pam")
  expect_equal(agr$aligned$pam$cluster, cl_pam$cluster)
  expect_named(agr$crosstabs, "km")
})

test_that("seg_cluster_set objects are expanded and labelled", {
  set <- seg_cluster(prep, "kmeans", k = 2:3, plots = FALSE, verbose = FALSE)
  expect_warning(
    agr <- seg_agreement(list(set, pam = cl_pam), verbose = FALSE),
    "different numbers of clusters"
  )
  expect_equal(rownames(agr$matrix), c("k-means, k = 2", "k-means, k = 3", "pam"))
})

test_that("only respondents of all solutions are compared", {
  prep_omit <- seg_prep_data(
    sm_synthetic[1:400, ],
    vars = dplyr::starts_with("F50_0_"),
    id = "id",
    verbose = FALSE
  )
  cl_omit <- seg_cluster(prep_omit, "kmeans", k = 3, plots = FALSE, verbose = FALSE)
  expect_warning(
    agr <- seg_agreement(list(km = cl_km, omit = cl_omit), verbose = FALSE),
    "not part of all solutions"
  )
  expect_equal(agr$settings$n, nrow(cl_omit$assignment))
  expect_equal(agr$respondents$id, cl_omit$assignment$id[order(match(cl_omit$assignment$id, cl_km$assignment$id))])
})

test_that("informative errors", {
  expect_error(seg_agreement(cl_km), "at least two")
  expect_error(seg_agreement(list(cl_km, cl_pam), reference = "nope"), "name or position")
  expect_error(seg_agreement(list(cl_km, cl_pam), reference = 3), "name or position")

  other_id <- seg_cluster(
    seg_prep_data(sm_synthetic[1:400, ], vars = dplyr::starts_with("F50_0_"), missing = "mean", verbose = FALSE),
    "kmeans",
    k = 3,
    plots = FALSE,
    verbose = FALSE
  )
  expect_error(seg_agreement(list(cl_km, other_id)), "different respondent identifiers")
})
