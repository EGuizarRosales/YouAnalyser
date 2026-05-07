# 1. Data Processing

``` r

library(YouAnalyser)
#> 
#> ── Welcome to YouAnalyser! ─────────────────────────────────────────────────────
#> ✔ Package loaded successfully!
#> Type `?YouAnalyser` to see the documentation.
#> Visit the package's website for more information:
#> <https://eguizarrosales.github.io/YouAnalyser/>
library(haven)
```

## Labelled Survey Data

In a best case scenario, survey data is collected in a format that
preserves the metadata of the survey, such as variable labels and value
labels. This is often the case when data is collected using YouGov’s own
**Gryphon** or other software solutions like **Quantilope**,
**Qualtrics** or **SurveyMonkey**, which can export data in formats that
retain this information, most commonly SPSS `.sav` files.

In this case, not only the names of the variables (e.g. “F600”) and the
values (e.g. “1”, “2”, “3”) are preserved, but also the labels that
describe what these variables and values represent:

- **Variable labels:** These provide a human-readable description of
  what each variable represents. For example, a variable named “F600”
  might have a label like *“Wie attraktiv finden Sie die BKW als
  Arbeitgeberin?”*, which makes it clear what the question was
  participants answered.
- **Value labels:** These provide a human-readable description of what
  each value represents. For example, a value of “1” for the variable
  “F600” might have a label like *“1 - Überhaupt nicht attraktiv”*,
  which makes it clear what the response option was for participants.

