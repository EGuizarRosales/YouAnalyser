#' Inspect the codebook of a labelled data frame
#'
#' @param data A labelled data frame, e.g. read in from a .sav file using haven::read_sav().
#' @param ... Additional arguments passed to `datawizard::data_codebook()`, e.g. `variable_label_width` and `value_label_width` to control the width of variable labels and value labels in the output.
#'
#' @returns Prints a codebook to the console with variable names, variable labels, value labels, and frequencies.
#' @export
dp_inspect_codebook <- function(data, ...) {
  datawizard::data_codebook(
    data,
    variable_label_width = 15,
    value_label_width = 15,
    max_values = 30,
    ...
  )
}

#' Copy a codebook template to a specified file path
#'
#' @param file_path The file path where the codebook template should be copied.
#'
#' @returns NULL, invisibly. The codebook template is copied to the specified file path. If the directory does not exist, it is created.
#'
#' @export
dp_copy_codebook_template <- function(file_path) {
  template_path <- ya_example("bkw_labels.xlsx")
  fs::file_copy(template_path, file_path, overwrite = TRUE)
  cli::cli_inform(
    c(
      "v" = "Codebook template copied to {.path {fs::path_norm(file_path)}}"
    )
  )
}

#' Convert a data frame to a labelled data frame using a codebook
#'
#' @param data A data frame to be converted to a labelled data frame, e.g. read in from a .csv or .xlsx file.
#' @param codebook A data frame containing the codebook information, with columns "variable", "variable_label", "value", and "value_label".
#' @returns A `haven::labelled` data frame with variable labels and value labels added according to the provided codebook.
#'
#' @export
#' @examples
#' # `data` should be a unlabelled data frame
#' head(bkw_unlabelled, 5)
#'
#' # `codebook` should be a data frame with columns "variable", "variable_label", "value", and "value_label" in *long* format
#' head(bkw_labels, 3*7)
#'
#' # Convert the unlabelled data to a labelled data frame using the codebook
#' data_labelled <- dp_convert_to_labelled(bkw_unlabelled, bkw_labels)
#' print(head(data_labelled, 5), n = Inf)
dp_convert_to_labelled <- function(data, codebook) {
  # Create codebook cb with a list column "haven_labels" used later for labelling
  cb <- codebook |>
    tidyr::nest(.by = c(variable, variable_label), .key = "haven_labels") |>
    dplyr::mutate(
      haven_labels = purrr::map(
        haven_labels,
        \(x) setNames(x$value, x$value_label)
      )
    )

  # Add variable labels and value labels to the data using the codebook
  data_labelled <- data |>
    dplyr::mutate(dplyr::across(
      .cols = dplyr::all_of(cb$variable),
      .fns = \(x) {
        var_name <- dplyr::cur_column()
        labels <- cb$haven_labels[[match(var_name, cb$variable)]]
        haven::labelled(
          x,
          labels = labels,
          label = cb$variable_label[match(var_name, cb$variable)]
        )
      }
    ))

  return(data_labelled)
}

