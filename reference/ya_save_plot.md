# Save a plot to JPEG

Saves a plot object as a JPEG file to the specified file path. The
function ensures that the directory exists (creating it if necessary)
and provides options for customizing the plot dimensions, resolution,
and whether to use the showtext package for rendering unicode
characters. Informative messages about the saved plot can also be
printed if `verbose` is set to TRUE.

## Usage

``` r
ya_save_plot(
  plot,
  file_path,
  width = 30,
  height = 15,
  resolution = 300,
  use_showtext = FALSE,
  verbose = TRUE
)
```

## Arguments

- plot:

  A plot object.

- file_path:

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
