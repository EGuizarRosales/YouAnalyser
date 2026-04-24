# Data Processing

``` r
library(YouAnalyser)
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
#> tibble [1,216 × 2] (S3: tbl_df/tbl/data.frame)
#>  $ F600  : dbl+lbl [1:1216] 4, 2, 2, 4, 4, 5, 4, 3, 6, 2, 6, 5, 4, 6, 4, 4, 3, 3,...
#>    ..@ label      : chr "Wie attraktiv finden Sie die BKW als Arbeitgeberin?"
#>    ..@ format.spss: chr "F1.0"
#>    ..@ labels     : Named num [1:7] 1 2 3 4 5 6 7
#>    .. ..- attr(*, "names")= chr [1:7] "1 - Überhaupt nicht attraktiv" "2" "3" "4" ...
#>  $ F800_1: dbl+lbl [1:1216] 4, 3, 4, 6, 7, 4, 7, 4, 7, 4, 6, 6, 5, 6, 5, 5, 4, 5,...
#>    ..@ label      : chr "Sicherheit und langfristige Stabilität des Arbeitgebers"
#>    ..@ format.spss: chr "F1.0"
#>    ..@ labels     : Named num [1:7] 1 2 3 4 5 6 7
#>    .. ..- attr(*, "names")= chr [1:7] "Überhaupt nicht gut  1" "2" "3" "4" ...
#>  - attr(*, "label")= chr "File created by user 'ana-maria.nedelcu' at Wed Feb 11 11:11"
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
#> data (1216 rows and 2 variables, 2 shown)
#> 
#> ID | Name   | Label          | Type    | Missings | Values | Value Labels       |           N
#> ---+--------+----------------+---------+----------+--------+--------------------+------------
#> 1  | F600   | Wie attraktiv  | numeric | 0 (0.0%) |      1 | 1 - Überhaupt...   |  54 ( 4.4%)
#>    |        | finden Sie die |         |          |      2 | 2                  |  59 ( 4.9%)
#>    |        | BKW als        |         |          |      3 | 3                  | 116 ( 9.5%)
#>    |        | Arbeitgeberin? |         |          |      4 | 4                  | 470 (38.7%)
#>    |        |                |         |          |      5 | 5                  | 305 (25.1%)
#>    |        |                |         |          |      6 | 6                  | 132 (10.9%)
#>    |        |                |         |          |      7 | 7 - Sehr...        |  80 ( 6.6%)
#> ---+--------+----------------+---------+----------+--------+--------------------+------------
#> 2  | F800_1 | Sicherheit und | numeric | 0 (0.0%) |      1 | Überhaupt nicht... |  18 ( 1.5%)
#>    |        | langfristige   |         |          |      2 | 2                  |  19 ( 1.6%)
#>    |        | Stabilität des |         |          |      3 | 3                  |  61 ( 5.0%)
#>    |        | Arbeitgebers   |         |          |      4 | 4                  | 310 (25.5%)
#>    |        |                |         |          |      5 | 5                  | 274 (22.5%)
#>    |        |                |         |          |      6 | 6                  | 334 (27.5%)
#>    |        |                |         |          |      7 | Sehr gut  7        | 200 (16.4%)
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
#> tibble [1,216 × 2] (S3: tbl_df/tbl/data.frame)
#>  $ F600  : num [1:1216] 4 2 2 4 4 5 4 3 6 2 ...
#>   ..- attr(*, "label")= chr "Wie attraktiv finden Sie die BKW als Arbeitgeberin?"
#>   ..- attr(*, "format.spss")= chr "F1.0"
#>  $ F800_1: num [1:1216] 4 3 4 6 7 4 7 4 7 4 ...
#>   ..- attr(*, "label")= chr "Sicherheit und langfristige Stabilität des Arbeitgebers"
#>   ..- attr(*, "format.spss")= chr "F1.0"
#>  - attr(*, "label")= chr "File created by user 'ana-maria.nedelcu' at Wed Feb 11 11:11"

# `dp_inspect_codebook()` also confirms that there are no variable labels or
#  value labels in the unlabelled data.
dp_inspect_codebook(myData_unlabelled)
#> data (1216 rows and 15 variables, 15 shown)
#> 
#> ID | Name    | Label                     | Type    | Missings | Values |    N
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 1  | F600    | Wie attraktiv             | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | finden Sie die            |         |          |        |     
#>    |         | BKW als                   |         |          |        |     
#>    |         | Arbeitgeberin?            |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 2  | F800_1  | Sicherheit und            | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | langfristige              |         |          |        |     
#>    |         | Stabilität des            |         |          |        |     
#>    |         | Arbeitgebers              |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 3  | F800_2  | Karriere- und             | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | Entwicklungsmöglichkeiten |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 4  | F800_3  | Sinnvolle                 | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | Tätigkeit und             |         |          |        |     
#>    |         | gesellschaftlicher        |         |          |        |     
#>    |         | Beitrag                   |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 5  | F800_4  | Gute                      | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | Zusammenarbeit            |         |          |        |     
#>    |         | und Teamkultur            |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 6  | F800_5  | Vereinbarkeit             | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | von Beruf und             |         |          |        |     
#>    |         | Privatleben               |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 7  | F800_6  | Moderne                   | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | Arbeitsumgebung           |         |          |        |     
#>    |         | und                       |         |          |        |     
#>    |         | Technologien              |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 8  | F800_7  | Attraktive                | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | Vergütung und             |         |          |        |     
#>    |         | Zusatzleistungen          |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 9  | F800_8  | Gute Führung              | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | und                       |         |          |        |     
#>    |         | wertschätzende            |         |          |        |     
#>    |         | Unternehmenskultur        |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 10 | F800_9  | Verantwortung             | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | und                       |         |          |        |     
#>    |         | Gestaltungsspielraum      |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 11 | F800_10 | Zukunftsorientierung      | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | und                       |         |          |        |     
#>    |         | Nachhaltigkeit            |         |          |        |     
#>    |         | des                       |         |          |        |     
#>    |         | Unternehmens              |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 12 | F800_11 | Internationales           | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | Arbeitsumfeld             |         |          |        |     
#>    |         | und kulturelle            |         |          |        |     
#>    |         | Vielfalt                  |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 13 | F800_12 | Innovationskultur         | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | und                       |         |          |        |     
#>    |         | Veränderungsbereitschaft  |         |          |        |     
#>    |         | des                       |         |          |        |     
#>    |         | Unternehmens              |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 14 | F800_13 | Arbeitszeit-              | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |         | und                       |         |          |        |     
#>    |         | Arbeitsortflexibilität    |         |          |        |     
#> ---+---------+---------------------------+---------+----------+--------+-----
#> 15 | F800_14 | Diversität,               | numeric | 0 (0.0%) | [1, 7] | 1216
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
#> data (1216 rows and 3 variables, 3 shown)
#> 
#> ID | Name   | Label                     | Type    | Missings | Values |    N
#> ---+--------+---------------------------+---------+----------+--------+-----
#> 1  | F600   | Wie attraktiv             | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |        | finden Sie die            |         |          |        |     
#>    |        | BKW als                   |         |          |        |     
#>    |        | Arbeitgeberin?            |         |          |        |     
#> ---+--------+---------------------------+---------+----------+--------+-----
#> 2  | F800_1 | Sicherheit und            | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |        | langfristige              |         |          |        |     
#>    |        | Stabilität des            |         |          |        |     
#>    |        | Arbeitgebers              |         |          |        |     
#> ---+--------+---------------------------+---------+----------+--------+-----
#> 3  | F800_2 | Karriere- und             | numeric | 0 (0.0%) | [1, 7] | 1216
#>    |        | Entwicklungsmöglichkeiten |         |          |        |     
#> ----------------------------------------------------------------------------
dp_inspect_codebook(myData_labelled[, 1:3])
#> data (1216 rows and 3 variables, 3 shown)
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
#> 1  | 1 - Überhaupt...   |  54 ( 4.4%)
#>    | 2                  |  59 ( 4.9%)
#>    | 3                  | 116 ( 9.5%)
#>    | 4                  | 470 (38.7%)
#>    | 5                  | 305 (25.1%)
#>    | 6                  | 132 (10.9%)
#>    | 7 - Sehr...        |  80 ( 6.6%)
#> ---+--------------------+------------
#> 2  | Überhaupt nicht... |  18 ( 1.5%)
#>    | 2                  |  19 ( 1.6%)
#>    | 3                  |  61 ( 5.0%)
#>    | 4                  | 310 (25.5%)
#>    | 5                  | 274 (22.5%)
#>    | 6                  | 334 (27.5%)
#>    | Sehr gut  7        | 200 (16.4%)
#> ---+--------------------+------------
#> 3  | Überhaupt nicht... |  19 ( 1.6%)
#>    | 2                  |  24 ( 2.0%)
#>    | 3                  |  73 ( 6.0%)
#>    | 4                  | 415 (34.1%)
#>    | 5                  | 339 (27.9%)
#>    | 6                  | 240 (19.7%)
#>    | Sehr gut  7        | 106 ( 8.7%)
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
