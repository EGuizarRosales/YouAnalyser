# Package index

## Data Processing & Exploratory Data Analysis

This section includes functions for data processing and exploratory data
analysis (EDA). These functions help you to prepare your data for
analysis, as well as to explore and understand the characteristics of
your data.

- [`eda_correlation()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_correlation.md)
  : Exploratory data analysis: correlation
- [`eda_summary()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_summary.md)
  : Exploratory data analysis: summary of data

## Key Driver Analysis

This section includes functions for conducting Key Driver Analysis
(KDA). These functions allow you to identify the key drivers of a target
variable based on a set of predictor variables, and to visualize the
results in an IPMA chart.

### KDA Helper Functions

This section includes helper functions for Key Driver Analysis (KDA).
These functions allow for more customized workflows than the main
[`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
function, which is a wrapper designed to be an end-to-end solution for
KDA. Use these helper functions if you want to have more control over
the individual steps of the KDA process.

- [`kda_forestPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_forestPlot.md)
  : Create a forest plot for model coefficients
- [`kda_importance_barPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_barPlot.md)
  : Create KDA importance bar plot
- [`kda_importance_domir()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_domir.md)
  : Perform KDA dominance analysis
- [`kda_importance_jrw()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_jrw.md)
  : Calculate Importance using Johnson's Relative Weights
- [`kda_importance_sumOfCoefficients()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_sumOfCoefficients.md)
  : Calculate feature importance using sum of coefficients
- [`kda_ipma()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_ipma.md)
  : Importance-Performance Matrix Analysis
- [`kda_ipma_scatterPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_ipma_scatterPlot.md)
  : Create an Importance-Performance Matrix Analysis scatter plot
- [`kda_performance()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_performance.md)
  : Calculate KDA performance
- [`kda_performance_barPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_performance_barPlot.md)
  : Create a KDA performance bar plot

### KDA Main Function

This section includes the main function for conducting Key Driver
Analysis (KDA), which is
[`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md).
This function is designed to be an end-to-end solution for KDA, as it
includes all the necessary steps from data preparation to model fitting
and visualization. Use this function if you want a streamlined workflow
for conducting KDA.

- [`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
  : Conduct KDA regression analysis

## YouAnalyser (YA) Helper Functions

This section includes helper functions for the YouAnalyser package.
These functions are designed to assist with various tasks related to the
package, such as copying templates for PowerPoint and Excel files, which
can be used for visualizing the results of analyses conducted with the
package.

- [`ya_save_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_save_plot.md)
  : Save a plot to JPEG

## Example Data

This section includes example datasets that are included in the
YouAnalyser package. These datasets can be used for testing and
demonstrating the functions in the package, as well as for learning how
to use the package effectively.

- [`bkw_bin`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_bin.md)
  : BKW Employer Brand Positioning Study Data (Binary)
- [`bkw_bin_outcome`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_bin_outcome.md)
  : BKW Employer Brand Positioning Study Data (Binary Outcome)
- [`bkw_bin_predictors`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_bin_predictors.md)
  : BKW Employer Brand Positioning Study Data (Binary Predictors)
- [`bkw_processed`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_processed.md)
  : BKW Employer Brand Positioning Study Data (Processed)
- [`bkw_raw`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_raw.md)
  : BKW Employer Brand Positioning Study Data (Raw)
