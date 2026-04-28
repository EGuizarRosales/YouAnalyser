# BKW Employer Brand Positioning Study Data (Unlabelled Data)

Data based on
[bkw_processed](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_processed.md)
with unlabelled variables. The data contains no variable labels or value
labels, mimicking a typical dataset that user might have read in from a
.csv or .xlsx file.

## Usage

``` r
bkw_unlabelled
```

## Format

### `bkw_unlabelled`

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
