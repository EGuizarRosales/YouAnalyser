# Read in the raw data, select relevant variables
deka_raw <- haven::read_sav(ya_example(
  "deka_realData.sav"
)) |>
  dplyr::select(q120, q117, q118)

# Take a random subsample with replacement of 1000 rows
withr::with_seed(123, {
  deka_sample <- deka_raw |>
    dplyr::slice_sample(n = 1000, replace = TRUE)
})

usethis::use_data(deka_sample, overwrite = TRUE)
