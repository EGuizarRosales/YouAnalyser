library(YouAnalyser)
library(haven)
library(dplyr)

# Segmentation (cluster analysis) template, following
# vignette("seg", package = "YouAnalyser"), which explains all steps and
# measures in detail. Run the script section by section.

#### PLEASE EDIT ###############################################################

# 1. Choose your raw data file in .sav format
my_path_to_data <- ya_choose_file()

# 2. Define the variables in your data

# Clustering variables (e.g. an attitude battery), e.g.,
# myClusterVars <- paste0("F50_0_", 1:20)
myClusterVars <- NULL

# Respondent identifier (needed to merge the segments back into the data), e.g.,
# myId <- "id"
myId <- NULL

# Codes of "don't know" / "no answer" in the clustering variables, e.g.,
# myMissingCodes <- c(98, 99)
myMissingCodes <- NULL

# Profiling variables to describe the segments (not used for clustering), e.g.,
# myProfilingVars <- c("gender", "age_group", "region")
myProfilingVars <- NULL

# Survey weight for the description of the segments (NULL = unweighted), e.g.,
# myWeight <- "weight"
myWeight <- NULL

# 3. Number of clusters: candidates and final choice (set after step 3)
myCandidateK <- 2:6
myK <- 4

# 4. Names of the segments (set after step 6), in the order of the clusters, e.g.,
# mySegmentNames <- c("Pragmatists", "Sustainable gourmets", "Price-conscious")
mySegmentNames <- NULL

#### 0. LOAD DATA ##############################################################

myData <- haven::read_sav(my_path_to_data, user_na = TRUE)

# Check the clustering variables: scales, labels, unexpected values
dp_inspect_codebook(myData[myClusterVars])

# Recode "don't know" / "no answer" codes of the clustering variables to NA
if (!is.null(myMissingCodes)) {
  myData[myClusterVars] <- dp_recode_missing(
    myData[myClusterVars],
    missing_values = myMissingCodes
  )
}

#### 1. DATA PREPARATION #######################################################

# Recommended for survey data: remove respondents with more than 20% missing
# values and impute the remaining ones with mice (reproducible with `seed`).
# With less than 5% missing values, missing = "mean" is fine as well.
prep <- seg_prep_data(
  myData,
  vars = all_of(myClusterVars),
  id = myId,
  missing = "mice",
  max_missing_prop = 0.2
)

#### 2. CLUSTERING TENDENCY ####################################################

# Does the data contain clusters at all? Hopkins statistic > 0.75 and red
# squares along the diagonal of the VAT plot. Without clear squares, the
# segments are types along a continuum rather than distinct groups.
tendency <- seg_clustering_tendency(prep)
tendency$plot

#### 3. NUMBER OF CLUSTERS #####################################################

# Elbow, silhouette, gap statistic and NbClust majority vote (about a minute;
# for a quick look use methods = c("wss", "silhouette"))
optimal <- seg_optimal_clusters(prep)
optimal$plot

# Hierarchical k-means (recommended) for all candidate numbers of clusters
cl_set <- seg_cluster(prep, method = "hkmeans", k = myCandidateK)
cl_set$summary # cluster sizes per solution
cl_set$plot # cluster plots of all solutions

# Compare the candidates: silhouette (higher = better), Dunn index, share of
# misclassified respondents, size of the smallest cluster (>= 5%)
val_set <- seg_validation(cl_set, silhouette_plots = FALSE)
val_set$plot

# -> Choose k by the measures, interpretability, usefulness and segment sizes,
#    and set myK above

#### 4. FINAL SOLUTION #########################################################

cl <- cl_set$solutions[[paste0("k", myK)]]

cl$sizes # size and share of each cluster
cl$plots$cluster # respondents in the space of the first two principal components
cl$plots$heatmap # answers of a sample of respondents, grouped by cluster

#### 5. VALIDATION #############################################################

# Quality of the solution: silhouette plot and measures
val <- seg_validation(cl)
val$plot_silhouette

# Robustness: do other algorithms with the same k find the same segments?
# (agreement > 80% is good for survey data)
agr <- seg_agreement(list(
  `Hierarchical k-means` = cl,
  PAM = seg_cluster(prep, "pam", k = myK, plots = FALSE, verbose = FALSE),
  Ward = seg_cluster(prep, "agnes", k = myK, plots = FALSE, verbose = FALSE)
))
agr$plot

#### 6. INTERPRETATION #########################################################

# Profiles on the clustering variables (z-values: 0.2 / 0.5 / 0.8 = small /
# medium / large deviation from the total)
cl$plots$centers
seg_plot_centers(cl, type = "bars", order = "difference") # to name the segments
seg_plot_centers(cl, type = "heatmap", scale = "original") # original scale

# Interactive exploration: tests, weights, profiling variables, code
eda_explore(cl)

# Clustering variables by segment, with significant differences to the total
eda_plot(
  cl,
  vars = myClusterVars,
  group = paste0("cluster_k", myK),
  weight = myWeight,
  show_sig = TRUE,
  label_width = 45
)

# Profiling variables by segment, with tests
if (!is.null(myProfilingVars)) {
  eda_describe(
    cl,
    vars = myProfilingVars,
    group = paste0("cluster_k", myK),
    weight = myWeight,
    total = TRUE,
    test = TRUE
  )
}

# -> Name the segments and set mySegmentNames above

#### 7. EXPORT #################################################################

# Segment variable, labelled with the segment names (NA = not segmented,
# e.g. too many missing values)
segments <- cl$assignment |>
  select(all_of(myId), segment = cluster)
if (!is.null(mySegmentNames)) {
  segments$segment <- segments$segment |>
    sjlabelled::set_labels(
      labels = setNames(seq_along(mySegmentNames), mySegmentNames)
    ) |>
    sjlabelled::as_labelled()
}
segments$segment <- sjlabelled::set_label(segments$segment, "Segment")

myDataSegmented <- myData |>
  left_join(segments, by = myId)

# Data with the segment variable
haven::write_sav(
  myDataSegmented,
  ya_choose_file_path("data_segmented.sav")
)

# Cluster profiles plot
ya_save_plot(
  plot = seg_plot_centers(cl, type = "bars", order = "difference"),
  file_path = ya_choose_file_path("segment_profiles.jpeg"),
  width = 30,
  height = 20
)

# The solution itself, to assign new respondents later (see below)
saveRDS(cl, ya_choose_file_path("segmentation.rds"))

#### 8. ASSIGN NEW RESPONDENTS (e.g. a new wave) ###############################

# New data must contain the same clustering variables (with the same missing
# codes recoded to NA). It is prepared like the original data and assigned to
# the existing segments.
# cl <- readRDS(ya_choose_file())
# myNewData <- haven::read_sav(ya_choose_file(), user_na = TRUE)
# myNewData[myClusterVars] <- dp_recode_missing(
#   myNewData[myClusterVars],
#   missing_values = myMissingCodes
# )
# predict(cl, myNewData)
