#' Inspect data
#'
#' @param data A data frame to be inspected.
#' @param variables An optional vector of variable names to include in the inspection. If NULL, all variables are included.
#'
#' @returns A temporaty html summary table of the data, which is displayed in the browser.
#'
#' @export
#' @examples
#' # Inspect a subset of variables in the data
#' inspect_data(bkw_raw, variables = c("F600", "F800_1", "F800_2"))
#' # Inspect all variables in the data
#' inspect_data(bkw_processed)
inspect_data <- function(data, variables = NULL) {
  if (!is.null(variables)) {
    data <- data[variables]
  }

  # Create summary table
  d_summary <- summarytools::dfSummary(data)

  # Display summary table in browser
  summarytools::view(d_summary, method = "browser")
}
