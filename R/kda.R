kda_formula <- function(outcome, predictors) {
  as.formula(
    paste(outcome, "~", paste(predictors, collapse = " + "))
  )
}

kda_model_reg <- function(data, formula_obj) {
  y <- data[[all.vars(formula_obj)[1]]]
  y_non_missing <- y[!is.na(y)]
  is_binary <- length(unique(y_non_missing)) == 2

  # Get the name of the data object from the calling environment
  data_name <- deparse(substitute(data))

  # Create the model with the actual data name
  if (is_binary) {
    eval(
      bquote(
        glm(.(formula_obj), data = .(as.name(data_name)), family = binomial())
      ),
      envir = parent.frame()
    )
  } else {
    eval(
      bquote(
        lm(.(formula_obj), data = .(as.name(data_name)))
      ),
      envir = parent.frame()
    )
  }
}

# ---- Variable Importance  ----------------------------------------------------

#' Calculate feature importance using sum of coefficients
#'
#' @description
#' A short description...
#'
#' @param model A fitted model object.
#'
#' @returns
#' A list with two elements: `out`, a tibble with predictor names and importance
#' metrics (raw, ratio, percent, and rank), and `coef`, the model parameters table.
#'
#' @export
kda_importance_sumOfCoefficients <- function(model) {
  coef <- parameters::model_parameters(model)
  out <- coef |>
    tibble::as_tibble() |>
    dplyr::filter(Parameter != "(Intercept)") |>
    dplyr::mutate(
      Importance_Raw = abs(Coefficient),
      Importance_Ratio = Importance_Raw / sum(Importance_Raw),
      Importance_Percent = Importance_Ratio * 100,
      Importance_Rank = dplyr::row_number(dplyr::desc(Importance_Raw))
    ) |>
    dplyr::select(predictor = Parameter, dplyr::starts_with("Importance"))
  attr(out, "importance_type") <- "Sum of Coefficients"

  return(list(
    out = out,
    coef = coef
  ))
}

#' Perform KDA dominance analysis
#'
#' @description
#' A short description...
#'
#' @param model A fitted model object.
#' @param domir_args Optional. A list of arguments to pass to [domir::domir()].
#'
#' @returns
#' A list containing:
#' - `out`: A tibble with predictor importance metrics (raw, ratio, percent, and rank).
#' - `da`: The raw dominance analysis object from [domir::domir()].
#'
#' @export
kda_importance_domir <- function(
  model,
  domir_args = list(
    .set = NULL
  )
) {
  # Define partial function for dominance analysis with user-specified arguments
  partial_domir <- purrr::partial(
    domir::domir,
    .adj = FALSE,
    .cdl = FALSE,
    .cpt = FALSE,
    .prg = FALSE,
    !!!domir_args
  )

  # Get model infos
  formula_obj <- insight::find_formula(model)$conditional
  data <- insight::get_data(model, source = "mf")

  # Define function to calculate R² for a given formula and data
  partial_glm <- purrr::partial(glm, family = binomial())
  reg_type <- if (insight::model_info(model)$is_binomial) partial_glm else lm
  R2_wrapper <- function(formula, data) {
    mod <- reg_type(formula, data = data)
    r2 <- performance::r2(mod)$R2
    return(r2)
  }

  # Run dominance analysis
  da <- partial_domir(
    .obj = formula_obj,
    .fct = R2_wrapper,
    data = data
  )

  # Define primary output
  out <- tibble::enframe(
    da$General_Dominance,
    name = "predictor",
    value = "Importance_Raw"
  ) |>
    dplyr::mutate(
      Importance_Ratio = as.numeric(da$Standardized),
      Importance_Percent = Importance_Ratio * 100,
      Importance_Rank = as.numeric(da$Ranks)
    )
  attr(out, "importance_type") <- "R²"

  return(list(
    out = out,
    da = da
  ))
}


