# Synthetic CH Media Oneplus Streaming Study Data (Synthetic)

Synthetic data generated from the CH Media Oneplus Streaming Study
conducted in 2025 (14131 Ch Media Oneplus Streaming Markenstudie 2025).
A Van Westendorp Price Sensitivity Meter with Newton Miller Smith
Extension was performed. The data includes the four basic questions
(PSM, `tooCheap`, `cheap`, `tooExpensive`, `expensive`) and the two
extension questions (NMS, `purchaseIntentionCheap` and
`purchaseIntentionExpensive`)

## Usage

``` r
chm_synthetic
```

## Format

### `chm_synthetic`

A data frame with 815 rows and 7 columns:

- id:

  unique identifier for each respondent, starting from 1

- weight:

  (random) weight for each participant

- tooCheap:

  e.g., "At what price would you consider Product X to be priced so low
  that you would feel the quality couldn't be very good?"

- cheap:

  e.g., "At what price would you consider Product X to be a bargain - a
  great buy for the money?"

- expensive:

  e.g., "At what price would you consider Product X starting to get
  expensive, so that it is not out of the question, but you wold have to
  give some thougth to buying it?"

- tooExpensive:

  e.g., "At what price would you consider Product X to be so expensive
  that you would not consider buying it?"

- purchaseIntentionCheap:

  e.g., "How likely are you to purchase Product X at \[pipe answer from
  cheap\]? (1: extremely unelikely, 2: somewhat unelikely, 3: neither
  likely nor unlikely, 4: somewhat likely, 5: extremely likely)"

- purchaseIntentionExpensive:

  e.g., "How likely are you to purchase Product X at \[pipe answer from
  expensive\]? (1: extremely unelikely, 2: somewhat unelikely, 3:
  neither likely nor unlikely, 4: somewhat likely, 5: extremely likely)"
