bkw_labelled <- haven::read_sav(ya_example(
  "bkw.sav"
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
  # Filter for rows with non-missing values in the dependent variable (F600)
  dplyr::filter(!is.na(F600))

# Remove variable labels to create an unlabelled version of the data
bkw_unlabelled <- bkw_labelled |>
  haven::zap_labels()

# Save variable labels and value labels
bkw_labels <- sjlabelled::get_label(bkw_labelled) |>
  tibble::enframe(name = "variable", value = "variable_label") |>
  dplyr::mutate(
    value_labels = unname(sjlabelled::get_labels(bkw_labelled, values = "p"))
  ) |>
  tidyr::unnest(value_labels) |>
  tidyr::separate_wider_delim(
    cols = value_labels,
    delim = "] ",
    names = c("value", "value_label")
  ) |>
  dplyr::mutate(value = as.numeric(stringr::str_remove_all(value, "\\[|\\]")))

# Save unlabelled data as well as data labels as .csv and .xlsx.
write.csv(bkw_unlabelled, "inst/extdata/bkw_unlabelled.csv", row.names = FALSE)
write.csv(bkw_labels, "inst/extdata/bkw_labels.csv", row.names = FALSE)
openxlsx::write.xlsx(bkw_unlabelled, "inst/extdata/bkw_unlabelled.xlsx")
openxlsx::write.xlsx(bkw_labels, "inst/extdata/bkw_labels.xlsx")

# Make the unlabelled data as well as data labels available in the package
usethis::use_data(bkw_unlabelled, overwrite = TRUE)
usethis::use_data(bkw_labels, overwrite = TRUE)
