# Save KDA data for chart in Excel template

Save KDA data for chart in Excel template

## Usage

``` r
kda_save_data_for_chart(ipma_scatterPlot_data, file_path)
```

## Arguments

- ipma_scatterPlot_data:

  The data frame containing the data used for the IPMA scatter plot.
  This should be the output of the `ipma_scatterPlot` element in the
  list returned by
  [`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md).

- file_path:

  A single string specifying the file path where the Excel file will be
  saved.

## Value

NULL, invisibly. The data is saved to an Excel file at the specified
path, using a predefined template. If the directory does not exist, it
is created.
