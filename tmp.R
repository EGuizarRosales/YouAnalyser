myModel_lm <- lm(F600 ~ ., data = bkw_processed)
myModel_glm <- glm(F600 ~ ., data = bkw_bin_outcome, family = binomial())

myModel_lm_reduced <- lm(
  F600 ~ F800_1 + F800_2 + F800_3 + F800_4 + F800_5,
  data = bkw_processed
)
myModel_glm_reduced <- glm(
  F600 ~ F800_1 + F800_2 + F800_3 + F800_4 + F800_5,
  data = bkw_bin_outcome,
  family = binomial()
)

bkw_bin_outcome_numeric <- bkw_bin_outcome |>
  dplyr::mutate(F600 = as.numeric(F600) - 1)

bkw_bin_numeric <- bkw_bin |>
  dplyr::mutate(dplyr::across(dplyr::everything(), \(x) as.numeric(x) - 1))

labels_bkw_bin <- sjlabelled::get_labels(bkw_bin)

bkw_bin_numeric_labelled <- sjlabelled::set_labels(
  bkw_bin_numeric,
  labels = labels_bkw_bin
)
sjlabelled::get_labels(bkw_bin_numeric_labelled)
