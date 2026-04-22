# Save a plot to JPEG

A short description...

## Usage

``` r
ya_save_plot(
  plot,
  fileName,
  width = 30,
  height = 15,
  resolution = 300,
  use_showtext = FALSE,
  verbose = FALSE
)
```

## Arguments

- plot:

  A plot object.

- fileName:

  A single string specifying the file path.

- width:

  Optional. A numeric value for plot width in centimeters. Defaults to
  30 cm.

- height:

  Optional. A numeric value for plot height in centimeters. Defaults to
  15 cm.

- resolution:

  Optional. A numeric value for resolution in DPI. Defaults to 300 dpi.

- use_showtext:

  Optional. A logical indicating whether to use showtext for unicode
  rendering. Defaults to FALSE.

- verbose:

  Optional. A logical indicating whether to print informative messages
  about the saved plot. Defaults to FALSE.

## Value

NULL, invisibly. The plot is saved as a JPEG file to the specified path.
If the directory does not exist, it is created.
