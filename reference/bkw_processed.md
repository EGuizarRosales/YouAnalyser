# Synthetic BKW Employer Brand Positioning Study Data (Processed)

Processed data created based on
[bkw_missings](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_missings.md).
Only the dependent variable (F600) and 14 independent variables (F800_1
to F800_14) used in the regression model are included. All NA values in
these variables were removed to ensure the data is ready for analysis.

## Usage

``` r
bkw_processed
```

## Format

### `bkw_processed`

A data frame with 1,104 rows and 15 columns:

- F600:

  Dependent variable: Wie attraktiv finden Sie die BKW als
  Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)

- F800_1, ..., F800_14:

  Independent variables used in the regression model. Main question: Wie
  gut passt die BKW Ihrer Meinung nach zu den folgenden Aspekten, die
  Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7:
  Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des
  Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und
  Inklusion")
