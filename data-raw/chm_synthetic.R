# Load example data, select and rename relevant variables, drop rows with missing values
chm_raw <- haven::read_sav(ya_example(
  "chm_realData.sav"
)) |>
  dplyr::select(
    cheap = "F240",
    expensive = "F250",
    tooExpensive = "F260",
    tooCheap = "F270",
    purchaseIntentionCheap = "F280",
    purchaseIntentionExpensive = "F290"
  ) |>
  dplyr::filter(dplyr::if_all(dplyr::everything(), \(x) {
    !(x == -7 | is.na(x) | x == 99)
  }))

# Save variable and value labels for later use
variable_labels <- sjlabelled::get_label(chm_raw)
value_labels <- sjlabelled::get_labels(chm_raw)

# Prepare data for use in synthpop
data_for_synthpop <- chm_raw |>
  dplyr::mutate(dplyr::across(dplyr::everything(), \(x) {
    haven::zap_labels(x)
  }))

# Apply synthpop to generate synthetic data and compare it with the original data
syn_obj <- synthpop::syn(
  data = data_for_synthpop,
  method = "cart",
  m = 1,
  k = nrow(chm_raw),
  seed = 123
)

# Compare synthetic with real data
# synthpop::compare(syn_obj, data_for_synthpop, stat = "counts")

# Save synthetic data as a tibble for further processing
chm_synthetic <- syn_obj$syn |>
  tibble::as_tibble()

# Convert the synthetic data back to haven::labelled format
f_convert_to_labelled <- function(data) {
  data |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        \(x) {
          col <- dplyr::cur_column()
          var_label <- variable_labels[[col]]
          raw_labels <- value_labels[[col]]
          if (is.null(raw_labels)) {
            # No value labels available for this column
            val_labels <- NULL
          } else {
            codes <- seq_along(raw_labels)
            val_labels <- setNames(codes, raw_labels)
          }
          haven::labelled(
            x,
            labels = val_labels,
            label = var_label
          )
        }
      )
    ) |>
    dplyr::mutate(
      id = haven::labelled(
        as.double(dplyr::row_number()),
        label = "Unique Identifier"
      )
    ) |>
    dplyr::relocate(id)
}
chm_synthetic <- f_convert_to_labelled(chm_synthetic)

# Finally, add a weighting variable and bring all variables into a custom order
chm_synthetic <- withr::with_seed(123, {
  chm_synthetic |>
    dplyr::mutate(
      weight = pmin(pmax(rnorm(dplyr::n(), mean = 1, sd = 0.7 / 3), 0.5), 2)
    )
}) |>
  dplyr::select(
    id,
    weight,
    tooCheap,
    cheap,
    tooExpensive,
    expensive,
    purchaseIntentionCheap,
    purchaseIntentionExpensive
  )

# Make data available for further use in the package
usethis::use_data(chm_synthetic, overwrite = TRUE)
