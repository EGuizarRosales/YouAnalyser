kda_example_data_01_raw <- haven::read_sav(ya_example(
  "kda_example_data_01.sav"
))

usethis::use_data(kda_example_data_01_raw, overwrite = TRUE)