#' Calculate Importance using Johnson's Relative Weights
#'
#' @description
#' This function is a more efficient, though less precise, alternative to
#' [kda_importance_domir()]. While [kda_importance_domir()] can become computationally intensive with
#' more than ~15 predictors, this function scales better to larger models.
#'
#' For linear regression models, relative importance is computed from each
#' predictor's contribution to model \(R^2\). For logistic regression models,
#' relative importance is computed from each predictor's contribution to
#' pseudo-\(R^2\).
#'
#' @seealso [kda_importance_domir()]
#' @param model A model object.
#' @param correlation_method Optional. One of `"polychoric"` or `"pearson"`. Defaults to `"polychoric"` for binomial models and `"pearson"` otherwise.
#'
#' @returns
#' A list containing:
#' - `out`: A tibble with predictor importance metrics (raw, ratio, percent, and rank).
#' - `jrw`: The Johnson's Relative Weights object.
#'
#' @export
kda_importance_jrw <- function(
  model,
  correlation_method = if (insight::model_info(model)$is_binomial) {
    "polychoric"
  } else {
    "pearson"
  }
) {
  # Get model data
  data <- dplyr::bind_cols(
    insight::get_data(model, source = "mf")[,
      insight::find_variables(model)$response
    ],
    insight::get_data(model, source = "mf")[,
      insight::find_variables(model)$conditional
    ]
  )

  if (insight::model_info(model)$is_binomial) {
    data <- data |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric))
  }

  # Calculate correlation matrix
  corr <- correlation::correlation(
    data,
    method = correlation_method,
    use = "pairwise.complete.obs"
  )
  corr_mat <- as.matrix(corr)

  # Calculate Johnson's Relative Weights
  jrw <- iopsych::relWt(
    corr_mat,
    y_col = 1,
    x_col = 2:ncol(corr_mat)
  )

  # Define primary output
  out <- tibble::as_tibble(jrw$eps, rownames = "predictor") |>
    dplyr::mutate(
      Importance_Raw = EPS,
      Importance_Ratio = EPS / sum(EPS),
      Importance_Percent = Importance_Ratio * 100,
      Importance_Rank = dplyr::row_number(dplyr::desc(EPS))
    ) |>
    # Make sure that Importance_Raw values sum up to the models R squared
    # (important for glm models)
    dplyr::mutate(
      Importance_Raw = performance::r2(model)$R2 * Importance_Ratio
    ) |>
    dplyr::select(-EPS)
  attr(out, "importance_type") <- "R²"

  return(list(
    out = out,
    jrw = jrw
  ))
}

#---- Variable Performance -----------------------------------------------------

#' Calculate KDA performance
#'
#' @description
#' A short description...
#'
#' @param model A fitted model object.
#'
#' @returns
#' A list with two elements: `out`, a data frame with performance metrics for each predictor, and `perf`, a data frame with detailed performance statistics.
#'
#' @export
kda_performance <- function(model) {
  # Extract data used in model
  df_predictors <- insight::get_predictors(model)

  # Get theoretical minimum and maximum values of predictors
  predictors_minmax_labels <- sjlabelled::get_values(df_predictors) |>
    tibble::enframe(name = "predictor", value = "values") |>
    tidyr::unnest(values) |>
    dplyr::summarise(min = min(values), max = max(values), .by = "predictor")

  d_performance <- df_predictors |>
    dplyr::summarise(
      dplyr::across(
        dplyr::everything(),
        list(
          mean = ~ mean(.x, na.rm = TRUE),
          sd = ~ sd(.x, na.rm = TRUE),
          n = ~ sum(!is.na(.x)),
          se = ~ sd(.x, na.rm = TRUE) / sqrt(sum(!is.na(.x))),
          ciLower = ~ mean(.x, na.rm = TRUE) -
            qt(0.975, df = sum(!is.na(.x)) - 1) *
              sd(.x, na.rm = TRUE) /
              sqrt(sum(!is.na(.x))),
          ciUpper = ~ mean(.x, na.rm = TRUE) +
            qt(0.975, df = sum(!is.na(.x)) - 1) *
              sd(.x, na.rm = TRUE) /
              sqrt(sum(!is.na(.x)))
        ),
        .names = "{.col}_{.fn}"
      )
    ) |>
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = c("predictor", "metric"),
      names_pattern = "(.+_.+)_(.+)",
      values_to = "value"
    ) |>
    tidyr::pivot_wider(
      names_from = "metric",
      values_from = "value"
    )

  out <- d_performance |>
    dplyr::select(predictor, Performance_Raw = mean) |>
    dplyr::left_join(predictors_minmax_labels, by = "predictor") |>
    dplyr::mutate(
      Performance_Ratio = (Performance_Raw - min) / (max - min),
      Performance_Percent = Performance_Ratio * 100,
      Performance_Rank = dplyr::row_number(dplyr::desc(Performance_Raw))
    ) |>
    dplyr::select(predictor, dplyr::starts_with("Performance"))

  return(list(
    out = out,
    perf = d_performance
  ))
}

