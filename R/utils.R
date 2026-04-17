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

#' Save a plot to JPEG
#'
#' @description
#' A short description...
#'
#' @param plot A plot object.
#' @param fileName A single string specifying the file path.
#' @param width Optional. A numeric value for plot width in centimeters. Defaults to 30 cm.
#' @param height Optional. A numeric value for plot height in centimeters. Defaults to 15 cm.
#' @param resolution Optional. A numeric value for resolution in DPI. Defaults to 300 dpi.
#' @param use_showtext Optional. A logical indicating whether to use showtext for unicode rendering. Defaults to FALSE.
#' @param verbose Optional. A logical indicating whether to print informative messages about the saved plot. Defaults to FALSE.
#'
#' @returns
#' NULL, invisibly. The plot is saved as a JPEG file to the specified path. If the directory does not exist, it is created.
#'
#' @export
ya_save_plot <- function(
  plot,
  fileName,
  width = 30,
  height = 15,
  resolution = 300,
  use_showtext = FALSE,
  verbose = FALSE
) {
  # Ensure the directory exists
  dir_path <- fs::path_dir(fileName)
  if (!fs::dir_exists(dir_path)) {
    fs::dir_create(dir_path, recurse = TRUE)
  }

  # Use package showtext to correctly render unicode like arrows
  if (use_showtext) {
    showtext::showtext_opts(dpi = 600)
    showtext::showtext_auto(TRUE)
  }

  # Save the plot
  jpeg(
    filename = fileName,
    width = width,
    height = height,
    units = "cm",
    res = resolution
  )
  plot(plot)
  invisible(dev.off())

  if (verbose) {
    cli::cli_inform(
      c(
        "v" = "Plot saved to {.path {fs::path_norm(fileName)}}",
        "i" = "Dimensions: {width} cm × {height} cm at {resolution} dpi"
      )
    )
  }

  if (use_showtext) {
    showtext::showtext_auto(FALSE)
  }
}

# Re-exports -------------------------------------------------------------------

#' @importFrom parameters model_parameters
#' @export
parameters::model_parameters
