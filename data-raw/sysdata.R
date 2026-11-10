# Define colors for plots
# fmt: skip
yougov_colors <- c(
    "Red 1"      = "#ff412c",
    "Purple 1"   = "#9f29ff",
    "Teal 1"     = "#31caa8",
    "Pink 1"     = "#ff2380",
    "Blue 1"     = "#06a6ee",
    "Yellow 1"   = "#ffba22",
    "Purple 2"   = "#6600ab",
    "Pink 2"     = "#ff7bb3",
    "Navy 1"     = "#003cab",
    "Teal 2"     = "#83dfcb",
    "Red 2"      = "#c20800",
    "Lavender 1" = "#c57fff",
    "Salmon 1"   = "#ff8d80",
    "Blue 2"     = "#6acaf5",
    "Green 1"    = "#006b46",
    "Salmon 2"   = "#ff6756",
    "Purple 3"   = "#8001d8",
    "Pink 3"     = "#ff4f99",
    "Blue 3"     = "#006bdb",
    "Teal 3"     = "#5ad5b9",
    "Red 3"      = "#e8281e",
    "Lavender 2" = "#b254ff",
    "Green 2"    = "#149678",
    "Yellow 2"   = "#ffe146"
  )


# Categorical palette for plots with groups (e.g. clusters), used instead of
# palettes such as "jco" in factoextra. Unnamed on purpose: named vectors would
# be matched against group levels by ggplot2's manual scales.
yougov_palette <- unname(yougov_colors[c(
  "Red 1",
  "Purple 1",
  "Blue 1",
  "Teal 1",
  "Yellow 1",
  "Pink 1",
  "Navy 1",
  "Green 1",
  "Lavender 1",
  "Salmon 1",
  "Blue 2",
  "Teal 2",
  "Pink 2",
  "Yellow 2"
)])

usethis::use_data(yougov_colors, yougov_palette, internal = TRUE, overwrite = TRUE)