# ---- Variable Importance & Performance ---------------------------------------

#' Importance-Performance Matrix Analysis
#'
#' @description
#' Combines importance and performance data to generate IPMA recommendations.
#'
#' @param importance_obj A list with element `out` containing predictor importance ratios.
#' @param performance_obj A list with element `out` containing predictor performance ratios.
#'
#' @returns
#' A list with elements `out` (a data frame with predictors, importance, performance, and recommendations) and `means` (a data frame with mean importance and performance ratios).
#'
#' @export
kda_ipma <- function(importance_obj, performance_obj) {
  d_ipma <- importance_obj$out |>
    dplyr::select(predictor, starts_with("Importance")) |>
    dplyr::left_join(
      performance_obj$out |>
        dplyr::select(predictor, starts_with("Performance")),
      by = "predictor"
    )

  d_ipma_means <- d_ipma |>
    dplyr::summarise(
      Importance_Ratio_Mean = mean(Importance_Ratio),
      Performance_Ratio_Mean = mean(Performance_Ratio)
    )

  d_ipma <- d_ipma |>
    dplyr::mutate(
      recommendation = dplyr::case_when(
        Importance_Ratio >= d_ipma_means$Importance_Ratio_Mean &
          Performance_Ratio >=
            d_ipma_means$Performance_Ratio_Mean ~ "Keep up the good work",
        Importance_Ratio >= d_ipma_means$Importance_Ratio_Mean &
          Performance_Ratio <
            d_ipma_means$Performance_Ratio_Mean ~ "Concentrate here",
        Importance_Ratio < d_ipma_means$Importance_Ratio_Mean &
          Performance_Ratio >=
            d_ipma_means$Performance_Ratio_Mean ~ "Possible overkill",
        Importance_Ratio < d_ipma_means$Importance_Ratio_Mean &
          Performance_Ratio <
            d_ipma_means$Performance_Ratio_Mean ~ "Low priority"
      ) |>
        factor(
          levels = c(
            "Low priority",
            "Possible overkill",
            "Keep up the good work",
            "Concentrate here"
          )
        )
    )

  attr(d_ipma, "importance_type") <- attr(importance_obj$out, "importance_type")

  return(list(
    out = d_ipma,
    means = d_ipma_means
  ))
}

#---- Plotting Functions -------------------------------------------------------

