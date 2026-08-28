#' @export
#' @importFrom pricesensitivitymeter psm_analysis
pricesensitivitymeter::psm_analysis

#' @export
#' @importFrom pricesensitivitymeter psm_analysis_weighted
pricesensitivitymeter::psm_analysis_weighted

#' Build a survey design object for weighted PSM analysis
#'
#' Wraps [survey::svydesign()] with an unclustered design (`ids = ~1`) and
#' weights taken from a column of `data`, for use with
#' [pricesensitivitymeter::psm_analysis_weighted()].
#'
#' @param data A data frame containing the price sensitivity meter data and
#'   the weight column.
#' @param weight_var String giving the name of the column in `data` that
#'   holds the survey weights.
#'
#' @returns A `survey.design` object, as returned by [survey::svydesign()].
#'
#' @export
#' @examples
#' \dontrun{
#' design <- psm_design_for_weighted(chm_synthetic, weight_var = "weight")
#' }
psm_design_for_weighted <- function(data, weight_var) {
  survey::svydesign(
    ids = ~1,
    weights = data[[weight_var]],
    data = data
  )
}

#' Plot Price Sensitivity Meter (van Westendorp) results
#'
#' Creates the classic van Westendorp price sensitivity meter plot (with the
#' four cumulative distribution curves, the indifference price point, the
#' optimal price point, and the acceptable price range), plus, when the
#' Newton-Miller-Smith (NMS) extension was used, the reach and revenue
#' optimization plots.
#'
#' @param output_psm A list as returned by
#'   [pricesensitivitymeter::psm_analysis()] or
#'   [pricesensitivitymeter::psm_analysis_weighted()].
#' @param xlim Numeric vector of length 2 giving the x-axis (price) limits
#'   passed to `ggplot2::coord_cartesian()`. Defaults to `NULL`, i.e. the
#'   full price range of the data.
#' @param currency_prefix String prefixed to the price axis labels via
#'   `scales::label_currency()`. Defaults to `"CHF "`.
#'
#' @returns A named list of `ggplot` objects: `psm` (the price sensitivity
#'   meter plot), `nms_reach` and `nms_revenue` (the NMS reach and revenue
#'   plots, or `NULL` if `output_psm$nms` is `FALSE`).
#'
#' @export
#' @examples
#' \dontrun{
#' psm_nms <- psm_analysis(
#'  data = as.data.frame(chm_synthetic),
#'  toocheap = "tooCheap",
#'  cheap = "cheap",
#'  expensive = "expensive",
#'  tooexpensive = "tooExpensive",
#'  pi_cheap = "purchaseIntentionCheap",
#'  pi_expensive = "purchaseIntentionExpensive",
#'  validate = TRUE
#' )
#' plots <- psm_plot(psm_result)
#' plots$psm
#' }
psm_plot <- function(output_psm, xlim = NULL, currency_prefix = "CHF ") {
  ##############################################################################
  # PSM PLOT
  ##############################################################################

  p_psm <- output_psm$data_vanwestendorp |>
    ggplot2::ggplot(ggplot2::aes(x = price)) +
    ggplot2::annotate(
      geom = "rect",
      xmin = output_psm$pricerange_lower,
      xmax = output_psm$pricerange_upper,
      ymin = 0,
      ymax = Inf,
      fill = "lightgrey",
      alpha = 0.4
    ) +
    ggplot2::geom_line(
      ggplot2::aes(
        y = ecdf_toocheap,
        colour = "too cheap",
        linetype = "too cheap"
      ),
      linewidth = 1
    ) +
    ggplot2::geom_line(
      ggplot2::aes(
        y = ecdf_tooexpensive,
        colour = "too expensive",
        linetype = "too expensive"
      ),
      linewidth = 1
    ) +
    ggplot2::geom_line(
      ggplot2::aes(
        y = ecdf_not_cheap,
        colour = "not cheap",
        linetype = "not cheap"
      ),
      linewidth = 1
    ) +
    ggplot2::geom_line(
      ggplot2::aes(
        y = ecdf_not_expensive, # line: not expensive
        colour = "not expensive",
        linetype = "not expensive"
      ),
      linewidth = 1
    ) +
    # Indifference Price Point (intersection of "cheap" and "expensive")
    ggrepel::geom_label_repel(
      data = data.frame(
        x = output_psm$idp,
        y = approx(
          x = output_psm$data_vanwestendorp$price,
          y = output_psm$data_vanwestendorp$ecdf_not_cheap,
          xout = output_psm$idp
        )$y,
        label = paste("IDP: ", round(output_psm$idp, 2))
      ),
      mapping = ggplot2::aes(x = x, y = y, label = label),
      fill = "white",
      color = yougov_colors[["Teal 1"]],
      alpha = 1,
      box.padding = 1,
      min.segment.length = 0
    ) +
    ggplot2::annotate(
      geom = "point",
      x = output_psm$idp,
      y = approx(
        x = output_psm$data_vanwestendorp$price,
        y = output_psm$data_vanwestendorp$ecdf_not_cheap,
        xout = output_psm$idp
      )$y,
      size = 5,
      stroke = 3,
      shape = "circle filled",
      colour = yougov_colors[["Teal 1"]],
      fill = NA
    ) +
    # Optimal Price Point (intersection of "too cheap" and "too expensive")
    ggrepel::geom_label_repel(
      data = data.frame(
        x = output_psm$opp,
        y = approx(
          x = output_psm$data_vanwestendorp$price,
          y = output_psm$data_vanwestendorp$ecdf_toocheap,
          xout = output_psm$opp
        )$y,
        label = paste("OPP: ", round(output_psm$opp, 2))
      ),
      mapping = ggplot2::aes(x = x, y = y, label = label),
      fill = "white",
      color = yougov_colors[["Teal 1"]],
      alpha = 1,
      box.padding = 1,
      min.segment.length = 0
    ) +
    ggplot2::annotate(
      geom = "point",
      x = output_psm$opp,
      y = approx(
        x = output_psm$data_vanwestendorp$price,
        y = output_psm$data_vanwestendorp$ecdf_toocheap,
        xout = output_psm$opp
      )$y,
      size = 5,
      stroke = 3,
      shape = "circle filled",
      colour = yougov_colors[["Teal 1"]],
      fill = "NA"
    ) +
    # Lower Pricne Range (intersection of "not cheap" and "too cheap")
    ggrepel::geom_label_repel(
      data = data.frame(
        x = output_psm$pricerange_lower,
        y = approx(
          x = output_psm$data_vanwestendorp$price,
          y = output_psm$data_vanwestendorp$ecdf_toocheap,
          xout = output_psm$pricerange_lower
        )$y,
        label = paste("LPR: ", round(output_psm$pricerange_lower, 2))
      ),
      mapping = ggplot2::aes(x = x, y = y, label = label),
      fill = "white",
      color = "darkgrey",
      alpha = 1,
      box.padding = 1,
      min.segment.length = 0
    ) +
    ggplot2::annotate(
      geom = "point",
      x = output_psm$pricerange_lower,
      y = approx(
        x = output_psm$data_vanwestendorp$price,
        y = output_psm$data_vanwestendorp$ecdf_toocheap,
        xout = output_psm$pricerange_lower
      )$y,
      size = 5,
      stroke = 3,
      shape = "circle filled",
      colour = "darkgrey",
      fill = "NA"
    ) +
    # Upper Pricne Range (intersection of "not expensive" and "too expensive")
    ggrepel::geom_label_repel(
      data = data.frame(
        x = output_psm$pricerange_upper,
        y = approx(
          x = output_psm$data_vanwestendorp$price,
          y = output_psm$data_vanwestendorp$ecdf_tooexpensive,
          xout = output_psm$pricerange_upper
        )$y,
        label = paste("UPR: ", round(output_psm$pricerange_upper, 2))
      ),
      mapping = ggplot2::aes(x = x, y = y, label = label),
      fill = "white",
      color = "darkgrey",
      alpha = 1,
      box.padding = 1,
      min.segment.length = 0
    ) +
    ggplot2::annotate(
      geom = "point",
      x = output_psm$pricerange_upper,
      y = approx(
        x = output_psm$data_vanwestendorp$price,
        y = output_psm$data_vanwestendorp$ecdf_tooexpensive,
        xout = output_psm$pricerange_upper
      )$y,
      size = 5,
      stroke = 3,
      shape = "circle filled",
      colour = "darkgrey",
      fill = "NA"
    ) +
    ggplot2::scale_colour_manual(
      name = "Legend",
      values = c(
        "too cheap" = yougov_colors[["Blue 1"]],
        "not cheap" = yougov_colors[["Blue 1"]],
        "not expensive" = yougov_colors[["Red 1"]],
        "too expensive" = yougov_colors[["Red 1"]]
      )
    ) +
    ggplot2::scale_linetype_manual(
      name = "Legend",
      values = c(
        "too cheap" = "dotted",
        "not cheap" = "solid",
        "not expensive" = "solid",
        "too expensive" = "dotted"
      )
    ) +
    ggplot2::scale_y_continuous(labels = scales::label_percent()) +
    ggplot2::scale_x_continuous(
      labels = scales::label_currency(prefix = currency_prefix)
    ) +
    ggplot2::coord_cartesian(xlim = xlim) +
    ggplot2::labs(
      x = "Price",
      y = "Share of Respondents",
      title = "Price Sensitivity Meter Plot",
      caption = "IDP: Indifference Price Point; OPP: Optimal Price Point; LPR: Lower Price Range; UPR: Upper Price Range"
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position = "bottom")

  p_nms_reach <- NULL
  p_nms_revenue <- NULL

  ##############################################################################
  # NMS EXTENSION PLOTS
  ##############################################################################

  if (output_psm$nms) {
    p_nms_reach <- output_psm$data_nms |>
      ggplot2::ggplot(ggplot2::aes(x = price)) +
      ggplot2::geom_line(ggplot2::aes(y = reach)) +
      ggplot2::geom_vline(
        xintercept = output_psm$price_optimal_reach,
        linetype = "dotted"
      ) +
      ggrepel::geom_label_repel(
        data = subset(output_psm$data_nms, reach == max(reach)),
        mapping = ggplot2::aes(x = price + 0.5, y = reach),
        label = paste(
          "Optimal Price:",
          round(output_psm$price_optimal_reach, 2)
        ),
        hjust = 0
      ) +
      ggplot2::scale_x_continuous(
        labels = scales::label_currency(prefix = currency_prefix)
      ) +
      ggplot2::coord_cartesian(xlim = xlim) +
      ggplot2::labs(
        x = "Price",
        y = "Likelihood to Buy (Reach)",
        title = "Price Sensitivity Meter: Price for Optimal Reach"
      ) +
      ggplot2::theme_bw()

    p_nms_revenue <- output_psm$data_nms |>
      ggplot2::ggplot(ggplot2::aes(x = price)) +
      ggplot2::geom_line(ggplot2::aes(y = revenue)) +
      ggplot2::geom_vline(
        xintercept = output_psm$price_optimal_revenue,
        linetype = "dotted"
      ) +
      ggrepel::geom_label_repel(
        data = subset(output_psm$data_nms, revenue == max(revenue)),
        mapping = ggplot2::aes(x = price + 0.5, y = revenue),
        label = paste(
          "Optimal Price:",
          round(output_psm$price_optimal_revenue, 2)
        ),
        hjust = 0
      ) +
      ggplot2::scale_x_continuous(
        labels = scales::label_currency(prefix = currency_prefix)
      ) +
      ggplot2::coord_cartesian(xlim = xlim) +
      ggplot2::labs(
        x = "Price",
        y = "Revenue",
        title = "Price Sensitivity Meter: Price for Optimal Revenue"
      ) +
      ggplot2::theme_bw()
  }

  return(list(
    psm = p_psm,
    nms_reach = p_nms_reach,
    nms_revenue = p_nms_revenue
  ))
}

