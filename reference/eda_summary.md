# Exploratory data analysis: summary of data

Generate a summary table of the data, including variable types, missing
values, and basic statistics. The summary is displayed in the browser
for easy inspection.

## Usage

``` r
eda_summary(data, variables = NULL)
```

## Arguments

- data:

  A data frame to be inspected.

- variables:

  An optional vector of variable names to include in the inspection. If
  NULL, all variables are included.

## Value

A temporary html summary table of the data, which is displayed in the
browser.

## Examples

``` r
# Inspect a subset of variables in the data
eda_summary(bkw_raw, variables = c("F600", "F800_1", "F800_2"))
#> Warning: no DISPLAY variable so Tk is not available
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Output file written: /tmp/Rtmp8EpjGS/file1bf6592c248b.html
# Inspect all variables in the data
eda_summary(bkw_processed)
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Warning: unable to open connection to X11 display ''
#> Output file written: /tmp/Rtmp8EpjGS/file1bf61ae5ee43.html
```
