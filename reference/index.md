# Package index

## Data Processing

Function to process survey data, including adding and inspecting
variable and value labels.

- [`dp_convert_to_labelled()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_convert_to_labelled.md)
  : Convert a data frame to a labelled data frame using a codebook
- [`dp_copy_codebook_template()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_copy_codebook_template.md)
  : Copy a codebook template to a specified file path
- [`dp_inspect_codebook()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_inspect_codebook.md)
  : Inspect the codebook of a labelled data frame

## Exploratory Data Analysis (EDA)

Functions to perform exploratory data analysis (EDA) on survey data,
including summary statistics and correlations.

- [`eda_correlation()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_correlation.md)
  : Exploratory data analysis: correlation
- [`eda_summary()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_summary.md)
  : Exploratory data analysis: Summary of data

## Key Driver Analysis (KDA)

Functions to perform KDA on survey data.
[`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
is the main end-to-end function that runs the entire KDA process, while
the other functions are helper functions that can be used to run
specific steps of the KDA process.

- [`kda_copy_pptx_template()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_copy_pptx_template.md)
  : Copy PowerPoint template to specified file path
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
- [`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
  : Conduct KDA regression analysis
- [`kda_save_data_for_chart()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_save_data_for_chart.md)
  : Save KDA data for chart in Excel template

## YouAnalyser (YA) Utility Functions

Miscellaneous utility functions for the YouAnalyser package.

- [`ya_choose_file()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_choose_file.md)
  : Choose a file and return its path
- [`ya_choose_file_path()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_choose_file_path.md)
  : Choose a directory and create a file path
- [`ya_save_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_save_plot.md)
  : Save a plot to JPEG

## Example Data

Example datasets included in the YouAnalyser package.

- [`bkw_bin`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_bin.md)
  : BKW Employer Brand Positioning Study Data (Binary)
- [`bkw_bin_outcome`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_bin_outcome.md)
  : BKW Employer Brand Positioning Study Data (Binary Outcome)
- [`bkw_bin_predictors`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_bin_predictors.md)
  : BKW Employer Brand Positioning Study Data (Binary Predictors)
- [`bkw_labels`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_labels.md)
  : BKW Employer Brand Positioning Study Data (Variable and Value
  Labels)
- [`bkw_processed`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_processed.md)
  : BKW Employer Brand Positioning Study Data (Processed)
- [`bkw_raw`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_raw.md)
  : BKW Employer Brand Positioning Study Data (Raw)
- [`bkw_unlabelled`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_unlabelled.md)
  : BKW Employer Brand Positioning Study Data (Unlabelled Data)

## Other Functions

Other functions or data that do not fit into the above categories.

- [`yougov_colors`](https://eguizarrosales.github.io/YouAnalyser/reference/yougov_colors.md)
  : YouGov Colors
