prep <- seg_prep_data(
  sm_synthetic[1:300, ],
  vars = dplyr::starts_with("F50_0_"),
  id = "id",
  missing = "mean",
  verbose = FALSE
)
cl <- seg_cluster(prep, "kmeans", k = 3, plots = FALSE, verbose = FALSE)
vars <- names(prep$data)

test_that("all types return ggplots based on the centers", {
  for (type in c("lines", "bars", "heatmap")) {
    p <- seg_plot_centers(cl, type = type)
    expect_s3_class(p, "ggplot")
  }
  d <- seg_plot_centers(cl)$data
  expect_equal(nrow(d), 3 * length(vars))
  centers <- tidyr::pivot_longer(cl$centers, -"cluster", names_to = "variable", values_to = "mean")
  merged <- dplyr::inner_join(
    dplyr::mutate(d, cluster = as.integer(.data$cluster), variable = as.character(.data$variable)),
    centers,
    by = c("cluster", "variable")
  )
  expect_equal(merged$mean.x, merged$mean.y)
})

test_that("the original scale uses the means of the original variables", {
  d <- seg_plot_centers(cl, scale = "original")$data
  raw <- seg_numeric_vars(cl$data_full, vars, "x")
  expected <- mean(raw[[vars[1]]][cl$cluster == 2], na.rm = TRUE)
  got <- d$mean[d$cluster == "Cluster 2" & d$variable == vars[1]]
  expect_equal(got, expected)
  expect_equal(
    unique(d$total[d$variable == vars[1]]),
    mean(raw[[vars[1]]], na.rm = TRUE)
  )
})

test_that("variables are ordered and labelled", {
  p <- seg_plot_centers(cl, order = "difference")
  spread <- apply(as.matrix(cl$centers[vars]), 2, \(v) max(v) - min(v))
  # First level at the top = last factor level
  expect_equal(rev(levels(p$data$variable))[1], names(which.max(spread)))

  labels_used <- ggplot2::ggplot_build(seg_plot_centers(cl, label_width = NULL))$layout$panel_params[[1]]$y$get_labels()
  expect_true(all(sjlabelled::get_label(prep$data_full[vars]) %in% labels_used))
  names_used <- ggplot2::ggplot_build(seg_plot_centers(cl, axis_labels = "name"))$layout$panel_params[[1]]$y$get_labels()
  expect_setequal(names_used, vars)
})

test_that("the heatmap has a total column without fill", {
  d <- seg_plot_centers(cl, type = "heatmap")$data
  expect_true("Total" %in% d$cluster)
  expect_true(all(is.na(d$difference[d$cluster == "Total"])))
  d_no <- seg_plot_centers(cl, type = "heatmap", total = FALSE)$data
  expect_false("Total" %in% d_no$cluster)
})

test_that("cluster labels of existing segmentations are used", {
  bm <- seg_as_cluster(prep, "cluster_benchmark", plots = FALSE, verbose = FALSE)
  d <- seg_plot_centers(bm)$data
  expect_true(all(grepl(": ", levels(d$cluster))))
})

test_that("solutions get a centers plot, customizable with centers_args", {
  cl_p <- seg_cluster(
    prep,
    "kmeans",
    k = 3,
    centers_args = list(type = "bars", scale = "original"),
    verbose = FALSE
  )
  expect_s3_class(cl_p$plots$centers, "ggplot")
  expect_true(inherits(cl_p$plots$centers$facet, "FacetWrap"))
  expect_match(cl_p$plots$centers$labels$subtitle, "original scale")
  expect_null(cl$plots$centers) # plots = FALSE

  bm <- seg_as_cluster(prep, "cluster_benchmark", centers_args = list(type = "heatmap"), verbose = FALSE)
  expect_s3_class(bm$plots$centers, "ggplot")
})

test_that("invalid arguments are rejected", {
  expect_error(seg_plot_centers(cl, type = "pie"))
  expect_error(seg_plot_centers(list()), "seg_cluster")
})
