# Recode user-defined missing values to NA

Recode user-defined missing values to NA

## Usage

``` r
dp_recode_missing(data, missing_values = NULL)
```

## Arguments

- data:

  A haven::labelled data frame.

- missing_values:

  A numeric vector of values to be treated as missing. If NULL
  (default), the function will attempt to automatically detect
  suspicious values that may indicate missings (e.g., -99, 9999) if they
  are `<= 0` or `>= 99`.

## Value

A haven::labelled data frame with user-defined missing values recoded to
NA.
