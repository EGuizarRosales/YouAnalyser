#' Synthetic BKW Employer Brand Positioning Study Data (Synthetic)
#'
#' Synthetic data generated from the BKW Employer Brand Positioning Study conducted in 2026 (14713 BKW Zielgruppenumfrage Arbeitgeberpositionierung 2026).
#' Key Driver Analyses (linear regression with dominance analysis) were performed.
#' The data includes the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model.
#' Additional grouping variables (country and cluster) are included to allow for subgroup analyses.
#'
#' @format ## `bkw_synthetic`
#' A data frame with 1,216 rows and 18 columns:
#' \describe{
#'   \item{id}{unique identifier for each respondent, starting from 1}
#'   \item{country}{country of the respondent}
#'   \item{cluster}{segmentation-based cluster the respondent belongs to}
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables used in the regression model. Main question: Wie gut passt die BKW Ihrer Meinung nach zu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#' }
"bkw_synthetic"

#' Synthetic BKW Employer Brand Positioning Study Data (With Missing Values)
#'
#' Data synthetically created based on [YouAnalyser::bkw_synthetic]. 5% NA values were introduced in all variables to mimic missing values.
#'
#' @format ## `bkw_missings`
#' A data frame with 1,216 rows and 18 columns:
#' \describe{
#'   \item{id}{unique identifier for each respondent, starting from 1}
#'   \item{country}{country of the respondent}
#'   \item{cluster}{segmentation-based cluster the respondent belongs to}
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables used in the regression model. Main question: Wie gut passt die BKW Ihrer Meinung nach zu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#' }
"bkw_missings"

#' Synthetic BKW Employer Brand Positioning Study Data (Processed)
#'
#' Processed data created based on [YouAnalyser::bkw_missings].
#' Only the dependent variable (F600) and 14 independent variables (F800_1 to F800_14) used in the regression model are included. All NA values in these variables were removed to ensure the data is ready for analysis.
#'
#' @format ## `bkw_processed`
#' A data frame with 1,104 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables used in the regression model. Main question: Wie gut passt die BKW Ihrer Meinung nach zu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#' }
"bkw_processed"

#' Synthetic BKW Employer Brand Positioning Study Data (Binary)
#'
#' Binary data based on [YouAnalyser::bkw_processed].
#' The dependent variable (F600) was dichotomized into a binary variable (0: "Nicht attraktiv", 1: "Attraktiv") based on a cutoff of 4. The independent variables (F800_1 to F800_14) were also dichotomized into binary variables (0: "Nicht gut", 1: "Gut") based on a cutoff of 4.
#'
#' @format ## `bkw_bin`
#' A data frame with 1,104 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (0: Nicht attraktiv, 1: Attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (0: Nicht gut, 1: Gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_bin"

#' BKW Employer Brand Positioning Study Data (Binary Outcome)
#'
#' Data based on [YouAnalyser::bkw_processed] with a binary dependent variable.
#' The dependent variable (F600) was dichotomized into a binary variable (0: "Nicht attraktiv", 1: "Attraktiv") based on a cutoff of 4.
#'
#' @format ## `bkw_bin_outcome`
#' A data frame with 1,104 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (0: Nicht attraktiv, 1: Attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_bin_outcome"

#' BKW Employer Brand Positioning Study Data (Binary Predictors)
#'
#' Data based on [YouAnalyser::bkw_processed] with binary independent variables.
#' The independent variables (F800_1 to F800_14) were dichotomized into binary variables (0: "Nicht gut", 1: "Gut") based on a cutoff of 4.
#'
#' @format ## `bkw_bin_predictors`
#' A data frame with 1,104 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (0: Nicht gut, 1: Gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_bin_predictors"

#' BKW Employer Brand Positioning Study Data (Unlabelled Data)
#'
#' Data based on [YouAnalyser::bkw_processed] with unlabelled variables.
#' The data contains no variable labels or value labels, mimicking
#' a typical dataset that user might have read in from a .csv or .xlsx file.
#'
#' @format ## `bkw_unlabelled`
#' A data frame with 1,104 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_unlabelled"

#' BKW Employer Brand Positioning Study Data (Variable and Value Labels)
#'
#' Data based on [YouAnalyser::bkw_processed] with variable and value labels.
#' The data only contains variable labels and value labels, providing a codebook additionally needed if unlabelled data is read in, e.g. using .xlsx or .csv files..
#'
#' @format ## `bkw_labels`
#' A data frame with 1,104 rows and 15 columns:
#' \describe{
#'   \item{F600}{Dependent variable: Wie attraktiv finden Sie die BKW als Arbeitgeberin? (1: Überhaupt nicht attraktiv - 7: Sehr attraktiv)}
#'   \item{F800_1, ..., F800_14}{Independent variables. Main question: Wie gut passt die BKW Ihrer Meinung nach uzu den folgenden Aspekten, die Ihnen bei einem Arbeitgeber wichtig sind? (1: Überhaupt nicht gut - 7: Sehr gut); F800_1: "Sicherheit und langfristige Stabilität des Arbeitgebers", ... , F800_14: "Diversität, Gleichstellung und Inklusion")}
#'   ...
#' }
"bkw_labels"

