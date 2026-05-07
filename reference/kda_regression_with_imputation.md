# Conduct KDA with imputation of missing values

Conduct KDA with imputation of missing values

## Usage

``` r
kda_regression_with_imputation(
  data,
  outcome = NULL,
  predictors = NULL,
  model = NULL,
  imputation_args = list(m = 100, method = "pmm", seed = 123, printFlag = FALSE),
  importance_method = "auto",
  show_progress = TRUE,
  imputation_aggregation_function = "median",
  display_imputation_info = TRUE
)
```

## Arguments

- data:

  A data frame with missing data containing the outcome and predictors.
  Optional if model is provided.

- outcome:

  A single string naming the outcome variable. Optional if model is
  provided.

- predictors:

  A character vector of predictor variable names. Optional if model is
  provided.

- model:

  A fitted regression model object. Optional if data, outcome, and
  predictors are provided.

- imputation_args:

  A list of arguments passed to the mice function for imputation.
  Defaults to
  `list(m = 100, method = "pmm", seed = 123, printFlag = FALSE)`, which
  translates 100 imputations with the predictive mean matching method
  and a seed of 123 for reproducibility. See
  [`mice::mice()`](https://amices.org/mice/reference/mice.html) for
  details.

- importance_method:

  A string specifying the method for calculating variable importance.
  Options are 'auto', 'domir', 'jrw', or 'sumOfCoefficients'. Defaults
  to 'auto'.

- show_progress:

  A logical indicating whether to show progress during the application
  of the different kda functions to the imputed datasets. Defaults to
  TRUE.

- imputation_aggregation_function:

  A string specifying the function to aggregate imputed values. Defaults
  to 'median' but could also be set to 'mean'.

- display_imputation_info:

  A logical indicating whether to display information about the
  imputation parameters in the subtitle of plots. Defaults to TRUE.

## Value

A list containing model results, importance measures, performance
metrics, IPMA analysis, and associated plots. Errors if neither model
nor all of data, outcome, and predictors are provided.
