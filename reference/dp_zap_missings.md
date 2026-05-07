# Zap missing values and their labels

Zap missing values and their labels

## Usage

``` r
dp_zap_missings(data, missing_labels = NULL)
```

## Arguments

- data:

  A haven::labelled data frame.

- missing_labels:

  A character vector of missing value labels. If NULL (default), the
  function will attempt to automatically detect suspicious values that
  may indicate missings (e.g., -99, 9999) if they are `<= 0` or `>= 99`.

## Value

A haven::labelled data frame with missing values and their labels
removed.
