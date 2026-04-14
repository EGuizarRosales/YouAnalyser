kda_formula <- function(data, outcome, predictors) {
  as.formula(
    paste(outcome, "~", paste(predictors, collapse = " + "))
  )
}

kda_model_reg <- function(data, formula_obj) {
  y <- data[[all.vars(formula_obj)[1]]]
  y_non_missing <- y[!is.na(y)]
  is_binary <- length(unique(y_non_missing)) == 2

  if (is_binary) {
    eval(bquote(glm(.(formula_obj), data = data, family = binomial())))
  } else {
    eval(bquote(lm(.(formula_obj), data = data)))
  }
}

kda_forest_plot <- function(model, model_parameters, predictor_labels) {
  # Create data frame for plotting
  d_plot <- model_parameters |>
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
  N <- nrow(insight::get_data(model))
  x_intercept <- dplyr::case_when(
    attributes(model_parameters)$coefficient_name == "Odds Ratio" ~ 1,
    TRUE ~ 0
  )

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
      color = if (
        attributes(model_parameters)$coefficient_name == "Odds Ratio"
      ) {
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
      x = attributes(model_parameters)$coefficient_name,
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

  return(p_plot)
}

kda_reg <- function(
  data,
  outcome,
  predictors,
  diagnostics = FALSE,
  model_parameters_args = list()
) {
  # Call KDA formula and model functions
  formula_obj <- kda_formula(data, outcome, predictors)
  model <- kda_model_reg(data, formula_obj)

  # Extract model information
  is_linear <- insight::model_info(model)$is_linear
  is_binomial <- insight::model_info(model)$is_binomial

  # Extract data used in model
  model_data <- insight::get_data(model)
  df_outcome <- model_data[outcome]
  df_predictors <- model_data[predictors]

  # outcome_is_binary <- length(unique(df_outcome[!is.na(df_outcome)])) == 2
  # outcome_is_continuous <- length(unique(df_outcome[!is.na(df_outcome)])) > 2
  # all_predictors_are_binary <- all(sapply(df_predictors, \(x) {
  #   length(unique(x[!is.na(x)])) == 2
  # }))
  # all_predictors_are_continuous <- all(sapply(df_predictors, \(x) {
  #   length(unique(x[!is.na(x)])) > 2
  # }))

  predictor_labels <- sjlabelled::get_label(df_predictors) |>
    tibble::enframe(name = "predictor", value = "label") |>
    dplyr::mutate(label_withPred = paste0(predictor, ": ", label))

  # ---- 1. Regression Diagnostics ----
  if (diagnostics) {
    check_model <- performance::check_model(model)

    cor_mat <- dplyr::bind_cols(df_outcome, df_predictors) |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric)) |>
      cor(method = "pearson", use = "pairwise.complete.obs")
    cor_plot <- function() {
      corrplot::corrplot.mixed(
        cor_mat,
        lower = "pie",
        upper = "number",
        diag = "n",
        tl.col = "black"
      )
    }
    diagnostics <- list(
      check_model = check_model,
      cor_plot = cor_plot
    )
  } else {
    diagnostics <- NULL
  }

  # --- 2. Inspect regression results ----
  partial_model_parameters <- purrr::partial(
    parameters::model_parameters,
    !!!model_parameters_args
  )

  m_parameters <- partial_model_parameters(model)

  p_forestPlot <- kda_forest_plot(model, m_parameters, predictor_labels)

  return(list(
    model,
    m_parameters,
    p_forestPlot
  ))
}