#' Create a forest plot for model coefficients
#'
#' @description
#' A short description...
#'
#' @param model A fitted regression model.
#' @param model_parameters_args Optional. A list of additional arguments passed to [parameters::model_parameters()].
#'
#' @returns
#' A list with elements `d` (a data frame of plot data) and `p` (a ggplot2 object).
#'
#' @export
kda_forestPlot <- function(model, model_parameters_args = list()) {
  # Extract data used in model
  data <- insight::get_data(model, source = "mf")
  predictor_labels <- ya_get_predictor_labels(model)

  # Define partial function for model parameters with user-specified arguments
  partial_model_parameters <- purrr::partial(
    parameters::model_parameters,
    !!!model_parameters_args
  )

  # Get model parameters
  m_params <- partial_model_parameters(model)

  # Create data frame for plotting
  d_plot <- m_params |>
    dplyr::filter(Parameter != "(Intercept)") |>
    dplyr::mutate(
      coeff_label = paste0(
        ya_format_numeric(Coefficient),
        " [",
        ya_format_numeric(CI_low),
        ", ",
        ya_format_numeric(CI_high),
        "]"
      )
    ) |>
    dplyr::left_join(predictor_labels, by = c("Parameter" = "predictor")) |>
    dplyr::mutate(
      label_withPred = forcats::fct_reorder(
        label_withPred,
        Coefficient
      )
    )

  R2 <- as.numeric(performance::r2(model)$R2) * 100
  R2 <- paste0(ya_format_numeric(R2), "%")
  N <- nrow(data)
  x_intercept <- if (attr(m_params, "exponentiate")) 1 else 0

  p_plot <- d_plot |>
    ggplot2::ggplot(ggplot2::aes(x = Coefficient, y = label_withPred)) +
    ggplot2::geom_vline(
      xintercept = x_intercept,
      linetype = "dotted",
      color = "darkgrey"
    ) +
    ggplot2::geom_pointrange(ggplot2::aes(
      xmin = CI_low,
      xmax = CI_high,
      color = if (x_intercept == 1) {
        Coefficient > 1
      } else {
        Coefficient > 0
      },
      alpha = p < 0.05
    )) +
    ggplot2::geom_text(
      ggplot2::aes(x = Inf, label = coeff_label),
      hjust = 1.1
    ) +
    ggplot2::scale_color_manual(
      values = c(
        `TRUE` = yougov_colors[["Teal 1"]],
        `FALSE` = yougov_colors[["Red 1"]]
      ),
      name = "Positive Effect"
    ) +
    ggplot2::scale_alpha_manual(values = c(`TRUE` = 1, `FALSE` = 0.2)) +
    ggplot2::scale_x_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.30))
    ) +
    ggplot2::labs(
      title = "Forest Plot of Regression Results",
      x = attr(m_params, "coefficient_name"),
      subtitle = paste0("R² = ", R2, "; N = ", N),
      caption = paste0(
        "Outcome: ",
        stringr::str_wrap(
          sjlabelled::get_label(insight::get_response(model)),
          width = 80
        )
      )
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.title.y = ggplot2::element_blank()
    )

  return(list(
    d = d_plot,
    p = p_plot
  ))
}

#' Create KDA importance bar plot
#'
#' @description
#' A short description...
#'
#' @param model A model object.
#' @param importance_obj An importance object, i.e., the output from [YouAnalyser::kda_importance_sumOfCoefficients()], [YouAnalyser::kda_importance_domir()], or [YouAnalyser::kda_importance_jrw()].
#' @param color Optional. A single string specifying the bar color.
#' @param label_size Optional. A numeric value specifying the size of the labels on the bars. Defaults to 3.
#'
#' @returns
#' A list with elements `d` (a data frame of plot data) and `p` (a ggplot2 object).
#'
#' @export
kda_importance_barPlot <- function(
  model,
  importance_obj,
  color = yougov_colors[["Red 1"]],
  label_size = 3
) {
  # Extract data used in model
  data <- insight::get_data(model, source = "mf")
  predictor_labels <- ya_get_predictor_labels(model)

  # Data for plot
  d_plot <- importance_obj$out |>
    dplyr::left_join(predictor_labels, by = "predictor") |>
    dplyr::mutate(
      label_geomLabel = paste0(
        ya_format_numeric(Importance_Percent),
        "%\n(",
        paste0(
          ifelse(
            attr(importance_obj$out, "importance_type") == "R²",
            "R² = ",
            "Coeff = "
          ),
          ya_format_numeric(Importance_Raw)
        ),
        ")"
      )
    )

  # Create bar plot
  p_plot <- d_plot |>
    dplyr::mutate(
      label_withPred = forcats::fct_reorder(
        label_withPred,
        Importance_Raw
      )
    ) |>
    ggplot2::ggplot(ggplot2::aes(y = label_withPred, x = Importance_Ratio)) +
    ggplot2::geom_col(fill = color) +
    ggplot2::geom_label(
      ggplot2::aes(label = label_geomLabel),
      hjust = 0.5,
      fill = "white",
      size = label_size
    ) +
    ggplot2::scale_x_continuous(labels = scales::label_percent()) +
    ggplot2::labs(
      title = paste0(
        "Predictor Importance based on ",
        attr(importance_obj$out, "importance_type")
      ),
      subtitle = paste0(
        ifelse(
          attr(importance_obj$out, "importance_type") == "Sum of Coefficients",
          paste0(
            "Sum of Coefficients = ",
            ya_format_numeric(sum(importance_obj$out$Importance_Raw)),
            "; "
          ),
          ""
        ),
        "Total R² = ",
        ya_format_numeric(performance::r2(model)$R2 * 100),
        "%; N = ",
        nrow(data)
      ),
      caption = paste0(
        "Outcome: ",
        data[[insight::find_response(model)]] |>
          sjlabelled::get_label() |>
          stringr::str_wrap(width = 80)
      ),
      x = paste0(
        "Importance (% Contribution to ",
        attr(importance_obj$out, "importance_type"),
        ")"
      ),
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.title.y = ggplot2::element_blank()
    )

  return(list(
    d = d_plot,
    p = p_plot
  ))
}

