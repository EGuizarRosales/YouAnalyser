# Simulated survey data with a clear segment structure: 3 segments of 200
# respondents with distinct profiles on 20 rating items (1-10). Used to
# illustrate the segmentation (seg_) functions on data with known, well
# separated clusters (in contrast to sm_synthetic).

n_per_segment <- 200
n_items <- 20

# Mean profiles of the segments on the 20 items
profiles <- rbind(
  c(rep(8, 7), rep(3, 7), rep(5, 6)), # segment A: high on items 1-7
  c(rep(3, 7), rep(8, 7), rep(4, 6)), # segment B: high on items 8-14
  c(rep(5, 7), rep(4, 7), rep(8, 6)) # segment C: high on items 15-20
)

segment <- rep(seq_len(nrow(profiles)), each = n_per_segment)
n <- length(segment)

items <- withr::with_seed(123, {
  profiles[segment, ] +
    matrix(stats::rnorm(n * n_items, sd = 1.5), nrow = n)
})
items <- pmin(pmax(round(items), 1), 10) # rating scale 1-10
colnames(items) <- paste0("item_", seq_len(n_items))

# Value labels of the rating scale (endpoints only)
item_value_labels <- c(
  "1 - Strongly disagree" = 1,
  "10 - Strongly agree" = 10
)

item_labels <- paste0(
  "Simulated rating item ",
  seq_len(n_items),
  " (high in segment ",
  rep(c("A", "B", "C"), times = c(7, 7, 6)),
  ")"
)

sim_segments <- tibble::tibble(
  id = as.double(seq_len(n)),
  segment = as.double(segment)
) |>
  dplyr::bind_cols(tibble::as_tibble(items)) |>
  dplyr::mutate(
    id = sjlabelled::set_label(id, label = "Unique Identifier"),
    segment = segment |>
      sjlabelled::set_labels(
        labels = c("Segment A" = 1, "Segment B" = 2, "Segment C" = 3)
      ) |>
      sjlabelled::as_labelled() |>
      sjlabelled::set_label(label = "True segment (simulated)"),
    dplyr::across(
      dplyr::starts_with("item_"),
      \(x) {
        x |>
          sjlabelled::set_labels(labels = item_value_labels) |>
          sjlabelled::as_labelled() |>
          sjlabelled::set_label(
            label = item_labels[match(dplyr::cur_column(), colnames(items))]
          )
      }
    )
  )

# Make data available for further use in the package
haven::write_sav(sim_segments, "./inst/extdata/sim_segments.sav")
usethis::use_data(sim_segments, overwrite = TRUE)
