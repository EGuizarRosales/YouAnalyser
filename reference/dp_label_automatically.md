# Automatically label a data frame

This function checks for missing variable labels and value labels in a
data frame and automatically fills them in. For missing variable labels,
it uses the variable name as a fallback. For missing value labels, it
uses the observed minimum and maximum values in the data, or theoretical
minimum and maximum values if provided by the user.

## Usage

``` r
dp_label_automatically(data, theoretical_min_max_values = NULL)
```

## Arguments

- data:

  A data frame to be checked and labelled. This can be a labelled data
  frame or an unlabelled data frame.

- theoretical_min_max_values:

  An optional data frame with columns "variable", "min", and "max" that
  provides theoretical minimum and maximum values for variables. If
  provided, these values will be used to fill in missing value labels
  instead of using observed min/max values from the data.

## Value

A labelled data frame with missing variable labels and value labels
filled in.

## Examples

``` r
# Create an example data frame with some missing variable labels and value labels
bkw_processed_missing_labels <- bkw_processed |>
  dplyr::mutate(dplyr::across(paste0("F800_", 1:5), \(x) {
    haven::zap_label(x)
  })) |>
 dplyr::mutate(dplyr::across(paste0("F800_", 4:5), \(x) {
   haven::zap_labels(x)
 }))
# Fill in missing labels using the function
out <- dp_label_automatically(bkw_processed_missing_labels)
#> Warning: Missing variable label detected.
#> ! Replaced with variable name for: "F800_1", "F800_2", "F800_3", "F800_4", and
#>   "F800_5".
#> Warning: Missing value labels detected.
#> ! Replaced with observed min/max values for: "F800_4" and "F800_5".
# Check the results
dp_inspect_codebook(out)
#> data (1171 rows and 15 variables, 15 shown)
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
#> 1  | 1 - Überhaupt...   |  43 ( 3.7%)
#>    | 2                  |  50 ( 4.3%)
#>    | 3                  | 130 (11.1%)
#>    | 4                  | 461 (39.4%)
#>    | 5                  | 303 (25.9%)
#>    | 6                  | 109 ( 9.3%)
#>    | 7 - Sehr...        |  75 ( 6.4%)
#> ---+--------------------+------------
#> 2  | Überhaupt nicht... |  11 ( 0.9%)
#>    | 2                  |  19 ( 1.6%)
#>    | 3                  |  66 ( 5.6%)
#>    | 4                  | 301 (25.7%)
#>    | 5                  | 270 (23.1%)
#>    | 6                  | 322 (27.5%)
#>    | Sehr gut  7        | 182 (15.5%)
#> ---+--------------------+------------
#> 3  | Überhaupt nicht... |  11 ( 0.9%)
#>    | 2                  |  34 ( 2.9%)
#>    | 3                  |  70 ( 6.0%)
#>    | 4                  | 417 (35.6%)
#>    | 5                  | 316 (27.0%)
#>    | 6                  | 234 (20.0%)
#>    | Sehr gut  7        |  89 ( 7.6%)
#> ---+--------------------+------------
#> 4  | Überhaupt nicht... |  12 ( 1.0%)
#>    | 2                  |  27 ( 2.3%)
#>    | 3                  |  89 ( 7.6%)
#>    | 4                  | 357 (30.5%)
#>    | 5                  | 305 (26.0%)
#>    | 6                  | 259 (22.1%)
#>    | Sehr gut  7        | 122 (10.4%)
#> ---+--------------------+------------
#> 5  | 1                  |  13 ( 1.1%)
#>    | 2                  |  20 ( 1.7%)
#>    | 3                  |  81 ( 6.9%)
#>    | 4                  | 463 (39.5%)
#>    | 5                  | 328 (28.0%)
#>    | 6                  | 190 (16.2%)
#>    | 7                  |  76 ( 6.5%)
#> ---+--------------------+------------
#> 6  | 1                  |  14 ( 1.2%)
#>    | 2                  |  27 ( 2.3%)
#>    | 3                  | 103 ( 8.8%)
#>    | 4                  | 446 (38.1%)
#>    | 5                  | 308 (26.3%)
#>    | 6                  | 177 (15.1%)
#>    | 7                  |  96 ( 8.2%)
#> ---+--------------------+------------
#> 7  | Überhaupt nicht... |  14 ( 1.2%)
#>    | 2                  |  25 ( 2.1%)
#>    | 3                  |  67 ( 5.7%)
#>    | 4                  | 324 (27.7%)
#>    | 5                  | 328 (28.0%)
#>    | 6                  | 273 (23.3%)
#>    | Sehr gut  7        | 140 (12.0%)
#> ---+--------------------+------------
#> 8  | Überhaupt nicht... |  13 ( 1.1%)
#>    | 2                  |  18 ( 1.5%)
#>    | 3                  |  82 ( 7.0%)
#>    | 4                  | 442 (37.7%)
#>    | 5                  | 281 (24.0%)
#>    | 6                  | 225 (19.2%)
#>    | Sehr gut  7        | 110 ( 9.4%)
#> ---+--------------------+------------
#> 9  | Überhaupt nicht... |  16 ( 1.4%)
#>    | 2                  |  31 ( 2.6%)
#>    | 3                  |  97 ( 8.3%)
#>    | 4                  | 466 (39.8%)
#>    | 5                  | 307 (26.2%)
#>    | 6                  | 173 (14.8%)
#>    | Sehr gut  7        |  81 ( 6.9%)
#> ---+--------------------+------------
#> 10 | Überhaupt nicht... |  22 ( 1.9%)
#>    | 2                  |  18 ( 1.5%)
#>    | 3                  | 117 (10.0%)
#>    | 4                  | 457 (39.0%)
#>    | 5                  | 295 (25.2%)
#>    | 6                  | 177 (15.1%)
#>    | Sehr gut  7        |  85 ( 7.3%)
#> ---+--------------------+------------
#> 11 | Überhaupt nicht... |  22 ( 1.9%)
#>    | 2                  |  20 ( 1.7%)
#>    | 3                  |  65 ( 5.6%)
#>    | 4                  | 322 (27.5%)
#>    | 5                  | 322 (27.5%)
#>    | 6                  | 310 (26.5%)
#>    | Sehr gut  7        | 110 ( 9.4%)
#> ---+--------------------+------------
#> 12 | Überhaupt nicht... |  27 ( 2.3%)
#>    | 2                  |  74 ( 6.3%)
#>    | 3                  | 155 (13.2%)
#>    | 4                  | 380 (32.5%)
#>    | 5                  | 258 (22.0%)
#>    | 6                  | 185 (15.8%)
#>    | Sehr gut  7        |  92 ( 7.9%)
#> ---+--------------------+------------
#> 13 | Überhaupt nicht... |  17 ( 1.5%)
#>    | 2                  |  27 ( 2.3%)
#>    | 3                  | 110 ( 9.4%)
#>    | 4                  | 408 (34.8%)
#>    | 5                  | 323 (27.6%)
#>    | 6                  | 203 (17.3%)
#>    | Sehr gut  7        |  83 ( 7.1%)
#> ---+--------------------+------------
#> 14 | Überhaupt nicht... |  12 ( 1.0%)
#>    | 2                  |  31 ( 2.6%)
#>    | 3                  | 113 ( 9.6%)
#>    | 4                  | 422 (36.0%)
#>    | 5                  | 317 (27.1%)
#>    | 6                  | 189 (16.1%)
#>    | Sehr gut  7        |  87 ( 7.4%)
#> ---+--------------------+------------
#> 15 | Überhaupt nicht... |  34 ( 2.9%)
#>    | 2                  |  47 ( 4.0%)
#>    | 3                  |  93 ( 7.9%)
#>    | 4                  | 461 (39.4%)
#>    | 5                  | 313 (26.7%)
#>    | 6                  | 163 (13.9%)
#>    | Sehr gut  7        |  60 ( 5.1%)
#> -------------------------------------

#' # Create a theoretical min/max data frame
theoretical_min_max <- data.frame(
  variable = paste0("F800_", 1:5),
 min = c(1, 1, 1, 1, 1),
 max = c(7, 7, 7, 7, 7)
)
# Fill in missing labels using the function with theoretical min/max values
out_with_theoretical <- dp_label_automatically(bkw_processed_missing_labels, theoretical_min_max)
#> Warning: Missing variable label detected.
#> ! Replaced with variable name for: "F800_1", "F800_2", "F800_3", "F800_4", and
#>   "F800_5".
#> Warning: Missing value labels detected.
#> ! Replaced with user-supplied min/max values for: "F800_4" and "F800_5".
```
