# Key Driver Analysis

``` r
library(YouAnalyser)
library(haven)
```

## Recommended Workflow

The following minimal and basic workflow is recommended for performing
Key Driver Analysis (KDA) using the `YouAnalyser` package. This workflow
includes the following steps:

1.  Exploratory Data Analysis (EDA)
2.  Key Driver Analysis (KDA)
3.  Visualize and interpret the results

It is assumed that the data is already in a
[`haven::labelled()`](https://haven.tidyverse.org/reference/labelled.html)
format. If your data is not in this format, you may need to perform some
data processing steps to convert it before using `YouAnalyser`. For an
example of how to do this, please refer to the
[`vignette("dp", package = "YouAnalyser")`](https://eguizarrosales.github.io/YouAnalyser/articles/dp.md)
vignette on Data Processing.

``` r
#---- 1. EDA -------------------------------------------------------------------

# Load your data
# myData <- haven::read_sav("path/to/your/data.sav")
# Here, we will use the example data included in the package:
myData <- YouAnalyser::bkw_processed

# Get an overview of the data. Confirm there are no unexpected values
# (e.g., values like "99") and no missing values.
eda_summary(myData)

# Inspect correlations among the variables.
# Are all predictors positively correlated with the outcome variable?
# Are there any high correlations among the predictors that may indicate
# multicollinearity issues?
eda_corrs <- eda_correlation(myData)
print(eda_corrs$p)

#---- 2. KDA -------------------------------------------------------------------

# Perform Key Driver Analysis
kda <- kda_regression(
  data = myData,
  outcome = "F600",
  predictors = paste0("F800_", 1:8)
)

#---- 3. Visualize and interpret results ---------------------------------------

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
```

For the remainder of this vignette, we will focus on the different
options for conducting the KDA step (step 2 in the workflow above). For
a more detailed walkthrough of the EDA step, please refer to the
[`vignette("eda", package = "YouAnalyser")`](https://eguizarrosales.github.io/YouAnalyser/articles/eda.md)
vignette on Exploratory Data Analysis.

## The `kda_regression()` Function

The
[`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
function is the main work horse for conducting KDA. It is a wrapper
function for all the necessary steps (subfunctions) to conduct a KDA,
including fitting a regression model, calculating variable importance
and performance measures, and creating the relevant plots. The function
has several arguments that allow you to customize the analysis, such as
the choice of regression model, variable importance method, and
diagnostic options. You can get help on the function and its arguments
by running
[`help("kda_regression")`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
or
[`?kda_regression`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
in your R console.

You need to provide at least the following arguments to the
[`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
function:

- `data`, `outcome`, and `predictors`:
  - `data`: A data frame containing the outcome and predictors. The data
    needs to be in a
    [`haven::labelled()`](https://haven.tidyverse.org/reference/labelled.html)
    format, as is typically the case for SPSS data. If it is not, refer
    to the
    [`vignette("dp", package = "YouAnalyser")`](https://eguizarrosales.github.io/YouAnalyser/articles/dp.md)
    vignette on Data Processing for how to convert your data into a
    labelled format.
  - `outcome`: The name of the outcome variable (as a string).