#' Create a KDA performance bar plot
#'
#' @description
#' A short description...
#'
#' @param model A model object.
#' @param performance_obj A performance object, i.e., the output from [YouAnalyser::kda_performance()].
#' @param color Optional. A single string specifying the bar color.
#' @param label_size Optional. A numeric value specifying the size of the labels on the bars. Defaults to 3.
#'
#' @returns
#' A list with two elements: `d`, a data frame containing the plot data, and `p`, a ggplot2 object.
#'
#' @export
kda_performance_barPlot <- function(
  model,
  performance_obj,
  color = yougov_colors[["Red 1"]],
  label_size = 3
) {
  # Extract data used in model
  data <- insight::get_data(model, source = "mf")
  predictor_labels <- ya_get_predictor_labels(model)

  # Data for plot
  d_plot <- performance_obj$out |>
    dplyr::left_join(predictor_labels, by = "predictor") |>
    dplyr::mutate(
      label_geomLabel = paste0(
        ya_format_numeric(Performance_Percent),
        "%\n(",
        ya_format_numeric(Performance_Raw),
        ")"
      )
    )

  # Create bar plot
  p_plot <- d_plot |>
    dplyr::mutate(
      label_withPred = forcats::fct_reorder(
        label_withPred,
        Performance_Raw
      )
    ) |>
    ggplot2::ggplot(ggplot2::aes(y = label_withPred, x = Performance_Ratio)) +
    ggplot2::geom_col(fill = color) +
    ggplot2::geom_label(
      ggplot2::aes(label = label_geomLabel),
      hjust = 0.5,
      fill = "white",
      size = label_size
    ) +
    ggplot2::scale_x_continuous(labels = scales::label_percent()) +
    ggplot2::labs(
      title = "Predictor Performance based on Rescaled Means",
      subtitle = paste0(
        "Mean Performance = ",
        ya_format_numeric(mean(performance_obj$out$Performance_Percent)),
        "%; N = ",
        nrow(data)
      ),
      caption = paste0(
        "Outcome: ",
        data[[insight::find_response(model)]] |>
          sjlabelled::get_label() |>
          stringr::str_wrap(width = 80)
      ),
      x = "Performance (% of Maximum Possible Score)"
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.title.y = ggplot2::element_blank()
    )

  return(list(
    d = d_plot,
    p = p_plot
  ))
}

