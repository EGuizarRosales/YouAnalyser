myModel_lm <- lm(F600 ~ ., data = bkw_processed)
myModel_glm <- glm(F600 ~ ., data = bkw_bin_outcome, family = binomial())

################################################################################


saved_labels <- bkw_missings |>
  purrr::map(\(x) {
    list(
      var_label = attr(x, "label", exact = TRUE),
      val_labels = attr(x, "labels", exact = TRUE)
    )
  })

d <- bkw_missings |>
  dplyr::mutate(dplyr::across(dplyr::everything(), \(x) {
    x |>
      haven::zap_label() |>
      haven::zap_labels()
  }))

imp <- mice::mice(d, m = 10, method = "pmm", seed = 123, printFlag = FALSE)

cpl <- mice::complete(imp, action = "long", include = FALSE) |>
  tibble::as_tibble()

d_imputed <- cpl |>
  dplyr::select(-.imp, -.id) |>
  dplyr::summarise(
    dplyr::across(dplyr::everything(), \(x) quantile(x, probs = 0.5, type = 3)),
    .by = "id"
  )

d_imputed <- d_imputed |>
  dplyr::mutate(
    dplyr::across(
      dplyr::everything(),
      \(x) {
        current_var <- dplyr::cur_column()
        var_info <- saved_labels[[current_var]]

        if (is.null(var_info$val_labels) && is.null(var_info$var_label)) {
          x
        } else {
          haven::labelled(
            x,
            labels = var_info$val_labels,
            label = var_info$var_label
          )
        }
      }
    )
  )
