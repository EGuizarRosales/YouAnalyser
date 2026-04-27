#' Synthetic BKW Employer Brand Positioning Study Data (Synthetic)
#'
#' Synthetic data generated from the BKW Employer Brand Positioning Study conducted in 2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026).
#' Key Driver Analyses (linear regression with dominance analysis) were performed.
#' The data includes the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model.
#' Additional grouping variables (country and cluster) are included to allow for subgroup analyses.
#'
#' @format ## `bkw_synthetic`
#' A data frame with 1,216 rows and 18 columns:
#' \describe{
#'   \item{id}{unique identifier for each respondent, starting from 1}
#'   \item{country}{country of the respondent}
#'   \item{cluster}{segmentation-based cluster the respondent belongs to}
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables used in the regression model. Main question: Wie gut passt die BKW Ihrer Meinung nach zu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#' }
"bkw_synthetic"

#' Synthetic BKW Employer Brand Positioning Study Data (With Missing Values)
#'
#' Data synthetically created based on [YouAnalyser::bkw_synthetic]. 5% NA values were introduced in all variables to mimic missing values.
#'
#' @format ## `bkw_missings`
#' A data frame with 1,216 rows and 18 columns:
#' \describe{
#'   \item{id}{unique identifier for each respondent, starting from 1}
#'   \item{country}{country of the respondent}
#'   \item{cluster}{segmentation-based cluster the respondent belongs to}
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables used in the regression model. Main question: Wie gut passt die BKW Ihrer Meinung nach zu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#' }
"bkw_missings"

#' Synthetic BKW Employer Brand Positioning Study Data (Processed)
#'
#' Processed data created based on [YouAnalyser::bkw_missings].
#' Only the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model are included. All NA values in these variables were removed to ensure the data is ready for analysis.
#'
#' @format ## `bkw_processed`
#' A data frame with 1,171 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables used in the regression model. Main question: Wie gut passt die BKW Ihrer Meinung nach zu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#' }
"bkw_processed"

#' Synthetic BKW Employer Brand Positioning Study Data (Binary)
#'
#' Binary data based on [YouAnalyser::bkw_processed].
#' The dependent variable (F600) was dichotomized into a binary variable (0: "Nicht attraktiv", 1: "Attraktiv") based on a cutoff of 4. The independent variables (F800_1 to F800_14) were also dichotomized into binary variables (0: "Nicht gut", 1: "Gut") based on a cutoff of 4.
#'
#' @format ## `bkw_bin`
#' A data frame with 1,171 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (0: Nicht attraktiv, 1: Attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (0: Nicht gut, 1: Gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_bin"

#' BKW Employer Brand Positioning Study Data (Binary Outcome)
#'
#' Data based on [YouAnalyser::bkw_processed] with a binary dependent variable.
#' The dependent variable (F600) was dichotomized into a binary variable (0: "Nicht attraktiv", 1: "Attraktiv") based on a cutoff of 4.
#'
#' @format ## `bkw_bin_outcome`
#' A data frame with 1,171 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (0: Nicht attraktiv, 1: Attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_bin_outcome"

#' BKW Employer Brand Positioning Study Data (Binary Predictors)
#'
#' Data based on [YouAnalyser::bkw_processed] with binary independent variables.
#' The independent variables (F800_1 to F800_14) were dichotomized into binary variables (0: "Nicht gut", 1: "Gut") based on a cutoff of 4.
#'
#' @format ## `bkw_bin_predictors`
#' A data frame with 1,171 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (0: Nicht gut, 1: Gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_bin_predictors"

#' BKW Employer Brand Positioning Study Data (Unlabelled Data)
#'
#' Data based on [YouAnalyser::bkw_processed] with unlabelled variables.
#' The data contains no variable labels or value labels, mimicking
#' a typical dataset that user might have read in from a .csv or .xlsx file.
#'
#' @format ## `bkw_unlabelled`
#' A data frame with 1,171 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_unlabelled"

#' BKW Employer Brand Positioning Study Data (Variable and Value Labels)
#'
#' Data based on [YouAnalyser::bkw_processed] with variable and value labels.
#' The data only contains variable labels and value labels, providing a codebook additionally needed if unlabelled data is read in, e.g. using .xlsx or .csv files..
#'
#' @format ## `bkw_labels`
#' A data frame with 1,171 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_labels"

#' YouGov Colors
#'
#' A named character vector containing the official YouGov colors with their corresponding hex codes.
#' Colors were sourced from the YouGov Marketing Portal
#'
#' @format ## `yougov_colors`
#' A named character vector with 24 elements. Access each element using e.g. `yougov_colors[["Red 1"]]` to get the hex code for "Red 1".
"yougov_colors"
