# Save PSM data for chart in Excel template

Save PSM data for chart in Excel template

## Usage

``` r
psm_save_data_for_chart(output_psm, file_path)
```

## Arguments

- output_psm:

  A list as returned by
  [`pricesensitivitymeter::psm_analysis()`](https://max-alletsee.github.io/pricesensitivitymeter/reference/psm_analysis.html)
  or
  [`pricesensitivitymeter::psm_analysis_weighted()`](https://max-alletsee.github.io/pricesensitivitymeter/reference/psm_analysis_weighted.html).

- file_path:

  A single string specifying the file path where the Excel file will be
  saved.

## Value

NULL, invisibly. The data is saved to an Excel file at the specified
path, using a predefined template. If the directory does not exist, it
is created.
