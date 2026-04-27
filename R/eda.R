#' Exploratory data analysis: Summary of data
#'
#' @description
#' Generate a summary table of the data, including variable types, missing values, and basic statistics. The summary is displayed in the browser for easy inspection.
#'
#' @param data A data frame to be inspected.
#' @param variables An optional vector of variable names to include in the inspection. If NULL, all variables are included.
#' @param console_output A logical value indicating whether to print descriptive statistics in the console. Defaults to TRUE.
#' @param browser_output A logical value indicating whether to display the summary table in the browser. Defaults to TRUE.
#' @param dfSummary_args A list of additional arguments passed to [summarytools::dfSummary()].
#' @param describe_distribution_args A list of additional arguments passed to [datawizard::describe_distribution()].
#'
#' @returns A temporary html summary table of the data, which is displayed in the browser.
#'
#' @export
#' @examplesIf requireNamespace("haven", quietly = TRUE)
#' # Inspect a subset of variables in the data
#' eda_summary(data = bkw_missings, variables = c("F600", "F800_1", "F800_2"), console_output = TRUE, browser_output = FALSE)
eda_summary <- function(
  data,
  variables = NULL,
  console_output = TRUE,
  browser_output = TRUE,
  describe_distribution_args = list(iqr = FALSE, quartiles = TRUE, by = NULL)
) {
  if (!is.null(variables)) {
    data <- data[variables]
  }

  # Create summary table
  d_summary <- summarytools::dfSummary(x = data, varnumbers = FALSE)

  if (browser_output) {
    cli::cli_h1("Data Frame Summary")
    cli::cli_alert_info(
      "Summary table is displayed in the browser. Please check your browser windows or tabs."
    )
    # Display summary table in browser
    summarytools::view(d_summary, method = "browser", silent = TRUE)
  }

  if (console_output) {
    # Print summary table in console
    if (!browser_output) {
      cli::cli_h1("Data Frame Summary")
      print(d_summary)
    }

    # Create descriptive statistics table
    d_descriptive <- do.call(
      datawizard::describe_distribution,
      c(list(x = haven::zap_labels(data)), describe_distribution_args)
    )

    # Print descriptive statistics table in console
    cli::cli_h1("Descriptive Statistics")
    print(d_descriptive)
  }
}

#' Exploratory data analysis: correlation
#'
#' @description
#' Compute and visualize correlations between variables.
#'
#' @param data A data frame.
#' @param variables Optional. A character vector of variable names to include in the correlation analysis. If `NULL`, all variables are used.
#' @param correlation_type Optional. Can be `"pearson"`, `"spearman"`, or `"tetrachoric"` (useful if variables are binary) among others. Check `method` argument in [correlation::correlation()] to see all options. Defaults to `"pearson"`.
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
