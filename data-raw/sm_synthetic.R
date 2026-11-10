# Synthetic example data for segmentation (cluster analysis), based on the
# Swissmilk "Milch & Umwelt 2024" study (137241). Only the 2024 wave is used.

# Grouping variables that are synthesised as factors
factor_vars <- c("cluster_benchmark", "gender", "age_group", "region", "education")

# Read in the raw data, keep the 2024 wave, select and rename relevant variables
sm_raw <- haven::read_sav(
  ya_example("sm_realData.sav"),
  user_na = TRUE
) |>
  dplyr::filter(welle == 5) |>
  dplyr::select(
    weight,
    cluster_benchmark = KSEG_2024,
    gender = Ban1_1,
    age,
    age_group = Ban1_2,
    region = Ban1_3,
    education = Ban1_5,
    dplyr::num_range("F50_0_", 1:20),
    dplyr::num_range("F1_0_", 1:10),
    dplyr::num_range("F50c_", 1:4),
    F4_1,
    dplyr::matches("^F40_0_[1-8]_(1|2|3|99)$"),
    dplyr::num_range("F12_0_", c(1:7, 9))
  ) |>
  haven::zap_missing()

# Recode "weiss nicht / keine Angabe" (99) to NA and drop the 99 value label.
# Only applied to variables whose value labels contain code 99.
sm_raw <- sm_raw |>
  dplyr::mutate(dplyr::across(dplyr::everything(), \(x) {
    lbls <- attr(x, "labels", exact = TRUE)
    if (is.null(lbls) || !99 %in% lbls) {
      return(x)
    }
    x[x == 99] <- NA
    attr(x, "labels") <- lbls[lbls != 99]
    x
  }))

# Save variable and value labels (as named code vectors) for later use
variable_labels <- sjlabelled::get_label(sm_raw)
value_labels <- purrr::map(sm_raw, \(x) attr(x, "labels", exact = TRUE))

# Prepare data for use in synthpop
data_for_synthpop <- sm_raw |>
  dplyr::mutate(dplyr::across(dplyr::all_of(factor_vars), \(x) {
    haven::as_factor(x, levels = "labels") |> droplevels()
  })) |>
  dplyr::mutate(dplyr::across(-dplyr::all_of(factor_vars), \(x) {
    as.numeric(haven::zap_labels(x))
  })) |>
  as.data.frame()

# Apply synthpop to generate synthetic data. The benchmark cluster is
# synthesised first so that all other variables are conditioned on it.
syn_obj <- synthpop::syn(
  data = data_for_synthpop,
  method = "cart",
  visit.sequence = c(
    "cluster_benchmark",
    setdiff(names(data_for_synthpop), "cluster_benchmark")
  ),
  m = 1,
  k = nrow(data_for_synthpop),
  seed = 123
)

# Compare synthetic with real data
# synthpop::compare(syn_obj, data_for_synthpop, stat = "counts")

# Save synthetic data as a tibble for further processing
sm_synthetic <- syn_obj$syn |>
  tibble::as_tibble()

# Convert the synthetic data back to labelled format, keeping original codes
f_convert_to_labelled <- function(data) {
  data |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        \(x) {
          col <- dplyr::cur_column()
          lbls <- value_labels[[col]]
          if (is.factor(x)) {
            # Map factor levels (= value labels) back to their original codes
            x <- unname(lbls[match(as.character(x), names(lbls))])
          }
          x <- as.double(x)
          if (!is.null(lbls)) {
            x <- x |>
              sjlabelled::set_labels(labels = lbls) |>
              sjlabelled::as_labelled()
          }
          sjlabelled::set_label(x, label = variable_labels[[col]])
        }
      )
    ) |>
    dplyr::mutate(
      id = sjlabelled::set_label(
        as.double(dplyr::row_number()),
        label = "Unique Identifier"
      )
    ) |>
    dplyr::relocate(id)
}

sm_synthetic <- f_convert_to_labelled(sm_synthetic)

# Make data available for further use in the package
haven::write_sav(sm_synthetic, "./inst/extdata/sm_synthetic.sav")
usethis::use_data(sm_synthetic, overwrite = TRUE)
