# YouGov Palette

An unnamed character vector of YouGov colors (taken from
[yougov_colors](https://eguizarrosales.github.io/YouAnalyser/reference/yougov_colors.md))
in a fixed order, for plots that color groups such as clusters or
segments. Use it wherever a palette of colors is expected, e.g. as the
`palette` argument of factoextra functions (instead of e.g. `"jco"`) or
in
[`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
/
[`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Usage

``` r
yougov_palette
```

## Format

### `yougov_palette`

An unnamed character vector with 14 hex codes, in this order: Red 1,
Purple 1, Blue 1, Teal 1, Yellow 1, Pink 1, Navy 1, Green 1, Lavender 1,
Salmon 1, Blue 2, Teal 2, Pink 2, Yellow 2 (see
[yougov_colors](https://eguizarrosales.github.io/YouAnalyser/reference/yougov_colors.md)).

## Details

The vector is unnamed on purpose: named vectors are matched against the
group levels by ggplot2's manual scales.

## Examples

``` r
yougov_palette[1:4]
#> [1] "#ff412c" "#9f29ff" "#06a6ee" "#31caa8"
```
