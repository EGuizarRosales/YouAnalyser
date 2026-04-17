ya_example <- function(path = NULL) {
  if (is.null(path)) {
    dir(system.file("extdata", package = "YouAnalyser"))
  } else {
    system.file("extdata", path, package = "YouAnalyser", mustWork = TRUE)
  }
}

ya_format_numeric <- function(x, digits = 2) {
  format(round(x, digits), nsmall = digits)
}

ya_get_predictor_labels <- function(model) {
  insight::get_predictors(model) |>
    sjlabelled::get_label() |>
    tibble::enframe(name = "predictor", value = "label") |>
    dplyr::mutate(label_withPred = paste0(predictor, ": ", label))
}

# Re-exports --------------------------------------------------------------------

#' @importFrom parameters model_parameters
#' @export
NULL
