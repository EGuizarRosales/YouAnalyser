# Calculate Importance using Johnson's Relative Weights

This function is a more efficient, though less precise, alternative to
[`kda_importance_domir()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_domir.md).
While
[`kda_importance_domir()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_domir.md)
can become computationally intensive with more than ~15 predictors, this
function scales better to larger models.

For linear regression models, relative importance is computed from each
predictor's contribution to model \\R^2\\. For logistic regression
models, relative importance is computed from each predictor's
contribution to pseudo-\\R^2\\.

## Usage

``` r
kda_importance_jrw(
  model,
  correlation_method = if (insight::model_info(model)$is_binomial) {
     "polychoric"
 }
    else {
     "pearson"
 }
)
```

## Arguments

- model:

  A model object.

- correlation_method:

  Optional. One of `"polychoric"` or `"pearson"`. Defaults to
  `"polychoric"` for binomial models and `"pearson"` otherwise.

## Value

A list containing:

- `out`: A tibble with predictor importance metrics (raw, ratio,
  percent, and rank).

- `jrw`: The Johnson's Relative Weights object.

## See also

[`kda_importance_domir()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_domir.md)
