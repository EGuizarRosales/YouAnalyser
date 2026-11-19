# Synthetic Swissmilk Milch & Umwelt Study Data (Synthetic)

Synthetic data generated from the 2024 wave of the Swissmilk study
"Milch & Umwelt" (137241 Schweizer Milchproduzenten SMP, Milch & Umwelt
2024). The study includes a segmentation of respondents into four
nutrition types based on 20 attitude items towards nutrition (`F50_0_1`
to `F50_0_20`). The data includes the original segment membership
(`cluster_benchmark`), the segmentation variables, profiling variables
and sociodemographics. All "weiss nicht / keine Angabe" answers (code
99) were recoded to `NA`.

## Usage

``` r
sm_synthetic
```

## Format

### `sm_synthetic`

A data frame with 1,401 rows and 75 columns:

- id:

  unique identifier for each respondent, starting from 1

- weight:

  survey weight

- cluster_benchmark:

  segment membership from the original 2024 analysis (1: Ausgewogener
  Omnivore, 2: Nachhaltig-Ökologischer Geniesser, 3: Pragmatiker, 4:
  Preisbewusster Carnivore)

- gender:

  gender (1: Männer, 2: Frauen)

- age:

  age in years

- age_group:

  age group (1: 16-34 Jahre, 2: 35-49 Jahre, 3: 50+ Jahre)

- region:

  language region (1: D-CH, 2: W-CH)

- education:

  education (1: tief, 2: mittel, 3: hoch)

- F50_0_1, ..., F50_0_20:

  Segmentation variables. Main question: Inwiefern treffen die folgenden
  Aussagen auf Sie zu? (1: Stimme überhaupt nicht zu - 10: Stimme voll
  und ganz zu); F50_0_1: "Ich bin ein richtiger Feinschmecker und achte
  auf das Geschmackserlebnis beim Essen.", ..., F50_0_20: "Ich
  interessiere mich für die nachhaltige Ernährung."

- F1_0_1, ..., F1_0_10:

  Consumption frequency of food groups. Main question: Wie oft essen Sie
  durchschnittlich die folgenden Nahrungsmittel? (1: mehrmals täglich -
  10: nie); F1_0_1: "Fleisch", ..., F1_0_10: "Fleischersatzprodukte"

- F50c_1, ..., F50c_4:

  Attitudes towards milk and dairy products (1: Stimme überhaupt nicht
  zu - 10: Stimme voll und ganz zu); F50c_1: "Milch und Milchprodukte
  sind gesund.", ..., F50c_4: "Milch und Milchprodukte verbinde ich mit
  Genuss."

- F4_1:

  Ich habe mein Einkaufsverhalten in den letzten 24 Monaten verändert,
  indem ich heute nachhaltiger einkaufe. (1: trifft überhaupt nicht zu -
  10: trifft voll und ganz zu)

- F40_0_x_1, ..., F40_0_x_99:

  Diets followed in the household (0: No, 1: Yes), for x = 1:
  vegetarian, 2: vegan, 3: flexitarian, 6: lactose intolerance, 7: other
  food intolerances/allergies, 8: weight loss diet; suffix 1: "Befolge
  ich selber", 2: "Befolgt jemand anderes aus dem Haushalt", 3: "Befolgt
  niemand aus dem Haushalt", 99: "weiss nicht/keine Angabe"

- F12_0_1, ..., F12_0_7, F12_0_9:

  Attitudes towards environment and climate (1: Stimme überhaupt nicht
  zu - 10: Stimme voll und ganz zu); F12_0_1: "Ich vertraue den Labels,
  welche auf den Lebensmitteln zu finden sind.", ..., F12_0_9: "Ich
  vertraue den Schweizer Lebensmitteln."
