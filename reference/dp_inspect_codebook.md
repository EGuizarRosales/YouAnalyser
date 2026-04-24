# Inspect the codebook of a labelled data frame

Inspect the codebook of a labelled data frame

## Usage

``` r
dp_inspect_codebook(data, ...)
```

## Arguments

- data:

  A labelled data frame, e.g. read in from a .sav file using
  haven::read_sav().

- ...:

  Additional arguments passed to
  [`datawizard::data_codebook()`](https://easystats.github.io/datawizard/reference/data_codebook.html),
  e.g. `variable_label_width` and `value_label_width` to control the
  width of variable labels and value labels in the output.

## Value

Prints a codebook to the console with variable names, variable labels,
value labels, and frequencies.
