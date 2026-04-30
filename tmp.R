myModel_lm <- lm(F600 ~ ., data = bkw_processed)
myModel_glm <- glm(F600 ~ ., data = bkw_bin_outcome, family = binomial())


################################################################################

tmp_data <- bkw_processed |>
  dplyr::mutate(dplyr::across(paste0("F800_", 1:5), \(x) {
    haven::zap_label(x)
  })) |>
  dplyr::mutate(dplyr::across(paste0("F800_", 4:5), \(x) {
    haven::zap_labels(x)
  }))

check_haven_metadata <- function(df, theoretical_min_max_values = NULL) {
  if (!is.data.frame(df)) {
    cli::cli_abort("{.arg df} must be a data frame.")
  }

  if (!is.null(theoretical_min_max_values)) {
    if (!is.data.frame(theoretical_min_max_values)) {
      cli::cli_abort("{.arg theoretical_min_max_values} must be a data frame.")
    }

    required_cols <- c("variable", "min", "max")
    missing_cols <- setdiff(required_cols, names(theoretical_min_max_values))

    if (length(missing_cols) > 0) {
      cli::cli_abort(c(
        "{.arg theoretical_min_max_values} is missing required columns.",
        "x" = "Missing: {.val {missing_cols}}",
        "i" = "Required columns are: {.val {required_cols}}"
      ))
    }
  }

  missing_label_vars <- character()
  missing_labels_vars <- character()

  for (nm in names(df)) {
    x <- df[[nm]]

    lbl <- attr(x, "label", exact = TRUE)
    lbls <- attr(x, "labels", exact = TRUE)

    if (is.null(lbl) || length(lbl) != 1 || !nzchar(trimws(as.character(lbl)))) {
      lbl <- nm
      missing_label_vars <- c(missing_label_vars, nm)
    }

    if (is.null(lbls) || length(lbls) == 0) {
      use_theoretical <- !is.null(theoretical_min_max_values) &&
        nm %in% theoretical_min_max_values$variable

      if (use_theoretical) {
        row_idx <- match(nm, theoretical_min_max_values$variable)
        min_val <- theoretical_min_max_values$min[[row_idx]]
        max_val <- theoretical_min_max_values$max[[row_idx]]
        label_values <- c(min_val, max_val)

        if (is.factor(x)) {
          label_values <- as.character(label_values)
          lbls <- stats::setNames(label_values, label_values)
        } else {
          lbls <- stats::setNames(label_values, as.character(label_values))
        }
      } else {
        x_non_na <- x[!is.na(x)]

        if (length(x_non_na) > 0) {
          if (is.factor(x_non_na)) {
            vals <- as.character(x_non_na)
            min_val <- min(vals)
            max_val <- max(vals)
            label_values <- c(min_val, max_val)
            lbls <- stats::setNames(label_values, label_values)
          } else {
            min_val <- min(x_non_na)
            max_val <- max(x_non_na)
            label_values <- c(min_val, max_val)
            lbls <- stats::setNames(label_values, as.character(label_values))
          }
        } else {
          lbls <- stats::setNames(c(NA, NA), c("NA", "NA"))
        }
      }

      missing_labels_vars <- c(missing_labels_vars, nm)
    }

    if (nm %in% missing_label_vars || nm %in% missing_labels_vars) {
      x <- haven::labelled(x = x, labels = lbls, label = lbl)
    }

    df[[nm]] <- x
  }

  if (length(missing_label_vars) > 0) {
    cli::cli_warn(c(
      "Missing variable {.field label} detected.",
      "!" = "Replaced with variable name for: {.val {missing_label_vars}}."
    ))
  }

  if (length(missing_labels_vars) > 0) {
    replacement_source <- if (is.null(theoretical_min_max_values)) {
      "observed"
    } else {
      "user-supplied"
    }

    cli::cli_warn(c(
      "Missing value {.field labels} detected.",
      "!" = "Replaced with {replacement_source} min/max values for: {.val {missing_labels_vars}}."
    ))
  }

  df
}

df_labels <- tibble::tibble(
  variable = paste0("F800_", 4:5),
  min = rep(2, times = length(variable)),
  max = rep(6, times = length(variable))
)

out <- check_haven_metadata(tmp_data, df_labels)

out |>
  dplyr::select("F800_4") |>
  sjlabelled::get_labels(value = "p")

eda_summary(out)

kda <- kda_regression(
  data = out,
  outcome = "F600",
  predictors = paste0("F800_", 1:14),
  diagnostics = TRUE,
  importance_method = "jrw"
)