#' Anonymized Random Subsample of a DEKA Study
#'
#' Randomly subsampled data from a DEKA study, containing three variables (q120, q117, q118) related to assets and income.
#' The data only serves as illustrative example for the handling of user-defined missing values.
#'
#' @format ## `deka_sample`
#' A data frame with 1,000 rows and 3 columns:
#' \describe{
#'   \item{q120}{Household assets; 15 categories and 977: "keine Angabe"}
#'   \item{q117}{Household net income; 13 cateories and 777: "keine Angabe"}
#'   \item{q118}{Individual net income; 14 categories and 777: "keine Angabe"}
#' }
"deka_sample"

#' YouGov Colors
#'
#' A named character vector containing the official YouGov colors with their corresponding hex codes.
#' Colors were sourced from the YouGov Marketing Portal
#'
#' @format ## `yougov_colors`
#' A named character vector with 24 elements. Access each element using e.g. `yougov_colors[["Red 1"]]` to get the hex code for "Red 1".
"yougov_colors"

#' YouGov Palette
#'
#' An unnamed character vector of YouGov colors (taken from [yougov_colors])
#' in a fixed order, for plots that color groups such as clusters or segments.
#' Use it wherever a palette of colors is expected, e.g. as the `palette`
#' argument of factoextra functions (instead of e.g. `"jco"`) or in
#' [ggplot2::scale_color_manual()] / [ggplot2::scale_fill_manual()].
#'
#' The vector is unnamed on purpose: named vectors are matched against the
#' group levels by ggplot2's manual scales.
#'
#' @format ## `yougov_palette`
#' An unnamed character vector with 14 hex codes, in this order: Red 1,
#' Purple 1, Blue 1, Teal 1, Yellow 1, Pink 1, Navy 1, Green 1, Lavender 1,
#' Salmon 1, Blue 2, Teal 2, Pink 2, Yellow 2 (see [yougov_colors]).
#'
#' @examples
#' yougov_palette[1:4]
"yougov_palette"

#' Synthetic CH Media Oneplus Streaming Study Data (Synthetic)
#'
#' Synthetic data generated from the CH Media Oneplus Streaming Study conducted in 2025 (14131 Ch Media Oneplus Streaming Markenstudie 2025).
#' A Van Westendorp Price Sensitivity Meter with Newton Miller Smith Extension was performed.
#' The data includes the four basic questions (PSM, `tooCheap`, `cheap`, `tooExpensive`, `expensive`) and the two extension questions (NMS, `purchaseIntentionCheap` and `purchaseIntentionExpensive`)
#'
#' @format ## `chm_synthetic`
#' A data frame with 815 rows and 7 columns:
#' \describe{
#'   \item{id}{unique identifier for each respondent, starting from 1}
#'   \item{weight}{(random) weight for each participant}
#'   \item{tooCheap}{e.g., "At what price would you consider Product X to be priced so low that you would feel the quality couldn't be very good?"}
#'   \item{cheap}{e.g., "At what price would you consider Product X to be a bargain - a great buy for the money?"}
#'   \item{expensive}{e.g., "At what price would you consider Product X starting to get expensive, so that it is not out of the question, but you wold have to give some thougth to buying it?"}
#'   \item{tooExpensive}{e.g., "At what price would you consider Product X to be so expensive that you would not consider buying it?"}
#'   \item{purchaseIntentionCheap}{e.g., "How likely are you to purchase Product X at \[pipe answer from cheap\]? (1: extremely unelikely, 2: somewhat unelikely, 3: neither likely nor unlikely, 4: somewhat likely, 5: extremely likely)"}
#'   \item{purchaseIntentionExpensive}{e.g., "How likely are you to purchase Product X at \[pipe answer from expensive\]? (1: extremely unelikely, 2: somewhat unelikely, 3: neither likely nor unlikely, 4: somewhat likely, 5: extremely likely)"}
#' }
"chm_synthetic"

