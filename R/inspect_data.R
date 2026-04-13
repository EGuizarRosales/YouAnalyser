#' Inspect data
#'
#' @param data A data frame to be inspected.
#' @param variables An optional vector of variable names to include in the inspection. If NULL, all variables are included.
#'
#' @returns
#'
#' @export
#' @examples
#' # Inspect a subset of variables in the data
#' inspect_data(kda_example_data_01_raw, variables = c("F600", paste0("F800_", 1:14)))
#' # Inspect all variables in the data
#' inspect_data(kda_example_data_01_processed)
inspect_data <- function(data, variables = NULL) {
  if (!is.null(variables)) {
    data <- data[variables]
  }

  # Create summary table
  d_summary <- summarytools::dfSummary(data)

  # Display summary table in browser
  summarytools::view(d_summary, method = "browser")
}