#' Create an Importance-Performance Matrix Analysis scatter plot
#'
#' @description
#' A short description...
#'
#' @param model A fitted model object.
#' @param ipma_obj An IPMA results object, i.e., the output from [YouAnalyser::kda_ipma()].
#' @param show_labels Optional. A logical indicating whether to display predictor labels on the plot. Defaults to `TRUE`.
#' @param quadrant_colors Optional. A named character vector of colors for the four quadrants. Defaults to a set of predefined colors.
#' @param geom_point_size Optional. A numeric value specifying the size of the points on the scatter plot. Defaults to 8.
#'
#' @returns
#' A list containing:
#' - `d`: A data frame with the plot data
#' - `p`: A ggplot2 plot object
#'
#' @export
#' @examples
#' # Fit a model
#' m <- lm(F600 ~ ., data = bkw_processed)
#' # Fit importance and performance objects
#' importance_obj <- kda_importance_jrw(m)
#' performance_obj <- kda_performance(m)
#' ipma_obj <- kda_ipma(importance_obj, performance_obj)
#' # Create IPMA scatter plot
#' ipma_plot <- kda_ipma_scatterPlot(m, ipma_obj)
#' # Access IPMA plot
#' print(ipma_plot$p)
kda_ipma_scatterPlot <- function(
  model,
  ipma_obj,
  show_labels = TRUE,
  quadrant_colors = c(
    "Concentrate here" = yougov_colors[["Red 1"]],
    "Keep up the good work" = yougov_colors[["Purple 1"]],
    "Possible overkill" = yougov_colors[["Teal 1"]],
    "Low priority" = yougov_colors[["Blue 1"]]
  ),
  geom_point_size = 6
) {
  # Extract data used in model
  data <- insight::get_data(model, source = "mf")
  predictor_labels <- ya_get_predictor_labels(model) |>
    dplyr::mutate(predictor_nr = dplyr::row_number()) |>
    dplyr::relocate(predictor_nr, .after = predictor)

  # Data for plot
  d_plot <- ipma_obj$out |>
    dplyr::left_join(predictor_labels, by = "predictor")

  # Create scatter plot
  p_plot <- d_plot |>
    ggplot2::ggplot(ggplot2::aes(x = Importance_Ratio, y = Performance_Ratio)) +
    ggplot2::geom_vline(
      xintercept = ipma_obj$means$Importance_Ratio_Mean,
      linetype = "solid",
      color = "darkgrey"
    ) +
    ggplot2::geom_hline(
      yintercept = ipma_obj$means$Performance_Ratio_Mean,
      linetype = "solid",
      color = "darkgrey"
    ) +
    {
      if (show_labels) {
        ggrepel::geom_label_repel(
          ggplot2::aes(label = stringr::str_wrap(label, width = 30)),
          size = 3,
          box.padding = 0.5,
          point.padding = 0.5,
          min.segment.length = 0,
          show.legend = FALSE
        )
      }
    } +
    ggplot2::geom_point(
      ggplot2::aes(color = recommendation),
      size = geom_point_size
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = predictor_nr),
      size = geom_point_size - 2,
      color = "white"
    ) +
    ggplot2::scale_x_continuous(labels = scales::label_percent()) +
    ggplot2::scale_y_continuous(labels = scales::label_percent()) +
    ggplot2::scale_color_manual(
      values = quadrant_colors,
      name = "Recommendation"
    ) +
    ggplot2::labs(
      title = "Importance-Performance Matrix Analysis (IPMA)",
      subtitle = paste0(
        "Mean Importance = ",
        ya_format_numeric(ipma_obj$means$Importance_Ratio_Mean * 100),
        "%; ",
        "Mean Performance = ",
        ya_format_numeric(ipma_obj$means$Performance_Ratio_Mean * 100),
        "%; ",
        "R² = ",
        ya_format_numeric(performance::r2(model)$R2 * 100),
        "%; N = ",
        nrow(data)
      ),
      caption = paste0(
        "Grey lines represent mean Importance and Performance which define the quadrants of the IPMA plot.\n",
        "Outcome: ",
        data[[insight::find_response(model)]] |>
          sjlabelled::get_label() |>
          stringr::str_wrap(width = 80)
      ),
      x = paste0(
        "Importance (% Contribution to ",
        attr(ipma_obj$out, "importance_type"),
        ")"
      ),
      y = "Performance (% of Maximum Possible Score)"
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(legend.position = "bottom")

  # Select only relevant data for output
  d <- d_plot |>
    dplyr::select(
      predictor_nr,
      predictor,
      label,
      recommendation,
      starts_with("Importance"),
      starts_with("Performance")
    )

  return(list(
    d = d,
    p = p_plot
  ))
}

# ---- KDA Main Function -------------------------------------------------------

