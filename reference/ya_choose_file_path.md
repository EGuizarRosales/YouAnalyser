# Choose an existing directory and define a new file in this directory, returning the full file path

Choose an existing directory and define a new file in this directory,
returning the full file path

## Usage

``` r
ya_choose_file_path(file_name)
```

## Arguments

- file_name:

  A single string specifying the file name to be appended to the chosen
  directory path.

## Value

A single string representing the full file path, combining the chosen
directory and the provided file name. The function normalizes the
directory path to use forward slashes and ensures that the specified
directory exists.

## Examples

``` r
if (FALSE) { # interactive()
ya_choose_file_path("my_plot.jpg")
}
```
