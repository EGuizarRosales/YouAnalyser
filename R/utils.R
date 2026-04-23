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

#' Choose a directory and create a file path
#'
#' @param file_name A single string specifying the file name to be appended to the chosen directory path.
#'
#' @returns A single string representing the full file path, combining the chosen directory and the provided file name. The function normalizes the directory path to use forward slashes and ensures that the specified directory exists.
#'
#' @export
#' @examplesIf interactive()
#' ya_choose_file_path("my_plot.jpg")
ya_choose_file_path <- function(file_name) {
  # Get directory path
  dir_path <- choose.dir()

  # Check if directory selection was cancelled or failed
  if (is.na(dir_path) || is.null(dir_path)) {
    stop("Directory selection was cancelled or failed.", call. = FALSE)
  }

  # Normalize path and combine with filename
  file.path(
    normalizePath(dir_path, winslash = "/", mustWork = TRUE),
    file_name
  )
}

#' Save a plot to JPEG
#'
#' @description
#' A short description...
#'
#' @param plot A plot object.
#' @param file_path A single string specifying the file path.
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
  file_path,
  width = 30,
  height = 15,
  resolution = 300,
  use_showtext = FALSE,
  verbose = TRUE
) {
  # Ensure the directory exists
  dir_path <- fs::path_dir(file_path)
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
    filename = file_path,
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
        "v" = "Plot saved to {.path {fs::path_norm(file_path)}}",
        "i" = "Dimensions: {width} cm × {height} cm at {resolution} dpi"
      )
    )
  }

  if (use_showtext) {
    showtext::showtext_auto(FALSE)
  }
}

#' Save data for chart in Excel template
#'
#' @param ipma_scatterPlot_data The data frame containing the data used for the IPMA scatter plot. This should be the output of the `ipma_scatterPlot` element in the list returned by `kda_regression()`.
#' @param file_path A single string specifying the file path where the Excel file will be saved.
#'
#' @returns NULL, invisibly. The data is saved to an Excel file at the specified path, using a predefined template. If the directory does not exist, it is created.
#'
#' @export
ya_save_data_for_chart <- function(ipma_scatterPlot_data, file_path) {
  # Select relevant columns for the chart
  data_for_chart <- ipma_scatterPlot_data |>
    dplyr::select(
      predictor_nr,
      label,
      Importance_Ratio,
      Performance_Ratio
    )

  # Read in the xlsx template
  template_wb <- ya_example("kda_template.xlsx") |>
    openxlsx::loadWorkbook()

  # Write the data to the template
  openxlsx::writeData(
    template_wb,
    sheet = "Sheet1",
    x = data_for_chart,
    startCol = 1,
    startRow = 5,
    colNames = FALSE
  )

  # Save the filled template to the specified file path
  openxlsx::saveWorkbook(
    template_wb,
    file_path,
    overwrite = TRUE
  )

  cli::cli_inform(
    c(
      "v" = "Data saved to {.path {fs::path_norm(file_path)}}"
    )
  )
}

#' Copy PowerPoint template to specified file path
#'
#' @param file_path A single string specifying the file path where the PowerPoint template will be copied to.
#'
#' @returns NULL, invisibly. The PowerPoint template is copied to the specified file path. If the directory does not exist, it is created.
#'
#' @export
ya_copy_template <- function(file_path) {
  template_path <- ya_example("kda_template.pptx")
  fs::file_copy(template_path, file_path, overwrite = TRUE)
  cli::cli_inform(
    c(
      "v" = "PowerPoint template copied to {.path {fs::path_norm(file_path)}}"
    )
  )
}

# Re-exports -------------------------------------------------------------------

#' @importFrom parameters model_parameters
#' @export
parameters::model_parameters
