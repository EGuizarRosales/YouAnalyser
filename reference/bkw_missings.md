# Synthetic BKW Employer Brand Positioning Study Data (With Missing Values)

Data synthetically created based on
[bkw_synthetic](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_synthetic.md).
5% NA values were introduced in all variables to mimic missing values.

## Usage

``` r
bkw_missings
```

## Format

### `bkw_missings`

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
