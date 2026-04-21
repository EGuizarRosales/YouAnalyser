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


tmp <- function(data) {
  corr <- correlation::correlation(data)
  p <- ggplotify::as.ggplot(
    ~ corrplot::corrplot(as.matrix(corr)),
    envir = environment()
  )
  return(p)
}

tmp(bkw_processed)

myCor <- correlation::correlation(bkw_processed)

ggplotify::as.ggplot(
  ~ corrplot::corrplot(as.matrix(myCor))
)

################################################################################

# Sticker
img <- normalizePath(file.choose(), winslash = "/", mustWork = TRUE)
s <- hexSticker::sticker(
  img,
  s_x = 1,
  s_y = 0.75,
  s_width = 0.3,
  s_height = 0.4,
  package = "YouAnalyser",
  p_x = 1,
  p_y = 1.4,
  p_size = 18,
  p_color = "white",
  h_size = 1.2,
  h_fill = yougov_colors[["Red 1"]],
  h_color = "white",
  url = "eguizarrosales.github.io/YouAnalyser/",
  u_size = 3,
  u_color = "white",
  filename = stringr::str_replace(img, ".png", "_sticker.png")
)
