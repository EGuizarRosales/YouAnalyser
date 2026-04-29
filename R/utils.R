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

#' Choose an existing directory and define a new file in this directory, returning the full file path
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
  dir_path <- tcltk::tk_choose.dir()

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

#' Choose a file and return its path
#'
#' @returns A single string representing the full file path of the chosen file. The function normalizes the file path to use forward slashes and ensures that the selected file exists.
#'
#' @export
ya_choose_file <- function() {
  file_path <- tcltk::tk_choose.files()
  if (is.na(file_path) || is.null(file_path)) {
    stop("File selection was cancelled or failed.", call. = FALSE)
  }
  normalizePath(file_path, winslash = "/", mustWork = TRUE)
}

#' Set up a standardized folder structure for a project
#'
#' @description Set up a standardized folder structure for a project, including subfolders for input data, scripts, and output. Optionally, copy a template script into the scripts folder and create an R project file in the main folder. The function provides informative messages about the created folder structure and any actions taken.
#'
#' @param base_path A single string specifying the base directory where the folder structure should be created.
#' @param folder_name A single string specifying the name of the main folder to be created within the base directory. This folder will contain the standardized subfolder structure for organizing project files.
#' @param template Optional. A single string specifying the name of the template file to be copied into the scripts folder. The template should be an R script located in the "templates" directory of the YouAnalyser package. Currently, `"kda"` is supported
#' @param make_rproj Optional. A logical value indicating whether to create an R project file in the main folder. Defaults to TRUE.
#'
#' @returns NULL, invisibly. The function creates a standardized folder structure for a project at the specified location and optionally copies a template script and creates an R project file. Informative messages about the created folder structure are printed to the console.
#'
#' @export
ya_setup_folder_structure <- function(
  folder_name,
  base_path = tcltk::tk_choose.dir(),
  template = NULL,
  make_rproj = TRUE
) {
  base_path <- fs::path(base_path, folder_name)

  # Data
  fs::dir_create(
    fs::path(base_path, "01_input", "data", "raw"),
    recurse = TRUE
  )
  fs::dir_create(
    fs::path(base_path, "01_input", "data", "processed"),
    recurse = TRUE
  )
  # Scripts
  fs::dir_create(fs::path(base_path, "02_scripts"), recurse = TRUE)

  if (!is.null(template)) {
    template <- paste0(template, ".R")
    template_path <- system.file("templates", template, package = "YouAnalyser")
    if (template_path == "") {
      cli::cli_abort(
        "Template {.val {template}} not found in YouAnalyser package."
      )
    }
    fs::file_copy(
      path = template_path,
      new_path = fs::path(base_path, "02_scripts", template)
    )
  }

  # Output
  fs::dir_create(fs::path(base_path, "03_output", "data"), recurse = TRUE)
  fs::dir_create(fs::path(base_path, "03_output", "plots"), recurse = TRUE)
  fs::dir_create(fs::path(base_path, "03_output", "reports"), recurse = TRUE)

  # Make the projet an R project
  if (make_rproj) {
    usethis::create_project(
      path = base_path,
      rstudio = rstudioapi::isAvailable(),
      open = rlang::is_interactive()
    )
  }

  # Feedback to user
  cli::cli_inform(
    c(
      "v" = "Folder structure created:",
      "i" = "Folder tree:"
    )
  )
  fs::dir_tree(base_path)

  if (!is.null(template)) {
    cli::cli_inform(
      c(
        "i" = "Open the {.val {template}} template to get started: {.path {fs::path(base_path, '02_scripts', template)}}"
      )
    )
  }
}

#' Save a plot to JPEG
#'
#' @description
#' Saves a plot object as a JPEG file to the specified file path.
#' The function ensures that the directory exists (creating it if necessary)
#' and provides options for customizing the plot dimensions, resolution,
#' and whether to use the showtext package for rendering unicode characters.
#' Informative messages about the saved plot can also be printed if `verbose`
#' is set to TRUE.
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
  if (!grepl("\\.jpeg$", file_path, ignore.case = TRUE)) {
    cli::cli_abort("{.arg file_path} must end with {.val .jpeg}.")
  }

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

# Re-exports -------------------------------------------------------------------

#' @importFrom parameters model_parameters
#' @export
parameters::model_parameters

#' @importFrom datawizard data_codebook
#' @export
datawizard::data_codebook
