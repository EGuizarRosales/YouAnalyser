#' Exploratory data analysis: summary of data
#'
#' @description
#' Generate a summary table of the data, including variable types, missing values, and basic statistics. The summary is displayed in the browser for easy inspection.
#'
#' @param data A data frame to be inspected.
#' @param variables An optional vector of variable names to include in the inspection. If NULL, all variables are included.
#'
#' @returns A temporary html summary table of the data, which is displayed in the browser.
#'
#' @export
#' @examples
#' # Inspect a subset of variables in the data
#' eda_summary(bkw_raw, variables = c("F600", "F800_1", "F800_2"))
#' # Inspect all variables in the data
#' eda_summary(bkw_processed)
eda_summary <- function(data, variables = NULL) {
  if (!is.null(variables)) {
    data <- data[variables]
  }

  # Create summary table
  d_summary <- summarytools::dfSummary(data)

  # Display summary table in browser
  summarytools::view(d_summary, method = "browser")
}

#' Exploratory data analysis: correlation
#'
#' @description
#' Compute and visualize correlations between variables.
#'
#' @param data A data frame.
#' @param variables Optional. A character vector of variable names to include in the correlation analysis. If `NULL`, all variables are used.
#' @param correlation_type Optional. Can be `"pearson"`, `"spearman"`, or `"tetrachoric"` (useful if variables are binary). See [correlation::correlation()] to see all options. Defaults to `"pearson"`.
#' @param correlation_args Optional. A list of additional arguments passed to [correlation::correlation()].
#' @param ggcorr_args Optional. A list of arguments passed to [GGally::ggcorr()].
#'
#' @returns
#' A list with two elements: `d`, the correlation data frame, and `p`, a ggplot object visualizing the correlation matrix.
#'
#' @export
#' @examples
#' # Compute and visualize correlations for all variables in the data
#' eda_correlation(bkw_processed)
#' # Compute and visualize correlations for a subset of variables
#' eda_correlation(bkw_processed, variables = c("F600", "F800_1", "F800_2", "F800_3", "F800_4", "F800_5"))
#' # Use e.g. `correlation_type = "tetrachoric"` if variables are binary
#' eda_correlation(bkw_bin, correlation_type = "tetrachoric")
eda_correlation <- function(
  data,
  variables = NULL,
  correlation_type = "pearson",
  correlation_args = list(),
  ggcorr_args = list(
    label = TRUE,
    label_size = 2,
    low = yougov_colors[["Blue 1"]],
    mid = "white",
    high = yougov_colors[["Red 1"]]
  )
) {
  if (!is.null(variables)) {
    data <- data[variables]
  }

  partial_correlation <- purrr::partial(
    correlation::correlation,
    method = correlation_type,
    !!!correlation_args
  )

  partial_ggcorr <- purrr::partial(
    GGally::ggcorr,
    !!!ggcorr_args
  )

  d_corr <- partial_correlation(data)

  p_corr <- partial_ggcorr(
    data = NULL,
    cor_matrix = as.matrix(d_corr),
    name = paste0("r (", stringr::str_to_sentence(correlation_type), ")")
  )

  return(list(
    d = d_corr,
    p = p_corr
  ))
}