#' Conduct KDA regression analysis
#'
#' @description
#' A short description...
#'
#' @param data A data frame containing the outcome and predictors. Optional if `model` is provided.
#' @param outcome A single string naming the outcome variable. Optional if `model` is provided.
#' @param predictors A character vector of predictor variable names. Optional if `model` is provided.
#' @param model A fitted regression model object. Optional if `data`, `outcome`, and `predictors` are provided.
#' @param diagnostics A logical indicating whether to compute model diagnostics. Defaults to `FALSE`.
#' @param importance_method One of `"auto"`, `"domir"`, `"jrw"`, or `"sumOfCoefficients"`. Defaults to `"auto"`.
#' @param importance_barPlot_args Optional. A list of additional arguments passed to the importance bar plot function. See [YouAnalyser::kda_importance_barPlot()] for details..
#' @param performance_barPlot_args Optional. A list of additional arguments passed to the performance bar plot function. See [YouAnalyser::kda_performance_barPlot()] for details..
#' @param ipma_scatterPlot_args Optional. A list of additional arguments passed to the IPMA scatter plot function. See [YouAnalyser::kda_ipma_scatterPlot()] for details..
#'
#' @returns
#' A list containing model results, importance measures, performance metrics, IPMA analysis, and associated plots. Errors if neither `model` nor all of `data`, `outcome`, and `predictors` are provided.
#'
#' @export
kda_regression <- function(
  data = NULL,
  outcome = NULL,
  predictors = NULL,
  model = NULL,
  diagnostics = FALSE,
  importance_method = "auto",
  importance_barPlot_args = list(),
  performance_barPlot_args = list(),
  ipma_scatterPlot_args = list()
) {
  # ---- 1. Preparation ----

  if (
    is.null(model) && (is.null(data) || is.null(outcome) || is.null(predictors))
  ) {
    cli::cli_abort(
      c(
        "Insufficient arguments provided.",
        "i" = "Either {.arg model} or all of {.arg data}, {.arg outcome}, and {.arg predictors} must be supplied.",
        "x" = "{.arg model} is {.val NULL} and one or more of {.arg data}, {.arg outcome}, {.arg predictors} is missing."
      )
    )
  }

  # Get or define model
  if (!is.null(model)) {
    model <- model
  } else {
    formula_obj <- kda_formula(outcome, predictors)
    model <- kda_model_reg(data, formula_obj)
  }

  # Get model information
  m_data <- insight::get_data(model, source = "mf")

  # ---- 2. Inspect Model Results ----

  m_parameters <- parameters::model_parameters(model) |>
    dplyr::left_join(
      ya_get_predictor_labels(model),
      by = c("Parameter" = "predictor")
    ) |>
    dplyr::select(-label_withPred) |>
    dplyr::select(Parameter, Label = label, dplyr::everything())

  p_forestPlot <- kda_forestPlot(model)

  model_obj = list(
    model = model,
    parameters = m_parameters
  )

  # ---- 3. Model Diagnostics ----

  # Define model diagnostics if requested
  if (diagnostics) {
    p_correlation <- eda_correlation(
      data = m_data,
      correlation_type = "auto"
    )
    p_model_diagnostics <- performance::check_model(model)
    diagnostics_corelation <- p_correlation
    diagnostics_model <- p_model_diagnostics
    diagnostics_model$p <- diagnostics_model
  } else {
    diagnostics_corelation <- NULL
    diagnostics_model <- NULL
  }

  # ---- 4. Variable Importance & Performance ----

  # Importance
  imp_obj <- if (importance_method == "auto") {
    if (ncol(insight::get_predictors(model)) <= 15) {
      kda_importance_domir(model)
    } else {
      kda_importance_jrw(model)
    }
  } else if (importance_method == "domir") {
    kda_importance_domir(model)
  } else if (importance_method == "jrw") {
    kda_importance_jrw(model)
  } else if (importance_method == "sumOfCoefficients") {
    kda_importance_sumOfCoefficients(model)
  } else {
    cli::cli_abort(
      c(
        "Invalid {.arg importance_method}: {.val {importance_method}}.",
        "i" = "Must be one of {.val auto}, {.val domir}, {.val jrw}, {.val sumOfCoefficients}."
      )
    )
  }
  p_imp <-
    do.call(
      kda_importance_barPlot,
      c(list(model = model, importance_obj = imp_obj), importance_barPlot_args)
    )

  # Performance
  perf_obj <- kda_performance(model)
  p_perf <- do.call(
    kda_performance_barPlot,
    c(list(model = model, performance_obj = perf_obj), performance_barPlot_args)
  )

  # ---- 5. Importance-Performance Matrix Analysis ----

  ipma_obj <- kda_ipma(imp_obj, perf_obj)
  p_ipma <- do.call(
    kda_ipma_scatterPlot,
    c(list(model = model, ipma_obj = ipma_obj), ipma_scatterPlot_args)
  )

  return(list(
    model = model_obj,
    importance = imp_obj,
    performance = perf_obj,
    ipma = ipma_obj,
    plots = list(
      diagnostics_corelation = diagnostics_corelation,
      diagnostics_model = diagnostics_model,
      model_forestPlot = p_forestPlot,
      importance_barPlot = p_imp,
      performance_barPlot = p_perf,
      ipma_scatterPlot = p_ipma
    )
  ))
}
