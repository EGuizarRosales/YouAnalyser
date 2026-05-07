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
