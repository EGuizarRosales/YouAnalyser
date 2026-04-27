# Read in the raw data, select relevant variables, and filter out rows with
# missing values in F600
bkw_raw <- haven::read_sav(ya_example(
  "bkw_realData.sav"
)) |>
  dplyr::select(
    country = Qcountry,
    cluster = S01_04_05,
    F600,
    starts_with("F800_")
  ) |>
  dplyr::filter(!is.na(F600))

# Save variable and value labels for later use
variable_labels <- sjlabelled::get_label(bkw_raw)
value_labels <- sjlabelled::get_labels(bkw_raw)

# Prepare data for use in synthpop
data_for_synthpop <- bkw_raw |>
  dplyr::mutate(dplyr::across(c("country", "cluster"), \(x) {
    haven::as_factor(x)
  })) |>
  dplyr::mutate(dplyr::across(-c("country", "cluster"), \(x) {
    haven::zap_labels(x)
  }))

# Apply synthpop to generate synthetic data and compare it with the original data
syn_obj <- synthpop::syn(
  data = data_for_synthpop,
  method = "cart",
  visit.sequence = c(
    "country",
    "cluster",
    paste0("F800_", 1:14),
    "F600"
  ),
  m = 1,
  k = nrow(data_for_synthpop),
  seed = 123
)

# Compare synthetic with real data
# synthpop::compare(syn_obj, data_for_synthpop, stat = "counts")

# Save synthetic data as a tibble for further processing
bkw_synthetic <- syn_obj$syn |>
  tibble::as_tibble()

# Create a data frame with missing values to test the handling of missing data
bkw_synthetic_missings <- bkw_synthetic

# Dummy code factors for use in mice::ampute
cluster_levels <- sort(unique(bkw_synthetic$cluster))

stopifnot(length(cluster_levels) == 6)

cluster_dummies <- stats::model.matrix(
  ~ factor(cluster, levels = cluster_levels) - 1,
  data = bkw_synthetic
) |>
  as.data.frame() |>
  rlang::set_names(paste0("cluster_", seq_len(6)))

bkw_synthetic_missings <- bkw_synthetic |>
  dplyr::bind_cols(tibble::as_tibble(cluster_dummies)) |>
  dplyr::select(-cluster) |>
  dplyr::mutate(
    country = dplyr::case_when(
      country == "CH" ~ 0,
      country == "DE" ~ 1,
    )
  )

# Apply mice::ampute to introduce missing values in all variables
bkw_synthetic_missings <- withr::with_seed(123, {
  mice::ampute(
    data = bkw_synthetic_missings,
    prop = 0.05,
    mech = "MAR",
  )$amp
})


bkw_synthetic_missings <- bkw_synthetic_missings |>
  dplyr::mutate(
    cluster = factor(
      cluster_levels[
        max.col(
          as.matrix(dplyr::pick(dplyr::starts_with("cluster_"))),
          ties.method = "first"
        )
      ],
      levels = cluster_levels
    ),
    country = factor(
      ifelse(country == 0, "CH", "DE"),
      levels = c("CH", "DE")
    )
  ) |>
  dplyr::select(-dplyr::starts_with("cluster_")) |>
  dplyr::relocate(cluster, .after = country)


# Convert the synthetic data back to haven::labelled format
f_convert_to_labelled <- function(data) {
  data |>
    dplyr::mutate(
      dplyr::across(c("country", "cluster"), as.double)
    ) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        \(x) {
          col <- dplyr::cur_column()
          var_label <- variable_labels[[col]]
          raw_labels <- value_labels[[col]]
          codes <- seq_along(raw_labels)
          val_labels <- setNames(codes, raw_labels)
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

bkw_synthetic <- f_convert_to_labelled(bkw_synthetic)
bkw_missings <- f_convert_to_labelled(bkw_synthetic_missings)

# Make data available for furhter use in the package
haven::write_sav(bkw_synthetic, "./inst/extdata/bkw_synthetic.sav")
haven::write_sav(bkw_missings, "./inst/extdata/bkw_missings.sav")
usethis::use_data(bkw_synthetic, overwrite = TRUE)
usethis::use_data(bkw_missings, overwrite = TRUE)
