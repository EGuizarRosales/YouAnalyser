d_mice <- sm_synthetic[1:300, ]

prep_mice <- function(...) {
  seg_prep_data(
    d_mice,
    vars = dplyr::starts_with("F50_0_"),
    id = "id",
    missing = "mice",
    max_missing_prop = 0.2,
    compute_distance = FALSE,
    verbose = FALSE,
    ...
  )
}

test_that("mice imputation is reproducible with seed", {
  expect_gt(prep_mice()$info$n_imputed_values, 0)
  expect_identical(prep_mice()$data, prep_mice()$data)
  expect_identical(prep_mice(seed = 42)$data, prep_mice(seed = 42)$data)
  expect_false(identical(prep_mice(seed = 1)$data, prep_mice(seed = 2)$data))
  expect_equal(prep_mice(seed = 42)$settings$seed, 42)
})

test_that("the default seed reproduces mice(seed = 123)", {
  vars <- names(prep_mice()$data)
  raw <- seg_numeric_vars(prep_mice()$data_full, vars, "x")
  imp <- mice::mice(
    as.data.frame(raw),
    m = 1,
    method = "pmm",
    seed = 123,
    printFlag = FALSE
  )
  expected <- seg_apply_scaling(
    tibble::as_tibble(mice::complete(imp, 1)),
    prep_mice()$settings$scaling
  )
  expect_equal(prep_mice()$data, expected, ignore_attr = TRUE)
})

test_that("mice imputation leaves the global random seed untouched", {
  set.seed(1)
  before <- .Random.seed
  prep_mice()
  expect_identical(.Random.seed, before)
})

test_that("imputation_args are added to the defaults, keeping the seed", {
  p <- prep_mice(imputation_args = list(method = "cart"))
  expect_equal(p$settings$imputation_args$method, "cart")
  expect_false(p$settings$imputation_args$printFlag)
  expect_equal(p$settings$seed, 123)
  expect_identical(
    p$data,
    prep_mice(imputation_args = list(method = "cart"))$data
  )
})

test_that("a seed in imputation_args takes precedence over seed", {
  p <- prep_mice(imputation_args = list(seed = 7), seed = 99)
  expect_equal(p$settings$seed, 7)
  expect_null(p$settings$imputation_args$seed)
  expect_identical(p$data, prep_mice(seed = 7)$data)
})

test_that("invalid seeds are rejected", {
  expect_error(prep_mice(seed = "a"), "single number")
  expect_error(prep_mice(seed = c(1, 2)), "single number")
  expect_error(prep_mice(imputation_args = "pmm"), "must be a list")
})

test_that("predict() uses the seed and leaves the global seed untouched", {
  prep <- prep_mice(seed = 42)
  cl <- seg_cluster(prep, "kmeans", k = 3, plots = FALSE, verbose = FALSE)
  expect_equal(cl$prep$seed, 42)

  new <- sm_synthetic[301:340, ]
  new$F50_0_1[1:5] <- NA
  set.seed(1)
  before <- .Random.seed
  p1 <- predict(cl, new, verbose = FALSE)
  expect_identical(.Random.seed, before)
  expect_identical(p1, predict(cl, new, verbose = FALSE))
})