#' Automatically label a data frame
#'
#' @description This function checks for missing variable labels and value labels
#' in a data frame and automatically fills them in. For missing variable labels,
#' it uses the variable name as a fallback. For missing value labels, it uses
#' the observed minimum and maximum values in the data, or theoretical minimum
#' and maximum values if provided by the user.
#'
#' @param data A data frame to be checked and labelled. This can be a labelled data frame or an unlabelled data frame.
#' @param theoretical_min_max_values An optional data frame with columns "variable", "min", and "max" that provides theoretical minimum and maximum values for variables. If provided, these values will be used to fill in missing value labels instead of using observed min/max values from the data.
#'
#' @returns A labelled data frame with missing variable labels and value labels filled in.
#'
#' @export
#' @examples
#' # Create an example data frame with some missing variable labels and value labels
#' bkw_processed_missing_labels <- bkw_processed |>
#'   dplyr::mutate(dplyr::across(paste0("F800_", 1:5), \(x) {
#'     haven::zap_label(x)
#'   })) |>
#'  dplyr::mutate(dplyr::across(paste0("F800_", 4:5), \(x) {
#'    haven::zap_labels(x)
#'  }))
#' # Fill in missing labels using the function
#' out <- dp_label_automatically(bkw_processed_missing_labels)
#' # Check the results
#' dp_inspect_codebook(out)
#'
#' # Create a theoretical min/max data frame
#' theoretical_min_max <- data.frame(
#'  variable = paste0("F800_", 1:5),
#'  min = c(1, 1, 1, 1, 1),
#'  max = c(7, 7, 7, 7, 7)
#' )
#' # Fill in missing labels using the function with theoretical min/max values
#' out_with_theoretical <- dp_label_automatically(bkw_processed_missing_labels, theoretical_min_max)
dp_label_automatically <- function(data, theoretical_min_max_values = NULL) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
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

  for (nm in names(data)) {
    x <- data[[nm]]

    lbl <- attr(x, "label", exact = TRUE)
    lbls <- attr(x, "labels", exact = TRUE)

    if (
      is.null(lbl) || length(lbl) != 1 || !nzchar(trimws(as.character(lbl)))
    ) {
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

    data[[nm]] <- x
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

  data
}

#' Recode user-defined missing values to NA
#'
#' @param data A haven::labelled data frame.
#' @param missing_values A numeric vector of values to be treated as missing. If NULL (default), the function will attempt to automatically detect suspicious values that may indicate missings (e.g., -99, 9999) if they are `<= 0` or `>= 99`.
#'
#' @returns A haven::labelled data frame with user-defined missing values recoded to NA.
#'
#' @export
dp_recode_missing <- function(data, missing_values = NULL) {
  if (is.null(missing_values)) {
    suspicious_tbl <- purrr::imap_dfr(data, \(x, nm) {
      vals <- sjlabelled::get_values(x)
      vals <- unique(vals[!is.na(vals)])

      vals_num <- suppressWarnings(as.numeric(vals))
      suspicious_idx <- !is.na(vals_num) & (vals_num >= 99 | vals_num <= 0)

      if (!any(suspicious_idx)) {
        return(tibble::tibble())
      }

      tibble::tibble(
        variable = nm,
        suspicious_value = vals_num[suspicious_idx]
      )
    })

    if (nrow(suspicious_tbl) == 0) {
      cli::cli_abort(c(
        "x" = "Missing values not provided.",
        "i" = "No suspicious values were detected across variables using the rule {.code <= 0 | >= 99}."
      ))
    }

    suspicious_lines <- suspicious_tbl |>
      dplyr::summarise(
        values = paste(sort(unique(suspicious_value)), collapse = ", "),
        .by = variable
      ) |>
      dplyr::mutate(
        line = paste0("{.var ", variable, "}: {.val ", values, "}")
      ) |>
      dplyr::pull(line)

    missing_values_code <- suspicious_tbl |>
      dplyr::pull(suspicious_value) |>
      unique() |>
      sort() |>
      paste(collapse = ", ")

    cli::cli_abort(c(
      "x" = "Missing values not provided.",
      "i" = "Suspicious values were detected in the following variables:",
      stats::setNames(suspicious_lines, rep("i", length(suspicious_lines))),
      "i" = "Consider setting {.arg missing_values}: {.code missing_values = c({missing_values_code})}"
    ))
  } else {
    out <- data |>
      dplyr::mutate(
        dplyr::across(
          dplyr::everything(),
          \(x) {
            # recode user-defined missing values to NA
            x[x %in% missing_values] <- NA

            # drop value labels for those missing values (if present)
            lbl <- attr(x, "labels", exact = TRUE)
            if (!is.null(lbl)) {
              attr(x, "labels") <- lbl[!unname(lbl) %in% missing_values]
            }

            x
          }
        )
      )
    cli::cli_bullets(c(
      "v" = "User-defined missing values recoded to NA for values: {.val {missing_values}}.",
      "i" = "You might want to inspect the codebook again to check that the user-defined missing values have been recoded and their labels removed: {.code dp_inspect_codebook({substitute(data)})}",
      "i" = "You might want to remove missing values: {.code tidyr::drop_na({substitute(data)})}"
    ))
    return(out)
  }
}
