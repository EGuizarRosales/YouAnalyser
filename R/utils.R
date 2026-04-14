# Function to get the path to an example file in the package

#' Get the path to an example file in the package
#'
#' @param path A character string specifying the path to the example file within the package. If NULL, lists all available example files.
#'
#' @returns A character string with the full path to the specified example file, or a vector of character strings of available example files if path is NULL.
#'
#' @export
#' @examples
#' # List all available example files
#' ya_example()
#'
#' # Get the full path to a specific example file
#' ya_example("kda_example_data_01.sav")
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

# Re-exports --------------------------------------------------------------------

#' @importFrom parameters model_parameters
#' @export
NULL
