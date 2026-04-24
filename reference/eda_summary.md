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
eda_summary(data = bkw_raw, variables = c("F600", "F800_1", "F800_2"), console_output = TRUE, browser_output = FALSE)
#> Warning: no DISPLAY variable so Tk is not available
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> 
#> ── Data Frame Summary ──────────────────────────────────────────────────────────
#> Data Frame Summary  
#> data  
#> Label: File created by user 'ana-maria.nedelcu' at Wed Feb 11 11:11  
#> Dimensions: 5523 x 3  
#> Duplicates: 5353  
#> 
#> ------------------------------------------------------------------------------------------------------------------------------------------------
#> Variable           Label                                     Stats / Values                 Freqs (% of Valid)   Graph       Valid     Missing  
#> ------------------ ----------------------------------------- ------------------------------ -------------------- ----------- --------- ---------
#> F600               Wie attraktiv finden Sie die BKW als      1. [1] 1 - Überhaupt nicht a    54 ( 4.4%)                      1216      4307     
#> [haven_labelled,   Arbeitgeberin?                            2. [2] 2                        59 ( 4.9%)                      (22.0%)   (78.0%)  
#> vctrs_vctr,                                                  3. [3] 3                       116 ( 9.5%)          I                              
#> double]                                                      4. [4] 4                       470 (38.7%)          IIIIIII                        
#>                                                              5. [5] 5                       305 (25.1%)          IIIII                          
#>                                                              6. [6] 6                       132 (10.9%)          II                             
#>                                                              7. [7] 7 - Sehr attraktiv       80 ( 6.6%)          I                              
#> 
#> F800_1             Sicherheit und langfristige Stabilität    1. [1] Überhaupt nicht gut      18 ( 1.5%)                      1216      4307     
#> [haven_labelled,   des Arbeitgebers                          2. [2] 2                        19 ( 1.6%)                      (22.0%)   (78.0%)  
#> vctrs_vctr,                                                  3. [3] 3                        61 ( 5.0%)          I                              
#> double]                                                      4. [4] 4                       310 (25.5%)          IIIII                          
#>                                                              5. [5] 5                       274 (22.5%)          IIII                           
#>                                                              6. [6] 6                       334 (27.5%)          IIIII                          
#>                                                              7. [7] Sehr gut  7             200 (16.4%)          III                            
#> 
#> F800_2             Karriere- und Entwicklungsmöglichkeiten   1. [1] Überhaupt nicht gut      19 ( 1.6%)                      1216      4307     
#> [haven_labelled,                                             2. [2] 2                        24 ( 2.0%)                      (22.0%)   (78.0%)  
#> vctrs_vctr,                                                  3. [3] 3                        73 ( 6.0%)          I                              
#> double]                                                      4. [4] 4                       415 (34.1%)          IIIIII                         
#>                                                              5. [5] 5                       339 (27.9%)          IIIII                          
#>                                                              6. [6] 6                       240 (19.7%)          III                            
#>                                                              7. [7] Sehr gut  7             106 ( 8.7%)          I                              
#> ------------------------------------------------------------------------------------------------------------------------------------------------
#> 
#> ── Descriptive Statistics ──────────────────────────────────────────────────────
#> Variable | Mean |   SD |        Range |  Quartiles | Skewness | Kurtosis |    n | n_Missing
#> -------------------------------------------------------------------------------------------
#> F600     | 4.34 | 1.36 | [1.00, 7.00] | 4.00, 5.00 |    -0.28 |     0.35 | 1216 |      4307
#> F800_1   | 5.14 | 1.32 | [1.00, 7.00] | 4.00, 6.00 |    -0.51 |     0.12 | 1216 |      4307
#> F800_2   | 4.79 | 1.23 | [1.00, 7.00] | 4.00, 6.00 |    -0.27 |     0.37 | 1216 |      4307
```
