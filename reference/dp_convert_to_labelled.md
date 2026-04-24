# Convert a data frame to a labelled data frame using a codebook

Convert a data frame to a labelled data frame using a codebook

## Usage

``` r
dp_convert_to_labelled(data, codebook)
```

## Arguments

- data:

  A data frame to be converted to a labelled data frame, e.g. read in
  from a .csv or .xlsx file.

- codebook:

  A data frame containing the codebook information, with columns
  "variable", "variable_label", "value", and "value_label".

## Value

A
[`haven::labelled`](https://haven.tidyverse.org/reference/labelled.html)
data frame with variable labels and value labels added according to the
provided codebook.

## Examples

``` r
# `data` should be a unlabelled data frame
print(head(bkw_unlabelled, 5), n = Inf)
#> # A tibble: 5 × 15
#>    F600 F800_1 F800_2 F800_3 F800_4 F800_5 F800_6 F800_7 F800_8 F800_9 F800_10
#>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>
#> 1     4      4      4      4      4      4      4      4      4      4       4
#> 2     2      3      3      3      3      3      3      3      3      3       3
#> 3     2      4      4      4      4      4      4      4      4      4       4
#> 4     4      6      6      6      6      6      6      6      6      6       6
#> 5     4      7      4      4      4      4      4      4      4      4       4
#> # ℹ 4 more variables: F800_11 <dbl>, F800_12 <dbl>, F800_13 <dbl>,
#> #   F800_14 <dbl>

# `codebook` should be a data frame with columns "variable", "variable_label", "value", and "value_label" in *long* format
print(head(bkw_labels, 3*7), n = Inf)
#> # A tibble: 21 × 4
#>    variable variable_label                                     value value_label
#>    <chr>    <chr>                                              <dbl> <chr>      
#>  1 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     1 1 - Überha…
#>  2 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     2 2          
#>  3 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     3 3          
#>  4 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     4 4          
#>  5 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     5 5          
#>  6 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     6 6          
#>  7 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     7 7 - Sehr a…
#>  8 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     1 Überhaupt …
#>  9 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     2 2          
#> 10 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     3 3          
#> 11 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     4 4          
#> 12 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     5 5          
#> 13 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     6 6          
#> 14 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     7 Sehr gut  7
#> 15 F800_2   Karriere- und Entwicklungsmöglichkeiten                1 Überhaupt …
#> 16 F800_2   Karriere- und Entwicklungsmöglichkeiten                2 2          
#> 17 F800_2   Karriere- und Entwicklungsmöglichkeiten                3 3          
#> 18 F800_2   Karriere- und Entwicklungsmöglichkeiten                4 4          
#> 19 F800_2   Karriere- und Entwicklungsmöglichkeiten                5 5          
#> 20 F800_2   Karriere- und Entwicklungsmöglichkeiten                6 6          
#> 21 F800_2   Karriere- und Entwicklungsmöglichkeiten                7 Sehr gut  7

# Convert the unlabelled data to a labelled data frame using the codebook
data_labelled <- dp_convert_to_labelled(bkw_unlabelled, bkw_labels)
print(head(data_labelled, 5), n = Inf)
#> # A tibble: 5 × 15
#>   F600   F800_1  F800_2 F800_3 F800_4 F800_5 F800_6 F800_7 F800_8 F800_9 F800_10
#>   <dbl+> <dbl+l> <dbl+> <dbl+> <dbl+> <dbl+> <dbl+> <dbl+> <dbl+> <dbl+> <dbl+l>
#> 1 4 [4]  4 [4]   4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  
#> 2 2 [2]  3 [3]   3 [3]  3 [3]  3 [3]  3 [3]  3 [3]  3 [3]  3 [3]  3 [3]  3 [3]  
#> 3 2 [2]  4 [4]   4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  
#> 4 4 [4]  6 [6]   6 [6]  6 [6]  6 [6]  6 [6]  6 [6]  6 [6]  6 [6]  6 [6]  6 [6]  
#> 5 4 [4]  7 [Seh… 4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  4 [4]  
#> # ℹ 4 more variables: F800_11 <dbl+lbl>, F800_12 <dbl+lbl>, F800_13 <dbl+lbl>,
#> #   F800_14 <dbl+lbl>
```
