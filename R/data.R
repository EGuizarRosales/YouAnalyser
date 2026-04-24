#' BKW Employer Brand Positioning Study Data (Raw)
#'
#' Raw data from the BKW Employer Brand Positioning Study conducted in 2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026).
#' Key Driver Analyses (linear regression with dominance analysis) were performed.
#' The data includes the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model.
#'
#' @format ## `bkw_raw`
#' A data frame with 5,523 rows and 220 columns:
#' \describe{
#'   \item{RecordNo}{Record number, starting from 0}
#'   \item{caseid}{unique identifier for each case}
#'   \item{endtime}{End time of the survey}
#'   ...
#' }
"bkw_raw"

#' BKW Employer Brand Positioning Study Data (Processed)
#'
#' Processed data from the BKW Employer Brand Positioning Study conducted in 2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026).
#' Key Driver Analyses (linear regression with dominance analysis) were performed.
#' The data was processed to only include the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model.
#' All NA values in the dependent variable (F600) were removed to ensure the data is ready for analysis.
#'
#' @format ## `bkw_processed`
#' A data frame with 1,216 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_processed"

#' BKW Employer Brand Positioning Study Data (Binary)
#'
#' Binary data from the BKW Employer Brand Positioning Study conducted in 2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026).
#' Key Driver Analyses (linear regression with dominance analysis) were performed.
#' The data was processed to only include the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model.
#' All NA values in the dependent variable (F600) were removed to ensure the data is ready for analysis.
#' The dependent variable (F600) was dichotomized into a binary variable (0: "Nicht attraktiv", 1: "Attraktiv") based on a cutoff of 4. The independent variables (F800_1 to F800_14) were also dichotomized into binary variables (0: "Nicht gut", 1: "Gut") based on a cutoff of 4.
#'
#' @format ## `bkw_bin`
#' A data frame with 1,216 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (0: Nicht attraktiv, 1: Attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (0: Nicht gut, 1: Gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_bin"

#' BKW Employer Brand Positioning Study Data (Binary Outcome)
#'
#' Data from the BKW Employer Brand Positioning Study conducted in 2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026) with binarized outcome.
#' Key Driver Analyses (linear regression with dominance analysis) were performed.
#' The data was processed to only include the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model.
#' All NA values in the dependent variable (F600) were removed to ensure the data is ready for analysis.
#' The dependent variable (F600) was dichotomized into a binary variable (0: "Nicht attraktiv", 1: "Attraktiv") based on a cutoff of 4.
#'
#' @format ## `bkw_bin_outcome`
#' A data frame with 1,216 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (0: Nicht attraktiv, 1: Attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_bin_outcome"

#' BKW Employer Brand Positioning Study Data (Binary Predictors)
#'
#' Data from the BKW Employer Brand Positioning Study conducted in 2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026) with binarized predictors.
#' Originally, Key Driver Analyses (linear regression with dominance analysis) were performed.
#' The data was processed to only include the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model.
#' All NA values in the dependent variable (F600) were removed to ensure the data is ready for analysis.
#' The independent variables (F800_1 to F800_14) were dichotomized into binary variables (0: "Nicht gut", 1: "Gut") based on a cutoff of 4.
#'
#' @format ## `bkw_bin_predictors`
#' A data frame with 1,216 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (0: Nicht gut, 1: Gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_bin_predictors"

#' BKW Employer Brand Positioning Study Data (Unlabelled Data)
#'
#' Processed data from the BKW Employer Brand Positioning Study conducted in 2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026).
#' Key Driver Analyses (linear regression with dominance analysis) were performed.
#' The data was processed to only include the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model.
#' All NA values in the dependent variable (F600) were removed to ensure the data is ready for analysis. The data contains no variable labels or value labels, mimicking
#' a typical dataset that user might have read in from a .csv or .xlsx file.
#'
#' @format ## `bkw_unlabelled`
#' A data frame with 1,216 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_unlabelled"

#' BKW Employer Brand Positioning Study Data (Variable and Value Labels)
#'
#' Variable and value labels for data from the BKW Employer Brand Positioning Study conducted in 2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026).
#' Key Driver Analyses (linear regression with dominance analysis) were performed.
#' The data was processed to only include the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model.
#' All NA values in the dependent variable (F600) were removed to ensure the data is ready for analysis.
#' The data only contains variable labels and value labels, providing a codebook additionally needed if unlabelled data is read in, e.g. using .xlsx or .csv files..
#'
#' @format ## `bkw_labels`
#' A data frame with 1,216 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_labels"
