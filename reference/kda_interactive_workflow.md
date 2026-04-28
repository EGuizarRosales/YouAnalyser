# Conduct an interactive KDA workflow in the console

This function guides the user through an interactive Key Driver Analysis
(KDA) workflow in the console, including exploratory data analysis
(EDA), and KDA execution. Note that the function expects to be called
within a project set up using
[`ya_setup_folder_structure()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_setup_folder_structure.md)
with `template = "kda"`.

## Usage

``` r
kda_interactive_workflow(
  path_to_data,
  outcome,
  predictors,
  preparePPTX = FALSE,
  importance_method = "auto"
)
```

## Arguments

- path_to_data:

  A string specifying the file path to the SPSS data file (a .sav file).
  The data will be copied to the project folder and read from there.

- outcome:

  A string specifying the outcome variable for the KDA.

- predictors:

  A character vector specifying the predictor variables for the KDA.

- preparePPTX:

  A logical value indicating whether to prepare a PowerPoint
  presentation with the results. Defaults to `FALSE`.

- importance_method:

  One of `"auto"`, `"domir"`, `"jrw"`, or `"sumOfCoefficients"`.
  Defaults to `"auto"`. This argument is passed to the KDA function to
  specify the method for calculating variable importance.

## Value

NULL (invisible) after guiding the user through the workflow and saving
the results. The function will open the EDA summary in the browser and
display the correlation matrix as a plot. After confirmation, it will
run the KDA and save all generated plots to the project folder.
