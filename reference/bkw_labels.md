# BKW Employer Brand Positioning Study Data (Variable and Value Labels)

Data based on
[bkw_processed](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_processed.md)
with variable and value labels. The data only contains variable labels
and value labels, providing a codebook additionally needed if unlabelled
data is read in, e.g. using .xlsx or .csv files..

## Usage

``` r
bkw_labels
```

## Format

### `bkw_labels`

A data frame with 1,171 rows and 15 columns:

- F600:

  Dependent variable: Wie attraktiv finden Sie die BKW als
  Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)

- F800_1, ..., F800_14:

  Independent variables. Main question: Wie gut passt die BKW Ihrer
  Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem
  Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut);
  F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ...
  , F800_14: "Diversität, Gleichstellung und Inklusion")
