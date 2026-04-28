# Synthetic BKW Employer Brand Positioning Study Data (Synthetic)

Synthetic data generated from the BKW Employer Brand Positioning Study
conducted in 2026 (14713 BKW Zielgruppenumfrage
Arbeitgeberpositionierung 2026). Key Driver Analyses (linear regression
with dominance analysis) were performed. The data includes the dependent
variable (F600) and 14 independent variables (F800_1 to F800_14) used in
the regression model. Additional grouping variables (country and
cluster) are included to allow for subgroup analyses.

## Usage

``` r
bkw_synthetic
```

## Format

### `bkw_synthetic`

A data frame with 1,216 rows and 18 columns:

- id:

  unique identifier for each respondent, starting from 1

- country:

  country of the respondent

- cluster:

  segmentation-based cluster the respondent belongs to

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
