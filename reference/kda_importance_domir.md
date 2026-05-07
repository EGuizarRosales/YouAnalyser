# Perform KDA dominance analysis

A short description...

## Usage

``` r
kda_importance_domir(
  model,
  domir_args = list(sets = NULL, all = NULL, conditional = TRUE, complete = FALSE,
    consmodel = NULL, reverse = FALSE),
  verbose = FALSE
)
```

## Arguments

- model:

  A fitted model object.

- domir_args:

  Optional. A list of arguments to pass to
  [`domir::domin()`](https://jluchman.github.io/domir/reference/domin.html).

- verbose:

  Logical. Whether to print messages to the console. Defaults to
  `FALSE`.

## Value

A list containing:

- `out`: A tibble with predictor importance metrics (raw, ratio,
  percent, and rank).

- `da`: The raw dominance analysis object from
  [`domir::domin()`](https://jluchman.github.io/domir/reference/domin.html).
