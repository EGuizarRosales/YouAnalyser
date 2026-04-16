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

inspect_correlation <- function(
  data,
  variables = NULL,
  correlation_type = "pearson",
  ...
) {
  if (!is.null(variables)) {
    data <- data[variables]
  }

  d_corr <- correlation::correlation(
    data = data,
    method = correlation_type,
    ...
  )

  p_corr <- GGally::ggcorr(
    data = NULL,
    cor_matrix = as.matrix(d_corr),
    geom = "circle",
    max_size = 10,
    min_size = 2,
    size = 3,
    hjust = 0.75,
    nbreaks = 6,
    angle = -45,
    label = FALSE,
    low = yougov_colors[["Blue 1"]],
    mid = yougov_colors[["Purple 1"]],
    high = yougov_colors[["Red 1"]],
    drop = false
  )

  return(list(
    d = d_corr,
    p = p_corr
  ))
}
