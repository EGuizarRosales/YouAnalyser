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
#' print(head(bkw_unlabelled, 5), n = Inf)
#'
#' # `codebook` should be a data frame with columns "variable", "variable_label", "value", and "value_label" in *long* format
#' print(head(bkw_labels, 3*7), n = Inf)
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
