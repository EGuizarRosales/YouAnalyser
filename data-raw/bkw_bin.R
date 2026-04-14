label_outcome <- sjlabelled::get_label(bkw_processed$F600)
label_predictors <- sjlabelled::get_label(bkw_processed[paste0("F800_", 1:14)])

bkw_bin_outcome <- bkw_processed |>
  dplyr::mutate(F600 = ifelse(F600 >= 4, 1, 0)) |>
  dplyr::mutate(F600 = as.factor(F600)) |>
  dplyr::mutate(F600 = sjlabelled::set_label(F600, label_outcome)) |>
  dplyr::mutate(
    F600 = sjlabelled::set_labels(
      F600,
      labels = c("Nicht attraktiv" = 0, "Attraktiv" = 1)
    )
  )

bkw_bin_predictors <- bkw_processed |>
  dplyr::mutate(dplyr::across(
    dplyr::starts_with("F800_"),
    ~ ifelse(. >= 4, 1, 0)
  )) |>
  dplyr::mutate(dplyr::across(dplyr::starts_with("F800_"), as.factor)) |>
  dplyr::mutate(dplyr::across(
    dplyr::starts_with("F800_"),
    ~ sjlabelled::set_label(., label_predictors[dplyr::cur_column()])
  )) |>
  dplyr::mutate(dplyr::across(
    dplyr::starts_with("F800_"),
    ~ sjlabelled::set_labels(
      .,
      labels = c("Nicht gut" = 0, "Gut" = 1)
    )
  ))

bkw_bin <- dplyr::bind_cols(
  dplyr::select(bkw_bin_outcome, "F600"),
  dplyr::select(bkw_bin_predictors, dplyr::starts_with("F800_"))
)

usethis::use_data(bkw_bin_outcome, overwrite = TRUE)
usethis::use_data(bkw_bin_predictors, overwrite = TRUE)
usethis::use_data(bkw_bin, overwrite = TRUE)
