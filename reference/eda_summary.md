# Exploratory data analysis: Summary of data

Generate a summary table of the data, including variable types, missing
values, and basic statistics. The summary is displayed in the browser
for easy inspection.

## Usage

``` r
eda_summary(
  data,
  variables = NULL,
  console_output = TRUE,
  browser_output = TRUE,
  describe_distribution_args = list(iqr = FALSE, quartiles = TRUE, by = NULL)
)
```

## Arguments

- data:

  A data frame to be inspected.

- variables:

  An optional vector of variable names to include in the inspection. If
  NULL, all variables are included.

- console_output:

  A logical value indicating whether to print descriptive statistics in
  the console. Defaults to TRUE.

- browser_output:

  A logical value indicating whether to display the summary table in the
  browser. Defaults to TRUE.

- describe_distribution_args:

  A list of additional arguments passed to
  [`datawizard::describe_distribution()`](https://easystats.github.io/datawizard/reference/describe_distribution.html).

- dfSummary_args:

  A list of additional arguments passed to
  [`summarytools::dfSummary()`](https://rdrr.io/pkg/summarytools/man/dfSummary.html).

## Value

A temporary html summary table of the data, which is displayed in the
browser.

## Examples

``` r
# Inspect a subset of variables in the data
eda_summary(data = bkw_missings, variables = c("F600", "F800_1", "F800_2"), console_output = TRUE, browser_output = FALSE)
#> Warning: no DISPLAY variable so Tk is not available
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> 
#> ── Data Frame Summary 
#> Data Frame Summary  
#> data  
#> Dimensions: 1216 x 3  
#> Duplicates: 1038  
#> 
#> ------------------------------------------------------------------------------------------------------------------------------------------------
#> Variable           Label                                     Stats / Values                 Freqs (% of Valid)   Graph       Valid     Missing  
#> ------------------ ----------------------------------------- ------------------------------ -------------------- ----------- --------- ---------
#> F600               Wie attraktiv finden Sie die BKW als      1. [1] 1 - Überhaupt nicht a    44 ( 3.6%)                      1211      5        
#> [haven_labelled,   Arbeitgeberin?                            2. [2] 2                        50 ( 4.1%)                      (99.6%)   (0.4%)   
#> vctrs_vctr,                                                  3. [3] 3                       132 (10.9%)          II                             
#> double]                                                      4. [4] 4                       472 (39.0%)          IIIIIII                        
#>                                                              5. [5] 5                       312 (25.8%)          IIIII                          
#>                                                              6. [6] 6                       117 ( 9.7%)          I                              
#>                                                              7. [7] 7 - Sehr attraktiv       84 ( 6.9%)          I                              
#> 
#> F800_1             Sicherheit und langfristige Stabilität    1. [1] Überhaupt nicht gut      11 ( 0.9%)                      1210      6        
#> [haven_labelled,   des Arbeitgebers                          2. [2] 2                        21 ( 1.7%)                      (99.5%)   (0.5%)   
#> vctrs_vctr,                                                  3. [3] 3                        67 ( 5.5%)          I                              
#> double]                                                      4. [4] 4                       303 (25.0%)          IIIII                          
#>                                                              5. [5] 5                       276 (22.8%)          IIII                           
#>                                                              6. [6] 6                       338 (27.9%)          IIIII                          
#>                                                              7. [7] Sehr gut  7             194 (16.0%)          III                            
#> 
#> F800_2             Karriere- und Entwicklungsmöglichkeiten   1. [1] Überhaupt nicht gut      11 ( 0.9%)                      1204      12       
#> [haven_labelled,                                             2. [2] 2                        34 ( 2.8%)                      (99.0%)   (1.0%)   
#> vctrs_vctr,                                                  3. [3] 3                        70 ( 5.8%)          I                              
#> double]                                                      4. [4] 4                       418 (34.7%)          IIIIII                         
#>                                                              5. [5] 5                       330 (27.4%)          IIIII                          
#>                                                              6. [6] 6                       244 (20.3%)          IIII                           
#>                                                              7. [7] Sehr gut  7              97 ( 8.1%)          I                              
#> ------------------------------------------------------------------------------------------------------------------------------------------------
#> 
#> ── Descriptive Statistics 
#> Variable | Mean |   SD |        Range |  Quartiles | Skewness | Kurtosis |    n | n_Missing
#> -------------------------------------------------------------------------------------------
#> F600     | 4.36 | 1.32 | [1.00, 7.00] | 4.00, 5.00 |    -0.19 |     0.44 | 1211 |         5
#> F800_1   | 5.15 | 1.29 | [1.00, 7.00] | 4.00, 6.00 |    -0.44 |    -0.11 | 1210 |         6
#> F800_2   | 4.78 | 1.21 | [1.00, 7.00] | 4.00, 6.00 |    -0.19 |     0.15 | 1204 |        12
```
