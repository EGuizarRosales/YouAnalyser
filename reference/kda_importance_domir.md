# Perform KDA dominance analysis

A short description...

## Usage

``` r
kda_importance_domir(model, domir_args = list(.set = NULL))
```

## Arguments

- model:

  A fitted model object.

- domir_args:

  Optional. A list of arguments to pass to
  [`domir::domir()`](https://jluchman.github.io/domir/reference/domir.html).

## Value

A list containing:

- `out`: A tibble with predictor importance metrics (raw, ratio,
  percent, and rank).

- `da`: The raw dominance analysis object from
  [`domir::domir()`](https://jluchman.github.io/domir/reference/domir.html).
