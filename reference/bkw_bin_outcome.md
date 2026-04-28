# BKW Employer Brand Positioning Study Data (Binary Outcome)

Data based on
[bkw_processed](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_processed.md)
with a binary dependent variable. The dependent variable (F600) was
dichotomized into a binary variable (0: "Nicht attraktiv", 1:
"Attraktiv") based on a cutoff of 4.

## Usage

``` r
bkw_bin_outcome
```

## Format

### `bkw_bin_outcome`

A data frame with 1,171 rows and 15 columns:

- F600:

  Dependent variable: Wie attraktiv finden Sie die BKW als
  Arbeitgeberin? (0: Nicht attraktiv, 1: Attraktiv)

- F800_1, ..., F800_14:

  Independent variables. Main question: Wie gut passt die BKW Ihrer
  Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem
  Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut);
  F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ...
  , F800_14: "Diversität, Gleichstellung und Inklusion")
