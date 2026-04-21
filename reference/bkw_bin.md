# BKW Employer Brand Positioning Study Data (Binary)

Binary data from the BKW Employer Brand Positioning Study conducted in
2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026). Key
Driver Analyses (linear regression with dominance analysis) were
performed. The data was processed to only include the dependent variable
(F600) and 14 independent variables (F800_1 to F800_14) used in the
regression model. All NA values in the dependent variable (F600) were
removed to ensure the data is ready for analysis. The dependent variable
(F600) was dichotomized into a binary variable (0: "Nicht attraktiv", 1:
"Attraktiv") based on a cutoff of 4. The independent variables (F800_1
to F800_14) were also dichotomized into binary variables (0: "Nicht
gut", 1: "Gut") based on a cutoff of 4.

## Usage

``` r
bkw_bin
```

## Format

### `bkw_bin`

A data frame with 1,216 rows and 15 columns:

- F600:

  Dependent variable: Wie attraktiv finden Sie die BKW als
  Arbeitgeberin? (0: Nicht attraktiv, 1: Attraktiv)

- F800_1, ..., F800_14:

  Independent variables. Main question: Wie gut passt die BKW Ihrer
  Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem
  Arbeitgeber wichtig sind? (0: Nicht gut, 1: Gut); F800_1: "Sicherheit
  und langfristige Stabilität des Arbeitgebers", ... , F800_14:
  "Diversität, Gleichstellung und Inklusion")
