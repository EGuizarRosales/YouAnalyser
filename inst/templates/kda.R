library(YouAnalyser)
library(haven)

#### PLEASE EDIT ###############################################################

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

#### INTERACTIVE KDA ###########################################################

# Use this function to run the KDA workflow interactively.
# It will guide you through the steps of setting up the project, performing EDA, and running the KDA, while saving all results in a structured folder format. You can adjust the parameters as needed before running the function.

kda_interactive_workflow(
  path_to_data = my_path_to_data,
  outcome = myOutcome,
  predictors = myPredictors,
  preparePPTX = myPreparePPTX
)

#### CODE SNIPPETS FOR MANUAL STEPS ############################################

# As an alternative to the interactive workflow, you can run the steps manually.

# Load your data
myData <- haven::read_sav(my_path_to_data) |>
  dplyr::select(
    all_of(myOutcome),
    all_of(myPredictors)
  )

#---- 1. EDA -----

# Get an overview of the data. Confirm there are no unexpected values
# (e.g., values like "99") and no missing values.
eda_summary(myData)

# Inspect correlations among the variables.
# Are all predictors positively correlated with the outcome variable?
# Are there any high correlations among the predictors that may indicate
# multicollinearity issues?
eda_corrs <- eda_correlation(myData)
print(eda_corrs$p)

#---- 2. KDA ----

# Perform Key Driver Analysis
kda <- kda_regression(
  data = myData,
  outcome = "F600",
  predictors = paste0("F800_", 1:8),
  diagnostics = TRUE
)

#---- 3. Visualize and interpret results ----

# Inspect the Importance Performance Matrix Analysis (IPMA) plot
print(kda$plots$ipma_scatterPlot$p)

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