#' Synthetic Swissmilk Milch & Umwelt Study Data (Synthetic)
#'
#' Synthetic data generated from the 2024 wave of the Swissmilk study "Milch & Umwelt" (137241 Schweizer Milchproduzenten SMP, Milch & Umwelt 2024).
#' The study includes a segmentation of respondents into four nutrition types based on 20 attitude items towards nutrition (`F50_0_1` to `F50_0_20`).
#' The data includes the original segment membership (`cluster_benchmark`), the segmentation variables, profiling variables and sociodemographics.
#' All "weiss nicht / keine Angabe" answers (code 99) were recoded to `NA`.
#'
#' @format ## `sm_synthetic`
#' A data frame with 1,401 rows and 75 columns:
#' \describe{
#'   \item{id}{unique identifier for each respondent, starting from 1}
#'   \item{weight}{survey weight}
#'   \item{cluster_benchmark}{segment membership from the original 2024 analysis (1: Ausgewogener Omnivore, 2: Nachhaltig-Ökologischer Geniesser, 3: Pragmatiker, 4: Preisbewusster Carnivore)}
#'   \item{gender}{gender (1: Männer, 2: Frauen)}
#'   \item{age}{age in years}
#'   \item{age_group}{age group (1: 16-34 Jahre, 2: 35-49 Jahre, 3: 50+ Jahre)}
#'   \item{region}{language region (1: D-CH, 2: W-CH)}
#'   \item{education}{education (1: tief, 2: mittel, 3: hoch)}
#'   \item{F50_0_1, ..., F50_0_20}{Segmentation variables. Main question: Inwiefern treffen die folgenden Aussagen auf Sie zu? (1: Stimme überhaupt nicht zu - 10: Stimme voll und ganz zu); F50_0_1: "Ich bin ein richtiger Feinschmecker und achte auf das Geschmackserlebnis beim Essen.", ..., F50_0_20: "Ich interessiere mich für die nachhaltige Ernährung."}
#'   \item{F1_0_1, ..., F1_0_10}{Consumption frequency of food groups. Main question: Wie oft essen Sie durchschnittlich die folgenden Nahrungsmittel? (1: mehrmals täglich - 10: nie); F1_0_1: "Fleisch", ..., F1_0_10: "Fleischersatzprodukte"}
#'   \item{F50c_1, ..., F50c_4}{Attitudes towards milk and dairy products (1: Stimme überhaupt nicht zu - 10: Stimme voll und ganz zu); F50c_1: "Milch und Milchprodukte sind gesund.", ..., F50c_4: "Milch und Milchprodukte verbinde ich mit Genuss."}
#'   \item{F4_1}{Ich habe mein Einkaufsverhalten in den letzten 24 Monaten verändert, indem ich heute nachhaltiger einkaufe. (1: trifft überhaupt nicht zu - 10: trifft voll und ganz zu)}
#'   \item{F40_0_x_1, ..., F40_0_x_99}{Diets followed in the household (0: No, 1: Yes), for x = 1: vegetarian, 2: vegan, 3: flexitarian, 6: lactose intolerance, 7: other food intolerances/allergies, 8: weight loss diet; suffix 1: "Befolge ich selber", 2: "Befolgt jemand anderes aus dem Haushalt", 3: "Befolgt niemand aus dem Haushalt", 99: "weiss nicht/keine Angabe"}
#'   \item{F12_0_1, ..., F12_0_7, F12_0_9}{Attitudes towards environment and climate (1: Stimme überhaupt nicht zu - 10: Stimme voll und ganz zu); F12_0_1: "Ich vertraue den Labels, welche auf den Lebensmitteln zu finden sind.", ..., F12_0_9: "Ich vertraue den Schweizer Lebensmitteln."}
#' }
"sm_synthetic"

#' Simulated Survey Data with a Clear Segment Structure
#'
#' Simulated survey data with three well separated segments, used to
#' illustrate the segmentation functions (`seg_`) on data with a known,
#' clear cluster structure. In contrast, the attitude items of
#' [YouAnalyser::sm_synthetic] show only a weak cluster structure, which is
#' typical for real survey data.
#'
#' The data was generated as follows (see `data-raw/sim_segments.R`): each of
#' the three segments of 200 respondents has a mean profile on the 20 rating
#' items, scoring high (8) on its "own" block of items and low to medium
#' (3 to 5) on the others. Normally distributed noise (SD = 1.5) was added,
#' and the values were rounded and restricted to the rating scale from 1 to
#' 10.
#'
#' | Segment | Items 1-7 | Items 8-14 | Items 15-20 |
#' |---|---|---|---|
#' | A | 8 | 3 | 5 |
#' | B | 3 | 8 | 4 |
#' | C | 5 | 4 | 8 |
#'
#' A cluster analysis on the 20 items should recover the three segments, which
#' can be checked against the true segment membership (`segment`).
#'
#' @format ## `sim_segments`
#' A data frame (haven-labelled) with 600 rows and 22 columns:
#' \describe{
#'   \item{id}{unique identifier for each respondent, starting from 1}
#'   \item{segment}{true segment membership (1: Segment A, 2: Segment B, 3: Segment C), 200 respondents each}
#'   \item{item_1, ..., item_20}{simulated rating items (1: Strongly disagree - 10: Strongly agree); items 1-7 are high in segment A, items 8-14 in segment B and items 15-20 in segment C}
#' }
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sim_segments,
#'   vars = dplyr::starts_with("item_"),
#'   id = "id",
#'   verbose = FALSE
#' )
#' cl <- seg_cluster(prep, k = 3, verbose = FALSE)
#' table(cluster = cl$cluster, segment = cl$data_full$segment)
#' cl$plots$heatmap
#' }
"sim_segments"
