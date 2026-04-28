# Set up a standardized folder structure for a project

Set up a standardized folder structure for a project, including
subfolders for input data, scripts, and output. Optionally, copy a
template script into the scripts folder and create an R project file in
the main folder. The function provides informative messages about the
created folder structure and any actions taken.

## Usage

``` r
ya_setup_folder_structure(
  folder_name,
  base_path = tcltk::tk_choose.dir(),
  template = NULL,
  make_rproj = TRUE
)
```

## Arguments

- folder_name:

  A single string specifying the name of the main folder to be created
  within the base directory. This folder will contain the standardized
  subfolder structure for organizing project files.

- base_path:

  A single string specifying the base directory where the folder
  structure should be created.

- template:

  Optional. A single string specifying the name of the template file to
  be copied into the scripts folder. The template should be an R script
  located in the "templates" directory of the YouAnalyser package.
  Currently, `"kda"` is supported

- make_rproj:

  Optional. A logical value indicating whether to create an R project
  file in the main folder. Defaults to TRUE.

## Value

NULL, invisibly. The function creates a standardized folder structure
for a project at the specified location and optionally copies a template
script and creates an R project file. Informative messages about the
created folder structure are printed to the console.
