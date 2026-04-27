bkw_processed <- haven::read_sav(ya_example(
  "bkw_missings.sav"
)) |>
  # Select only the variables used in the regression model
  dplyr::select(
    F600,
    F800_1,
    F800_2,
    F800_3,
    F800_4,
    F800_5,
    F800_6,
    F800_7,
    F800_8,
    F800_9,
    F800_10,
    F800_11,
    F800_12,
    F800_13,
    F800_14
  ) |>
  # Filter for rows with non-missing values in the outcome or predictor varialbes
  tidyr::drop_na()

usethis::use_data(bkw_processed, overwrite = TRUE)