#' Save PSM data for chart in Excel template
#'
#' @param output_psm A list as returned by
#'   [pricesensitivitymeter::psm_analysis()] or
#'   [pricesensitivitymeter::psm_analysis_weighted()].
#' @param file_path A single string specifying the file path where the Excel file will be saved.
#'
#' @returns NULL, invisibly. The data is saved to an Excel file at the specified path, using a predefined template. If the directory does not exist, it is created.
#'
#' @export
psm_save_data_for_chart <- function(output_psm, file_path) {
  # Select relevant columns for the chart
  # `price` may carry a `haven_labelled` class (from SPSS-style variable
  # labels), which openxlsx writes as text rather than a number. Coerce it
  # to plain numeric so it is stored correctly in the Excel file.
  data_for_chart_psm <- output_psm$data_vanwestendorp |>
    dplyr::select(
      price,
      `not cheap` = ecdf_not_cheap,
      `not expensive` = ecdf_not_expensive,
      `too cheap` = ecdf_toocheap,
      `too expensive` = ecdf_tooexpensive
    ) |>
    dplyr::mutate(price = as.numeric(price))
  if (output_psm$nms) {
    data_for_chart_reach <- output_psm$data_nms |>
      dplyr::select(price, reach) |>
      dplyr::mutate(price = as.numeric(price))
    data_for_chart_revenue <- output_psm$data_nms |>
      dplyr::select(price, revenue) |>
      dplyr::mutate(price = as.numeric(price))
  } else {
    data_for_chart_reach <- NULL
    data_for_chart_revenue <- NULL
  }

  # Read in the xlsx template
  template_wb <- ya_example("psm_template.xlsx") |>
    openxlsx::loadWorkbook()

  # Write data to a sheet, always clearing any pre-existing rows first (e.g.
  # sample data shipped with the template) so stale rows never survive when
  # `data` is NULL (no NMS extension) or shorter than what was there before.
  write_sheet_data <- function(wb, sheet, data, ncols) {
    openxlsx::deleteData(
      wb,
      sheet = sheet,
      cols = seq_len(ncols),
      rows = 2:1000,
      gridExpand = TRUE
    )
    if (!is.null(data)) {
      openxlsx::writeData(
        wb,
        sheet = sheet,
        x = data,
        startCol = 1,
        startRow = 2,
        colNames = FALSE
      )
    }
  }

  write_sheet_data(template_wb, "PSM", data_for_chart_psm, ncols = 5)
  write_sheet_data(template_wb, "Reach", data_for_chart_reach, ncols = 2)
  write_sheet_data(template_wb, "Revenue", data_for_chart_revenue, ncols = 2)

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
psm_copy_pptx_template <- function(file_path) {
  template_path <- ya_example("psm_template.pptx")
  fs::file_copy(template_path, file_path, overwrite = TRUE)
  cli::cli_inform(
    c(
      "v" = "KDA PowerPoint template copied to {.path {fs::path_norm(file_path)}}"
    )
  )
}