When you import such a labelled dataset into R using the
[`haven::read_sav()`](https://haven.tidyverse.org/reference/read_spss.html)
function, you can easily access both the variable labels and value
labels. The `YouAnalyser` package provides functions to work with this
metadata, allowing you to quickly understand and analyze your survey
data without having to manually decode the variable and value names.

``` r

# Provide a file path to your labelled survey data in SPSS .sav format.
# Here we accesss the example data shipped with the `YouAnalyser` package.
file_path <- system.file(
  "extdata",
  "bkw.sav",
  package = "YouAnalyser",
  mustWork = FALSE
)

# Read in the data using haven::read_sav() and filter/select relevant variables
myData <- haven::read_sav(file = file_path) |>
  # Filter out missing values for the dependent variable F600
  dplyr::filter(!is.na(F600)) |>
  # Select only the dependent variable F600 and the independent variables F800
  dplyr::select("F600", dplyr::starts_with("F800_"))
```

``` r

# Inspect the structure of the data for the first two variables. Take note of
# the attributes "@label" (variable label) and "@labels" (value labels).
str(myData[, 1:2])
#> tibble [1,104 × 2] (S3: tbl_df/tbl/data.frame)
#>  $ F600  : dbl+lbl [1:1104] 5, 3, 6, 2, 4, 5, 5, 5, 5, 5, 4, 3, 4, 4, 5, 4, 4, 4,...
#>    ..@ label      : chr "Wie attraktiv finden Sie die BKW als Arbeitgeberin?"
#>    ..@ format.spss: chr "F8.2"
#>    ..@ labels     : Named num [1:7] 1 2 3 4 5 6 7
#>    .. ..- attr(*, "names")= chr [1:7] "1 - Überhaupt nicht attraktiv" "2" "3" "4" ...
#>  $ F800_1: dbl+lbl [1:1104] 6, 6, 7, 5, 4, 6, 4, 5, 7, 7, 7, 3, 4, 6, 7, 5, 4, 5,...
#>    ..@ label      : chr "Sicherheit und langfristige Stabilität des Arbeitgebers"
#>    ..@ format.spss: chr "F8.2"
#>    ..@ labels     : Named num [1:7] 1 2 3 4 5 6 7
#>    .. ..- attr(*, "names")= chr [1:7] "Überhaupt nicht gut  1" "2" "3" "4" ...
```

There are different ways you can inspect the variable and value labels
in R, e.g.:

``` r

# Access variable label
attr(myData$F600, "label")
#> [1] "Wie attraktiv finden Sie die BKW als Arbeitgeberin?"

# Access value labels
attr(myData$F600, "labels")
#> 1 - Überhaupt nicht attraktiv                             2 
#>                             1                             2 
#>                             3                             4 
#>                             3                             4 
#>                             5                             6 
#>                             5                             6 
#>            7 - Sehr attraktiv 
#>                             7

# Prettier with the haven::print_labels() function
haven::print_labels(myData$F600)
#> 
#> Labels:
#>  value                         label
#>      1 1 - Überhaupt nicht attraktiv
#>      2                             2
#>      3                             3
#>      4                             4
#>      5                             5
#>      6                             6
#>      7            7 - Sehr attraktiv
```

`YouAnalyser` provides the
[`dp_inspect_codebook()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_inspect_codebook.md)
function to print a codebook of your labelled data to your console,
which includes the variable labels and value labels in a tidy format:

``` r

# Print codebook for the first two variables
dp_inspect_codebook(myData[, 1:2])
#> data (1104 rows and 2 variables, 2 shown)
#> 
#> ID | Name   | Label          | Type    | Missings | Values | Value Labels       |           N
#> ---+--------+----------------+---------+----------+--------+--------------------+------------
#> 1  | F600   | Wie attraktiv  | numeric | 0 (0.0%) |      1 | 1 - Überhaupt...   |  42 ( 3.8%)
#>    |        | finden Sie die |         |          |      2 | 2                  |  49 ( 4.4%)
#>    |        | BKW als        |         |          |      3 | 3                  | 127 (11.5%)
#>    |        | Arbeitgeberin? |         |          |      4 | 4                  | 443 (40.1%)
#>    |        |                |         |          |      5 | 5                  | 282 (25.5%)
#>    |        |                |         |          |      6 | 6                  | 100 ( 9.1%)
#>    |        |                |         |          |      7 | 7 - Sehr...        |  61 ( 5.5%)
#> ---+--------+----------------+---------+----------+--------+--------------------+------------
#> 2  | F800_1 | Sicherheit und | numeric | 0 (0.0%) |      1 | Überhaupt nicht... |  11 ( 1.0%)
#>    |        | langfristige   |         |          |      2 | 2                  |  21 ( 1.9%)
#>    |        | Stabilität des |         |          |      3 | 3                  |  65 ( 5.9%)
#>    |        | Arbeitgebers   |         |          |      4 | 4                  | 295 (26.7%)
#>    |        |                |         |          |      5 | 5                  | 256 (23.2%)
#>    |        |                |         |          |      6 | 6                  | 300 (27.2%)
#>    |        |                |         |          |      7 | Sehr gut  7        | 156 (14.1%)
#> ---------------------------------------------------------------------------------------------
```

## Convert Unlabelled to Labelled Data

Sometimes, your data comes in an unlabelled format, for example if you
receive a `.csv` or a `.xlsx` file. Then, this data looks like this:

``` r

# Provide a file path to your unlabelled survey data in Excel .xlsx format.
# Here we accesss the example data shipped with the `YouAnalyser` package.
file_path <- system.file(
  "extdata",
  "bkw_unlabelled.xlsx",
  package = "YouAnalyser",
  mustWork = TRUE
)

# Read in the unlabelled data using openxlsx::read.xlsx() and convert it to a tibble
myData_unlabelled <- openxlsx::read.xlsx(file_path) |>
  tibble::as_tibble()
```

``` r

# Inspect the structure of the data for the first two variables.
# Note that there are no variable labels or value labels.
str(myData_unlabelled[, 1:2])
#> tibble [1,104 × 2] (S3: tbl_df/tbl/data.frame)
#>  $ F600  : num [1:1104] 5 3 6 2 4 5 5 5 5 5 ...
#>   ..- attr(*, "label")= chr "Wie attraktiv finden Sie die BKW als Arbeitgeberin?"
#>   ..- attr(*, "format.spss")= chr "F8.2"
#>  $ F800_1: num [1:1104] 6 6 7 5 4 6 4 5 7 7 ...
#>   ..- attr(*, "label")= chr "Sicherheit und langfristige Stabilität des Arbeitgebers"
#>   ..- attr(*, "format.spss")= chr "F8.2"

# `dp_inspect_codebook()` also confirms that there are no variable labels or
#  value labels in the unlabelled data.
dp_inspect_codebook(myData_unlabelled)
#> data (1104 rows and 15 variables, 15 shown)
#> 
#> ID | Name    | Label                     | Type    | Missings | Values |    N
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 1  | F600    | Wie attraktiv             | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | finden Sie die            |         |          |        |     
#>    |         | BKW als                   |         |          |        |     
#>    |         | Arbeitgeberin?            |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 2  | F800_1  | Sicherheit und            | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | langfristige              |         |          |        |     
#>    |         | Stabilität des            |         |          |        |     
#>    |         | Arbeitgebers              |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 3  | F800_2  | Karriere- und             | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | Entwicklungsmöglichkeiten |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 4  | F800_3  | Sinnvolle                 | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | Tätigkeit und             |         |          |        |     
#>    |         | gesellschaftlicher        |         |          |        |     
#>    |         | Beitrag                   |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 5  | F800_4  | Gute                      | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | Zusammenarbeit            |         |          |        |     
#>    |         | und Teamkultur            |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 6  | F800_5  | Vereinbarkeit             | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | von Beruf und             |         |          |        |     
#>    |         | Privatleben               |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 7  | F800_6  | Moderne                   | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | Arbeitsumgebung           |         |          |        |     
#>    |         | und                       |         |          |        |     
#>    |         | Technologien              |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 8  | F800_7  | Attraktive                | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | Vergütung und             |         |          |        |     
#>    |         | Zusatzleistungen          |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 9  | F800_8  | Gute Führung              | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | und                       |         |          |        |     
#>    |         | wertschätzende            |         |          |        |     
#>    |         | Unternehmenskultur        |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 10 | F800_9  | Verantwortung             | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | und                       |         |          |        |     
#>    |         | Gestaltungsspielraum      |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 11 | F800_10 | Zukunftsorientierung      | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | und                       |         |          |        |     
#>    |         | Nachhaltigkeit            |         |          |        |     
#>    |         | des                       |         |          |        |     
#>    |         | Unternehmens              |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 12 | F800_11 | Internationales           | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | Arbeitsumfeld             |         |          |        |     
#>    |         | und kulturelle            |         |          |        |     
#>    |         | Vielfalt                  |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 13 | F800_12 | Innovationskultur         | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | und                       |         |          |        |     
#>    |         | Veränderungsbereitschaft  |         |          |        |     
#>    |         | des                       |         |          |        |     
#>    |         | Unternehmens              |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 14 | F800_13 | Arbeitszeit-              | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | und                       |         |          |        |     
#>    |         | Arbeitsortflexibilität    |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 15 | F800_14 | Diversität,               | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |         | Gleichstellung            |         |          |        |     
#>    |         | und Inklusion             |         |          |        |     
#> -----------------------------------------------------------------------------

# The missing variable and value labels are also confirmed by the haven::is.labelled()
# function, which returns FALSE for all variables in the unlabelled data.
haven::is.labelled(myData_unlabelled)
#> [1] FALSE
```

In this case, you can use the
[`dp_convert_to_labelled()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_convert_to_labelled.md)
function to convert your unlabelled data into a labelled format, which
will allow you to work with variable and value labels in R and in
`YouAnalyser`.

To do this, you need to provide the data as well as a **codebook** that
contains the variable labels and value labels for your data. The
codebook should be in a tidy format, with one row per variable and
columns for the variable name, variable label, and value labels. This
codebook can be created manually using a spreadsheet software like
Excel. Use the following code to save a copy of the codebook template
provided with `YouAnalyser`:

``` r

# Choose interactively where the template should be copied to
file_path <- ya_choose_file_path("my_codebook.xlsx")

# Copy the template
dp_copy_codebook_template(file_path)
```

Keep the first row unchanged, as it contains the required column names.
Then, fill in the codebook with the variable names, variable labels and
value labels for your data. Import the codebook into R and inspect it to
make sure it looks correct.

``` r

# Choose the codebook file you just edited
codebook_file_path <- ya_choose_file()

# Read in the codebook
myCodebook <- openxlsx::read.xlsx(codebook_file_path) |>
  tibble::as_tibble()

# Display the first few rows of the codebook
head(myCodebook, n = 3 * 7) |>
  print(n = Inf)
```

``` r

# Display the first few rows of the codebook
head(myCodebook, n = 3 * 7) |>
  print(n = Inf)
#> # A tibble: 21 × 4
#>    variable variable_label                                     value value_label
#>    <chr>    <chr>                                              <dbl> <chr>      
#>  1 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     1 1 - Überha…
#>  2 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     2 2          
#>  3 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     3 3          
#>  4 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     4 4          
#>  5 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     5 5          
#>  6 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     6 6          
#>  7 F600     Wie attraktiv finden Sie die BKW als Arbeitgeberi…     7 7 - Sehr a…
#>  8 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     1 Überhaupt …
#>  9 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     2 2          
#> 10 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     3 3          
#> 11 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     4 4          
#> 12 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     5 5          
#> 13 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     6 6          
#> 14 F800_1   Sicherheit und langfristige Stabilität des Arbeit…     7 Sehr gut  7
#> 15 F800_2   Karriere- und Entwicklungsmöglichkeiten                1 Überhaupt …
#> 16 F800_2   Karriere- und Entwicklungsmöglichkeiten                2 2          
#> 17 F800_2   Karriere- und Entwicklungsmöglichkeiten                3 3          
#> 18 F800_2   Karriere- und Entwicklungsmöglichkeiten                4 4          
#> 19 F800_2   Karriere- und Entwicklungsmöglichkeiten                5 5          
#> 20 F800_2   Karriere- und Entwicklungsmöglichkeiten                6 6          
#> 21 F800_2   Karriere- und Entwicklungsmöglichkeiten                7 Sehr gut  7
```

Once your codebook is ready, you can use the
[`dp_convert_to_labelled()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_convert_to_labelled.md)
function to convert your unlabelled data into a labelled format:

``` r

# Convert unlabelled data to labelled format using the codebook
myData_labelled <- dp_convert_to_labelled(
  data = myData_unlabelled,
  codebook = myCodebook
)

# Confirm that labelling worked (only show the first 3 variables for brevity)
dp_inspect_codebook(myData_unlabelled[, 1:3])
#> data (1104 rows and 3 variables, 3 shown)
#> 
#> ID | Name   | Label                     | Type    | Missings | Values |    N
#> ---+--------+---------------------------+---------+----------+--------+-----
#> 1  | F600   | Wie attraktiv             | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |        | finden Sie die            |         |          |        |     
#>    |        | BKW als                   |         |          |        |     
#>    |        | Arbeitgeberin?            |         |          |        |     
#> ---+--------+---------------------------+---------+----------+--------+-----
#> 2  | F800_1 | Sicherheit und            | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |        | langfristige              |         |          |        |     
#>    |        | Stabilität des            |         |          |        |     
#>    |        | Arbeitgebers              |         |          |        |     
#> ---+--------+---------------------------+---------+----------+--------+-----
#> 3  | F800_2 | Karriere- und             | numeric | 0 (0.0%) | [1, 7] | 1104
#>    |        | Entwicklungsmöglichkeiten |         |          |        |     
#> ----------------------------------------------------------------------------
dp_inspect_codebook(myData_labelled[, 1:3])
#> data (1104 rows and 3 variables, 3 shown)
#> 
#> ID | Name   | Label                     | Type    | Missings | Values
#> ---+--------+---------------------------+---------+----------+-------
#> 1  | F600   | Wie attraktiv             | numeric | 0 (0.0%) |      1
#>    |        | finden Sie die            |         |          |      2
#>    |        | BKW als                   |         |          |      3
#>    |        | Arbeitgeberin?            |         |          |      4
#>    |        |                           |         |          |      5
#>    |        |                           |         |          |      6
#>    |        |                           |         |          |      7
#> ---+--------+---------------------------+---------+----------+-------
#> 2  | F800_1 | Sicherheit und            | numeric | 0 (0.0%) |      1
#>    |        | langfristige              |         |          |      2
#>    |        | Stabilität des            |         |          |      3
#>    |        | Arbeitgebers              |         |          |      4
#>    |        |                           |         |          |      5
#>    |        |                           |         |          |      6
#>    |        |                           |         |          |      7
#> ---+--------+---------------------------+---------+----------+-------
#> 3  | F800_2 | Karriere- und             | numeric | 0 (0.0%) |      1
#>    |        | Entwicklungsmöglichkeiten |         |          |      2
#>    |        |                           |         |          |      3
#>    |        |                           |         |          |      4
#>    |        |                           |         |          |      5
#>    |        |                           |         |          |      6
#>    |        |                           |         |          |      7
#> ---------------------------------------------------------------------
#> 
#> ID | Value Labels       |           N
#> ---+--------------------+------------
#> 1  | 1 - Überhaupt...   |  42 ( 3.8%)
#>    | 2                  |  49 ( 4.4%)
#>    | 3                  | 127 (11.5%)
#>    | 4                  | 443 (40.1%)
#>    | 5                  | 282 (25.5%)
#>    | 6                  | 100 ( 9.1%)
#>    | 7 - Sehr...        |  61 ( 5.5%)
#> ---+--------------------+------------
#> 2  | Überhaupt nicht... |  11 ( 1.0%)
#>    | 2                  |  21 ( 1.9%)
#>    | 3                  |  65 ( 5.9%)
#>    | 4                  | 295 (26.7%)
#>    | 5                  | 256 (23.2%)
#>    | 6                  | 300 (27.2%)
#>    | Sehr gut  7        | 156 (14.1%)
#> ---+--------------------+------------
#> 3  | Überhaupt nicht... |  11 ( 1.0%)
#>    | 2                  |  33 ( 3.0%)
#>    | 3                  |  69 ( 6.2%)
#>    | 4                  | 405 (36.7%)
#>    | 5                  | 300 (27.2%)
#>    | 6                  | 209 (18.9%)
#>    | Sehr gut  7        |  77 ( 7.0%)
#> -------------------------------------
```

### Summary

If your data is unlabelled (`.csv`, `.xlsx`), use the following code
snippets to convert it to a labelled format:

``` r

# Read in your .xlsx data
file_path <- ya_choose_file()
myData_unlabelled <- openxlsx::read.xlsx(file_path) |>
  tibble::as_tibble()

# Create a codebook for your data using the provided template
file_path <- ya_choose_file_path("my_codebook.xlsx")
dp_copy_codebook_template(file_path)

#### EDIT THE CODEBOOK TEMPLATE IN EXCEL ####

# After having edited the codebook template in Excel, you can read it back into R
file_path <- ya_choose_file()
myCodebook <- openxlsx::read.xlsx(file_path) |>
  tibble::as_tibble()

# Use the unlabelled data and the codebook to convert the unlabelled data into a labelled format
myData_labelled <- dp_convert_to_labelled(
  data = myData_unlabelled,
  codebook = myCodebook
)

# Confirm that the data is now labelled
dp_inspect_codebook(myData_labelled)

# Save the labelled data as a .sav file to preserve the variable and value labels for future use
file_path <- ya_choose_file_path("my_labelled_data.sav")
haven::write_sav(myData_labelled, file_path)
```

### Automatically Label Data

If you are missing variable and value labels for your data and do not
want to provide a codebook (lazy you! ;) ), you can use the
[`dp_label_automatically()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_label_automatically.md)
function to automatically label your data based on its values. This
function is useful for filling in missing labels, but it should be used
with caution: It assumes that the observed minimum and maximum values in
your data represent the theoretical minimum and maximum values of the
variables, which is not always the case. Therefore, it is recommended to
provide a codebook with
[`dp_convert_to_labelled()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_convert_to_labelled.md)
if possible. If you do use
[`dp_label_automatically()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_label_automatically.md),
make sure to inspect the results carefully using
[`dp_inspect_codebook()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_inspect_codebook.md)
to check whether the labelling worked as expected.

``` r

# Create an example data frame with some missing variable labels and value labels
bkw_processed_missing_labels <- bkw_processed |>
  dplyr::mutate(dplyr::across(paste0("F800_", 1:5), \(x) {
    haven::zap_label(x)
  })) |>
  dplyr::mutate(dplyr::across(paste0("F800_", 4:5), \(x) {
    haven::zap_labels(x)
  }))

# Demonstrate: There are missing labels in the data
dp_inspect_codebook(bkw_processed_missing_labels)
#> data (1104 rows and 15 variables, 15 shown)
#> 
#> ID | Name    | Label                    | Type    | Missings | Values
#> ---+---------+--------------------------+---------+----------+-------
#> 1  | F600    | Wie attraktiv            | numeric | 0 (0.0%) |      1
#>    |         | finden Sie die           |         |          |      2
#>    |         | BKW als                  |         |          |      3
#>    |         | Arbeitgeberin?           |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 2  | F800_1  |                          | numeric | 0 (0.0%) |      1
#>    |         |                          |         |          |      2
#>    |         |                          |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 3  | F800_2  |                          | numeric | 0 (0.0%) |      1
#>    |         |                          |         |          |      2
#>    |         |                          |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 4  | F800_3  |                          | numeric | 0 (0.0%) |      1
#>    |         |                          |         |          |      2
#>    |         |                          |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 5  | F800_4  |                          | numeric | 0 (0.0%) | [1, 7]
#> ---+---------+--------------------------+---------+----------+-------
#> 6  | F800_5  |                          | numeric | 0 (0.0%) | [1, 7]
#> ---+---------+--------------------------+---------+----------+-------
#> 7  | F800_6  | Moderne                  | numeric | 0 (0.0%) |      1
#>    |         | Arbeitsumgebung          |         |          |      2
#>    |         | und                      |         |          |      3
#>    |         | Technologien             |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 8  | F800_7  | Attraktive               | numeric | 0 (0.0%) |      1
#>    |         | Vergütung und            |         |          |      2
#>    |         | Zusatzleistungen         |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 9  | F800_8  | Gute Führung             | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | wertschätzende           |         |          |      3
#>    |         | Unternehmenskultur       |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 10 | F800_9  | Verantwortung            | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | Gestaltungsspielraum     |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 11 | F800_10 | Zukunftsorientierung     | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | Nachhaltigkeit           |         |          |      3
#>    |         | des                      |         |          |      4
#>    |         | Unternehmens             |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 12 | F800_11 | Internationales          | numeric | 0 (0.0%) |      1
#>    |         | Arbeitsumfeld            |         |          |      2
#>    |         | und kulturelle           |         |          |      3
#>    |         | Vielfalt                 |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 13 | F800_12 | Innovationskultur        | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | Veränderungsbereitschaft |         |          |      3
#>    |         | des                      |         |          |      4
#>    |         | Unternehmens             |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 14 | F800_13 | Arbeitszeit-             | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | Arbeitsortflexibilität   |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 15 | F800_14 | Diversität,              | numeric | 0 (0.0%) |      1
#>    |         | Gleichstellung           |         |          |      2
#>    |         | und Inklusion            |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---------------------------------------------------------------------
#> 
#> ID | Value Labels       |           N
#> ---+--------------------+------------
#> 1  | 1 - Überhaupt...   |  42 ( 3.8%)
#>    | 2                  |  49 ( 4.4%)
#>    | 3                  | 127 (11.5%)
#>    | 4                  | 443 (40.1%)
#>    | 5                  | 282 (25.5%)
#>    | 6                  | 100 ( 9.1%)
#>    | 7 - Sehr...        |  61 ( 5.5%)
#> ---+--------------------+------------
#> 2  | Überhaupt nicht... |  11 ( 1.0%)
#>    | 2                  |  21 ( 1.9%)
#>    | 3                  |  65 ( 5.9%)
#>    | 4                  | 295 (26.7%)
#>    | 5                  | 256 (23.2%)
#>    | 6                  | 300 (27.2%)
#>    | Sehr gut  7        | 156 (14.1%)
#> ---+--------------------+------------
#> 3  | Überhaupt nicht... |  11 ( 1.0%)
#>    | 2                  |  33 ( 3.0%)
#>    | 3                  |  69 ( 6.2%)
#>    | 4                  | 405 (36.7%)
#>    | 5                  | 300 (27.2%)
#>    | 6                  | 209 (18.9%)
#>    | Sehr gut  7        |  77 ( 7.0%)
#> ---+--------------------+------------
#> 4  | Überhaupt nicht... |  12 ( 1.1%)
#>    | 2                  |  27 ( 2.4%)
#>    | 3                  |  87 ( 7.9%)
#>    | 4                  | 348 (31.5%)
#>    | 5                  | 289 (26.2%)
#>    | 6                  | 238 (21.6%)
#>    | Sehr gut  7        | 103 ( 9.3%)
#> ---+--------------------+------------
#> 5  |                    |        1104
#> ---+--------------------+------------
#> 6  |                    |        1104
#> ---+--------------------+------------
#> 7  | Überhaupt nicht... |  14 ( 1.3%)
#>    | 2                  |  26 ( 2.4%)
#>    | 3                  |  66 ( 6.0%)
#>    | 4                  | 315 (28.5%)
#>    | 5                  | 311 (28.2%)
#>    | 6                  | 254 (23.0%)
#>    | Sehr gut  7        | 118 (10.7%)
#> ---+--------------------+------------
#> 8  | Überhaupt nicht... |  12 ( 1.1%)
#>    | 2                  |  17 ( 1.5%)
#>    | 3                  |  81 ( 7.3%)
#>    | 4                  | 430 (38.9%)
#>    | 5                  | 260 (23.6%)
#>    | 6                  | 211 (19.1%)
#>    | Sehr gut  7        |  93 ( 8.4%)
#> ---+--------------------+------------
#> 9  | Überhaupt nicht... |  16 ( 1.4%)
#>    | 2                  |  30 ( 2.7%)
#>    | 3                  |  97 ( 8.8%)
#>    | 4                  | 454 (41.1%)
#>    | 5                  | 276 (25.0%)
#>    | 6                  | 163 (14.8%)
#>    | Sehr gut  7        |  68 ( 6.2%)
#> ---+--------------------+------------
#> 10 | Überhaupt nicht... |  21 ( 1.9%)
#>    | 2                  |  19 ( 1.7%)
#>    | 3                  | 116 (10.5%)
#>    | 4                  | 443 (40.1%)
#>    | 5                  | 277 (25.1%)
#>    | 6                  | 160 (14.5%)
#>    | Sehr gut  7        |  68 ( 6.2%)
#> ---+--------------------+------------
#> 11 | Überhaupt nicht... |  22 ( 2.0%)
#>    | 2                  |  20 ( 1.8%)
#>    | 3                  |  65 ( 5.9%)
#>    | 4                  | 314 (28.4%)
#>    | 5                  | 305 (27.6%)
#>    | 6                  | 277 (25.1%)
#>    | Sehr gut  7        | 101 ( 9.1%)
#> ---+--------------------+------------
#> 12 | Überhaupt nicht... |  26 ( 2.4%)
#>    | 2                  |  68 ( 6.2%)
#>    | 3                  | 150 (13.6%)
#>    | 4                  | 378 (34.2%)
#>    | 5                  | 239 (21.6%)
#>    | 6                  | 166 (15.0%)
#>    | Sehr gut  7        |  77 ( 7.0%)
#> ---+--------------------+------------
#> 13 | Überhaupt nicht... |  18 ( 1.6%)
#>    | 2                  |  27 ( 2.4%)
#>    | 3                  | 114 (10.3%)
#>    | 4                  | 396 (35.9%)
#>    | 5                  | 299 (27.1%)
#>    | 6                  | 178 (16.1%)
#>    | Sehr gut  7        |  72 ( 6.5%)
#> ---+--------------------+------------
#> 14 | Überhaupt nicht... |  12 ( 1.1%)
#>    | 2                  |  31 ( 2.8%)
#>    | 3                  | 108 ( 9.8%)
#>    | 4                  | 403 (36.5%)
#>    | 5                  | 302 (27.4%)
#>    | 6                  | 171 (15.5%)
#>    | Sehr gut  7        |  77 ( 7.0%)
#> ---+--------------------+------------
#> 15 | Überhaupt nicht... |  32 ( 2.9%)
#>    | 2                  |  47 ( 4.3%)
#>    | 3                  |  90 ( 8.2%)
#>    | 4                  | 445 (40.3%)
#>    | 5                  | 294 (26.6%)
#>    | 6                  | 146 (13.2%)
#>    | Sehr gut  7        |  50 ( 4.5%)
#> -------------------------------------

# Fill in missing labels using the function
out <- dp_label_automatically(bkw_processed_missing_labels)
#> Warning: Missing variable label detected.
#> ! Replaced with variable name for: "F800_1", "F800_2", "F800_3", "F800_4", and
#>   "F800_5".
#> Warning: Missing value labels detected.
#> ! Replaced with observed min/max values for: "F800_4" and "F800_5".

# Check the results
dp_inspect_codebook(out)
#> data (1104 rows and 15 variables, 15 shown)
#> 
#> ID | Name    | Label                    | Type    | Missings | Values
#> ---+---------+--------------------------+---------+----------+-------
#> 1  | F600    | Wie attraktiv            | numeric | 0 (0.0%) |      1
#>    |         | finden Sie die           |         |          |      2
#>    |         | BKW als                  |         |          |      3
#>    |         | Arbeitgeberin?           |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 2  | F800_1  | F800_1                   | numeric | 0 (0.0%) |      1
#>    |         |                          |         |          |      2
#>    |         |                          |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 3  | F800_2  | F800_2                   | numeric | 0 (0.0%) |      1
#>    |         |                          |         |          |      2
#>    |         |                          |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 4  | F800_3  | F800_3                   | numeric | 0 (0.0%) |      1
#>    |         |                          |         |          |      2
#>    |         |                          |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 5  | F800_4  | F800_4                   | numeric | 0 (0.0%) |      1
#>    |         |                          |         |          |      2
#>    |         |                          |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 6  | F800_5  | F800_5                   | numeric | 0 (0.0%) |      1
#>    |         |                          |         |          |      2
#>    |         |                          |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 7  | F800_6  | Moderne                  | numeric | 0 (0.0%) |      1
#>    |         | Arbeitsumgebung          |         |          |      2
#>    |         | und                      |         |          |      3
#>    |         | Technologien             |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 8  | F800_7  | Attraktive               | numeric | 0 (0.0%) |      1
#>    |         | Vergütung und            |         |          |      2
#>    |         | Zusatzleistungen         |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 9  | F800_8  | Gute Führung             | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | wertschätzende           |         |          |      3
#>    |         | Unternehmenskultur       |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 10 | F800_9  | Verantwortung            | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | Gestaltungsspielraum     |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 11 | F800_10 | Zukunftsorientierung     | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | Nachhaltigkeit           |         |          |      3
#>    |         | des                      |         |          |      4
#>    |         | Unternehmens             |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 12 | F800_11 | Internationales          | numeric | 0 (0.0%) |      1
#>    |         | Arbeitsumfeld            |         |          |      2
#>    |         | und kulturelle           |         |          |      3
#>    |         | Vielfalt                 |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 13 | F800_12 | Innovationskultur        | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | Veränderungsbereitschaft |         |          |      3
#>    |         | des                      |         |          |      4
#>    |         | Unternehmens             |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 14 | F800_13 | Arbeitszeit-             | numeric | 0 (0.0%) |      1
#>    |         | und                      |         |          |      2
#>    |         | Arbeitsortflexibilität   |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---+---------+--------------------------+---------+----------+-------
#> 15 | F800_14 | Diversität,              | numeric | 0 (0.0%) |      1
#>    |         | Gleichstellung           |         |          |      2
#>    |         | und Inklusion            |         |          |      3
#>    |         |                          |         |          |      4
#>    |         |                          |         |          |      5
#>    |         |                          |         |          |      6
#>    |         |                          |         |          |      7
#> ---------------------------------------------------------------------
#> 
#> ID | Value Labels       |           N
#> ---+--------------------+------------
#> 1  | 1 - Überhaupt...   |  42 ( 3.8%)
#>    | 2                  |  49 ( 4.4%)
#>    | 3                  | 127 (11.5%)
#>    | 4                  | 443 (40.1%)
#>    | 5                  | 282 (25.5%)
#>    | 6                  | 100 ( 9.1%)
#>    | 7 - Sehr...        |  61 ( 5.5%)
#> ---+--------------------+------------
#> 2  | Überhaupt nicht... |  11 ( 1.0%)
#>    | 2                  |  21 ( 1.9%)
#>    | 3                  |  65 ( 5.9%)
#>    | 4                  | 295 (26.7%)
#>    | 5                  | 256 (23.2%)
#>    | 6                  | 300 (27.2%)
#>    | Sehr gut  7        | 156 (14.1%)
#> ---+--------------------+------------
#> 3  | Überhaupt nicht... |  11 ( 1.0%)
#>    | 2                  |  33 ( 3.0%)
#>    | 3                  |  69 ( 6.2%)
#>    | 4                  | 405 (36.7%)
#>    | 5                  | 300 (27.2%)
#>    | 6                  | 209 (18.9%)
#>    | Sehr gut  7        |  77 ( 7.0%)
#> ---+--------------------+------------
#> 4  | Überhaupt nicht... |  12 ( 1.1%)
#>    | 2                  |  27 ( 2.4%)
#>    | 3                  |  87 ( 7.9%)
#>    | 4                  | 348 (31.5%)
#>    | 5                  | 289 (26.2%)
#>    | 6                  | 238 (21.6%)
#>    | Sehr gut  7        | 103 ( 9.3%)
#> ---+--------------------+------------
#> 5  | 1                  |  13 ( 1.2%)
#>    | 2                  |  20 ( 1.8%)
#>    | 3                  |  81 ( 7.3%)
#>    | 4                  | 447 (40.5%)
#>    | 5                  | 300 (27.2%)
#>    | 6                  | 182 (16.5%)
#>    | 7                  |  61 ( 5.5%)
#> ---+--------------------+------------
#> 6  | 1                  |  14 ( 1.3%)
#>    | 2                  |  27 ( 2.4%)
#>    | 3                  | 102 ( 9.2%)
#>    | 4                  | 435 (39.4%)
#>    | 5                  | 286 (25.9%)
#>    | 6                  | 157 (14.2%)
#>    | 7                  |  83 ( 7.5%)
#> ---+--------------------+------------
#> 7  | Überhaupt nicht... |  14 ( 1.3%)
#>    | 2                  |  26 ( 2.4%)
#>    | 3                  |  66 ( 6.0%)
#>    | 4                  | 315 (28.5%)
#>    | 5                  | 311 (28.2%)
#>    | 6                  | 254 (23.0%)
#>    | Sehr gut  7        | 118 (10.7%)
#> ---+--------------------+------------
#> 8  | Überhaupt nicht... |  12 ( 1.1%)
#>    | 2                  |  17 ( 1.5%)
#>    | 3                  |  81 ( 7.3%)
#>    | 4                  | 430 (38.9%)
#>    | 5                  | 260 (23.6%)
#>    | 6                  | 211 (19.1%)
#>    | Sehr gut  7        |  93 ( 8.4%)
#> ---+--------------------+------------
#> 9  | Überhaupt nicht... |  16 ( 1.4%)
#>    | 2                  |  30 ( 2.7%)
#>    | 3                  |  97 ( 8.8%)
#>    | 4                  | 454 (41.1%)
#>    | 5                  | 276 (25.0%)
#>    | 6                  | 163 (14.8%)
#>    | Sehr gut  7        |  68 ( 6.2%)
#> ---+--------------------+------------
#> 10 | Überhaupt nicht... |  21 ( 1.9%)
#>    | 2                  |  19 ( 1.7%)
#>    | 3                  | 116 (10.5%)
#>    | 4                  | 443 (40.1%)
#>    | 5                  | 277 (25.1%)
#>    | 6                  | 160 (14.5%)
#>    | Sehr gut  7        |  68 ( 6.2%)
#> ---+--------------------+------------
#> 11 | Überhaupt nicht... |  22 ( 2.0%)
#>    | 2                  |  20 ( 1.8%)
#>    | 3                  |  65 ( 5.9%)
#>    | 4                  | 314 (28.4%)
#>    | 5                  | 305 (27.6%)
#>    | 6                  | 277 (25.1%)
#>    | Sehr gut  7        | 101 ( 9.1%)
#> ---+--------------------+------------
#> 12 | Überhaupt nicht... |  26 ( 2.4%)
#>    | 2                  |  68 ( 6.2%)
#>    | 3                  | 150 (13.6%)
#>    | 4                  | 378 (34.2%)
#>    | 5                  | 239 (21.6%)
#>    | 6                  | 166 (15.0%)
#>    | Sehr gut  7        |  77 ( 7.0%)
#> ---+--------------------+------------
#> 13 | Überhaupt nicht... |  18 ( 1.6%)
#>    | 2                  |  27 ( 2.4%)
#>    | 3                  | 114 (10.3%)
#>    | 4                  | 396 (35.9%)
#>    | 5                  | 299 (27.1%)
#>    | 6                  | 178 (16.1%)
#>    | Sehr gut  7        |  72 ( 6.5%)
#> ---+--------------------+------------
#> 14 | Überhaupt nicht... |  12 ( 1.1%)
#>    | 2                  |  31 ( 2.8%)
#>    | 3                  | 108 ( 9.8%)
#>    | 4                  | 403 (36.5%)
#>    | 5                  | 302 (27.4%)
#>    | 6                  | 171 (15.5%)
#>    | Sehr gut  7        |  77 ( 7.0%)
#> ---+--------------------+------------
#> 15 | Überhaupt nicht... |  32 ( 2.9%)
#>    | 2                  |  47 ( 4.3%)
#>    | 3                  |  90 ( 8.2%)
#>    | 4                  | 445 (40.3%)
#>    | 5                  | 294 (26.6%)
#>    | 6                  | 146 (13.2%)
#>    | Sehr gut  7        |  50 ( 4.5%)
#> -------------------------------------
```

You can do better by providing theoretical minimum and maximum values
for the variables:

``` r

# Create a theoretical min/max data frame
theoretical_min_max <- data.frame(
  variable = paste0("F800_", 1:5),
  min = c(1, 1, 1, 1, 1),
  max = c(5, 5, 5, 5, 5)
)

# Fill in missing labels using the function with theoretical min/max values
out_with_theoretical <- dp_label_automatically(
  bkw_processed_missing_labels,
  theoretical_min_max
)
#> Warning: Missing variable label detected.
#> ! Replaced with variable name for: "F800_1", "F800_2", "F800_3", "F800_4", and
#>   "F800_5".
#> Warning: Missing value labels detected.
#> ! Replaced with user-supplied min/max values for: "F800_4" and "F800_5".
```
