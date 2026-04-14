bkw_raw <- haven::read_sav(ya_example(
  "bkw.sav"
))

usethis::use_data(bkw_raw, overwrite = TRUE)
