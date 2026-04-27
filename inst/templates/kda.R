library(YouAnalyser)
library(haven)

#### EDIT ######################################################################

#---- Define Variables ---------------------------------------------------------

# 1. Choose your raw data file in .sav format
my_path_to_data <- ya_choose_file()

# 2. Defne the names of the outcome variable and predictor variables in your data

# Outcome, e.g.,
# myOutcome <- "F600"
myOutcome <- NULL

# Predictors, e.g.,
# myPredictors <- paste0("F800_", 1:8)
myPredictors <- NULL

# Prepare PPTX Chart?
myPreparePPTX <- TRUE

#### DO NOT EDIT ###############################################################

#---- Project Setup ------------------------------------------------------------

# Copy the raw data file to the corect folder in the current project
new_path_to_data <- fs::path(
  ".",
  "01_input",
  "data",
  "raw",
  basename(my_path_to_data)
)
fs::file_copy(
  path = my_path_to_data,
  new_path = new_path_to_data
)

#---- Read in data -------------------------------------------------------------

myData <- haven::read_sav(new_path_to_data) |>
  dplyr::select(
    all_of(myOutcome),
    all_of(myPredictors)
  )

#---- 1. EDA -------------------------------------------------------------------

cli::cli_h1("Exploratory Data Analysis (EDA)")

# Get an overview of the data. Confirm there are no unexpected values
# (e.g., values like "99") and no missing values.
eda_summary(myData)

# Inspect correlations among the variables.
# Are all predictors positively correlated with the outcome variable?
# Are there any high correlations among the predictors that may indicate
# multicollinearity issues?
eda_corrs <- eda_correlation(myData)
tmp_file <- tempfile(fileext = ".jpeg")
ya_save_plot(
  plot = eda_corrs$p,
  file_path = tmp_file,
  width = 30,
  height = 20,
  verbose = FALSE
)
browseURL(tmp_file)


cli::cli_text("")
cli::cli_div(
  theme = list(
    .alert = list(color = "red"),
    li = list(color = "orange")
  )
)
cli::cli_alert_info(
  "Check the data summary (browser) and correlation matrix (picture) and confirm the following:"
)
cli::cli_ol(
  items = c(
    "Are there no unexpected values (e.g., values like {.val 99}) and no missing values in the data?",
    "Are all predictors positively correlated with the outcome variable?"
  )
)
cli::cli_end()

# Ask for confirmation in console: 1 = Yes, 2 = No
run_kda <- menu(
  choices = c("Yes!", "No, I need to work on my data again."),
  title = "\nCould you confirm the above points? Are you ready to run the KDA?"
)

if (run_kda == 2L) {
  cli::cli_abort("KDA canceled by user.")
}

if (run_kda == 0L) {
  cli::cli_abort("No option selected. KDA canceled.")
}

#---- 2. KDA -------------------------------------------------------------------

cli::cli_h1("Key Driver Analysis (KDA)")

# Perform Key Driver Analysis
kda <- kda_regression(
  data = myData,
  outcome = myOutcome,
  predictors = myPredictors,
  diagnostics = TRUE,
  importance_method = "auto"
)
cli::cli_alert_success("KDA completed successfully!")
cli::cli_alert_info(
  "Next, all created plots will be saved to the folder {.path ./03_output/plots}"
)

#---- 3. Visualize and interpret results ---------------------------------------

# Save all plots
suppressMessages(
  purrr::iwalk(
    .x = kda$plots,
    .f = \(x, name) {
      ya_save_plot(
        plot = x$p,
        file_path = paste0(
          "./03_output/plots/",
          name,
          ".jpeg"
        ),
        width = 30,
        height = 20,
        verbose = FALSE
      )
    }
  )
)
cli::cli_alert_success("All plots saved successfully!")

# Inspect the Importance Performance Matrix Analysis (IPMA) plot
cli::cli_h3("Your Main Output: The IPMA Plot")
print(kda$plots$ipma_scatterPlot$p)
cli::cli_alert(
  "Look at the output in your plots pane, also saved here: {.file ./03_output/plots/ipma_scatterPlot.jpeg}"
)

# Save the IPMA plot as a file
ya_save_plot(
  plot = kda$plots$ipma_scatterPlot$p,
  file_path = ya_choose_file_path("myPlotName.jpeg"),
  width = 30,
  height = 20
)

# If you need a PowerPoint report:

# 1. Export the KDA results into a formatted Excel template:
kda_save_data_for_chart(
  ipma_scatterPlot_data = kda$plots$ipma_scatterPlot$d,
  file_path = ya_choose_file_path("myKDAresults.xlsx")
)

# 2. Copy the PowerPoint template provided within YouAnalyser to a
# location of your choice:
kda_copy_pptx_template(
  file_path = ya_choose_file_path("myKDAReport.pptx")
)
