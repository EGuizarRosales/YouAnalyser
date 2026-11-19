# Playground for the segmentation (seg_) functions in R/seg_prep.R
# (preparation, clustering tendency, number of clusters, algorithms),
# R/seg_cluster.R (clustering) and R/seg_post.R (validation).
# Run section by section after devtools::load_all().

devtools::load_all()

library(haven)
library(tidyverse)
library(easystats)

d_seg <- sm_synthetic |>
  select(starts_with("F50_"))

# ---- 0. Example data ---------------------------------------------------------

# Clustering variables: the 20 F50_0 attitude items (1-10, "don't know" = NA)
d_seg |>
  sjlabelled::get_label() |>
  enframe(name = "variable", value = "label")

# Missing values per respondent
d_seg |>
  mutate(n_missing = rowSums(is.na(pick(everything())))) |>
  count(n_missing)

# Benchmark segments from the 2024 report
datawizard::data_tabulate(sm_synthetic$cluster_benchmark)


# ---- 1. seg_prep_data() ------------------------------------------------------

# Default: listwise deletion, z-standardization, euclidean distance
prep <- seg_prep_data(
  sm_synthetic,
  vars = starts_with("F50_0_"),
  id = "id"
)

prep$data # prepared clustering variables (labels kept)
prep$data_full # original data of retained respondents (for profiling)
prep$dist # distance matrix
prep$info

# Recommended for survey data: drop respondents with > 20% missing,
# impute the rest with mice (predictive mean matching)
prep_mice <- seg_prep_data(
  sm_synthetic,
  vars = starts_with("F50_0_"),
  id = "id",
  missing = "mice",
  max_missing_prop = 0.2
)

# Mean imputation, min-max scaling, correlation-based distance
prep_mean <- seg_prep_data(
  sm_synthetic,
  vars = starts_with("F50_0_"),
  missing = "mean",
  scale = "range",
  distance = "pearson"
)

# Gower distance via cluster::daisy(), keeping missing values
# (warns: some respondents share no answered item -> NA distances)
prep_gower <- seg_prep_data(
  sm_synthetic,
  vars = starts_with("F50_0_"),
  missing = "none",
  distance = "gower"
)

# Skip the distance matrix (e.g. for k-means on large samples)
prep_nodist <- seg_prep_data(
  sm_synthetic,
  vars = starts_with("F50_0_"),
  missing = "mice",
  max_missing_prop = 0.2,
  compute_distance = FALSE
)


# ---- 2. seg_distance() -------------------------------------------------------

# Distance matrix on already prepared data
d_manhattan <- seg_distance(prep_mice$data, distance = "manhattan")
d_gower <- seg_distance(prep_mice$data, distance = "gower")

# Visualize the distance matrix for a subset of respondents
seg_distance(prep_mice$data[1:50, ], labels = prep_mice$data_full$id[1:50]) |>
  factoextra::fviz_dist(
    gradient = list(
      low = yougov_colors[["Red 1"]],
      mid = "white",
      high = yougov_colors[["Blue 1"]]
    )
  )


# ---- 3. seg_clustering_tendency() --------------------------------------------

tendency <- seg_clustering_tendency(prep_mice)

tendency$hopkins # Hopkins statistic: actual vs. random data
tendency$plot # VAT plots side by side
tendency$plot_actual

# All respondents in the VAT plots (slower) and another distance measure
tendency_all <- seg_clustering_tendency(
  prep_mice,
  distance = "manhattan",
  vat_n = NULL
)

# Sanity check with clearly clustered data
tendency_iris <- seg_prep_data(iris, vars = -Species, verbose = FALSE) |>
  seg_clustering_tendency()

tendency_iris$plot

# ---- 4. yougov_palette -------------------------------------------------------

yougov_palette

# e.g. instead of palette = "jco" in factoextra, or with ggplot2
sm_synthetic |>
  mutate(cluster_benchmark = as_factor(cluster_benchmark)) |>
  ggplot(aes(x = cluster_benchmark, fill = cluster_benchmark)) +
  geom_bar() +
  scale_fill_manual(values = yougov_palette) +
  theme_classic() +
  theme(legend.position = "none")


# ---- 5. seg_optimal_clusters() -----------------------------------------------

# Quick exploration: elbow and silhouette only (a few seconds)
optimal_quick <- seg_optimal_clusters(
  prep_mice,
  methods = c("wss", "silhouette")
)

# All methods incl. gap statistic and 26 NbClust indices (~1 minute)
optimal <- seg_optimal_clusters(prep_mice)

optimal$summary # suggested k per method
optimal$plot # all plots combined
optimal$plots$gap_stat # individual plot
optimal$results$nbclust$values # number of NbClust indices per k

# Hierarchical clustering (Ward) instead of k-means
optimal_hc <- seg_optimal_clusters(
  prep_mice,
  methods = c("wss", "silhouette", "nbclust"),
  cluster_method = "hclust"
)

# PAM (NbClust is skipped, as it does not support PAM)
optimal_pam <- seg_optimal_clusters(
  prep_mice,
  methods = c("wss", "silhouette"),
  cluster_method = "pam"
)

# Individual methods
seg_nbclust_wss(prep_mice)$plot
seg_nbclust_silhouette(prep_mice, k_max = 8)$plot
seg_nbclust_gap(prep_mice, nboot = 20)$plot # fewer bootstraps -> faster
seg_nbclust_indices(prep_mice, index = c("silhouette"))$plot # single index


# ---- 6. seg_compare_algorithms() ---------------------------------------------

# Internal validation (connectivity, Dunn, silhouette): ~10 seconds
algorithms <- seg_compare_algorithms(prep_mice)

algorithms$optimal # best algorithm and k per measure
algorithms$plot # all measures incl. size of the smallest cluster
algorithms$plots$Silhouette # individual plot
algorithms$measures # all values (long format)
algorithms$cluster_sizes # cluster sizes of every solution

# Average linkage (clValid's default) -> one large cluster and small ones
algorithms_avg <- seg_compare_algorithms(prep_mice, linkage = "average")

# Incl. stability measures (APN, AD, ADM, FOM): ~1.5 minutes
algorithms_stab <- seg_compare_algorithms(
  prep_mice,
  k = 2:5,
  validation = c("internal", "stability")
)
algorithms_stab$plot

# Other algorithms
seg_compare_algorithms(
  prep_mice,
  cl_methods = c("kmeans", "diana", "clara"),
  k = 2:4
)


# ---- 7. seg_cluster() --------------------------------------------------------

# Default: hierarchical k-means with 4 clusters
cl_hk <- seg_cluster(prep_mice, k = 4)

cl_hk$sizes # cluster sizes (renumbered by size)
cl_hk$centers # cluster means of the clustering variables
cl_hk$assignment # id + cluster per respondent
cl_hk$plots$cluster # PCA plot (euclid ellipses + star plot)
cl_hk$plots$dend # dendrogram of the hierarchical step
cl_hk$plots$heatmap # heatmap of 200 sampled respondents

# Several numbers of clusters
cl_pam <- seg_cluster(prep_mice, method = "pam", k = 2:6)
cl_pam$summary
cl_pam$plot # cluster plots of all solutions
cl_pam$solutions$k4$plots$cluster

# Other methods (via the wrapper or the family functions)
cl_km <- seg_cluster(prep_mice, method = "kmeans", k = 4)
cl_agnes <- seg_cluster(prep_mice, method = "agnes", k = 4, linkage = "ward")
cl_diana <- seg_cluster_hierarchical(prep_mice, k = 4, method = "diana")
cl_fuzzy <- seg_cluster(prep_mice, method = "fuzzy", k = 4, memb_exp = 1.1)
head(cl_fuzzy$membership) # membership degrees
cl_mclust <- seg_cluster(prep_mice, method = "mclust", k = 4) # needs mclust
cl_mclust$plots$bic

# Density-based clustering (needs dbscan): on survey data mostly one cluster
seg_dbscan_eps(prep_mice)$plot
cl_db <- seg_cluster(prep_mice, method = "dbscan")
cl_hdb <- seg_cluster(prep_mice, method = "hdbscan", min_pts = 30)

# Pass arguments to fviz_cluster() and fviz_dend()
seg_cluster(
  prep_mice,
  method = "agnes",
  k = 4,
  cluster_plot_args = list(ellipse.type = "norm"),
  dend_args = list(type = "phylogenic")
)

# Re-plot a solution without re-running the clustering
seg_plot_cluster(cl_hk, star.plot = FALSE, ellipse.type = "convex")
seg_plot_dend(cl_agnes, type = "circular")

# Heatmap with dendrograms (random sample, grouped by cluster)
seg_plot_heatmap(cl_hk, n = 300)
# Classical order by hierarchical clustering: do the clusters match it?
seg_plot_heatmap(cl_hk, row_order = "dendrogram")
# All respondents
seg_plot_heatmap(cl_hk, n = NULL)

# Existing segmentation (benchmark 2024) in the same format
cl_benchmark <- seg_as_cluster(
  prep_mice,
  "cluster_benchmark",
  name = "Benchmark 2024"
)
cl_benchmark$plots$heatmap

# Agreement of a new solution with the benchmark
table(new = cl_hk$cluster, benchmark = cl_benchmark$cluster)


# ---- 8. Sanity check: data with a clear cluster structure --------------------

# The attitude items of sm_synthetic show no clear cluster structure (blurry
# heatmap, low silhouette). For comparison, the same steps on data with known,
# well separated clusters.

# 8a. iris: 3 species, 4 measurements
prep_iris <- seg_prep_data(iris, vars = -Species)

seg_clustering_tendency(prep_iris)$plot # VAT: clear blocks on the diagonal
seg_optimal_clusters(prep_iris, methods = c("wss", "silhouette"))

cl_iris <- seg_cluster(prep_iris, method = "hkmeans", k = 3)
cl_iris$plots$cluster
cl_iris$plots$heatmap # clear blocks within the clusters
seg_plot_heatmap(cl_iris, row_order = "dendrogram") # tree = clusters

# Agreement with the true species
table(cluster = cl_iris$cluster, species = iris$Species)

# 8b. Simulated survey (example data sim_segments, see ?sim_segments):
# 3 segments of 200 respondents with distinct profiles on 20 rating items
# (1-10), similar to the F50_0 battery
sim_segments
datawizard::data_tabulate(sim_segments$segment)

prep_sim <- seg_prep_data(sim_segments, vars = starts_with("item_"), id = "id")

seg_clustering_tendency(prep_sim)$plot
seg_optimal_clusters(prep_sim, methods = c("wss", "silhouette"))

cl_sim <- seg_cluster(prep_sim, method = "hkmeans", k = 3)
cl_sim$plots$cluster
cl_sim$plots$heatmap # three blocks: each segment high on its own items
seg_plot_heatmap(cl_sim, row_order = "dendrogram")

# Agreement with the true segments
table(cluster = cl_sim$cluster, segment = cl_sim$data_full$segment)

# Compare with our survey data: blurry blocks, weak structure
cl_hk$plots$heatmap


# ---- 9. seg_validation() -----------------------------------------------------

# 9a. Single solution: silhouette plot, silhouette coefficient, Dunn index
val_hk <- seg_validation(cl_hk)

val_hk$summary # main measures
val_hk$cluster_silhouette # average silhouette width per cluster
val_hk$plots$silhouette[[1]] # silhouette plot
val_hk$statistics # further statistics of fpc::cluster.stats()

# Respondents with a negative silhouette (probably misclassified)
val_hk$silhouette[[1]] |>
  filter(sil_width < 0) |>
  arrange(sil_width)

# Silhouette plot directly from a solution (arguments -> fviz_silhouette())
seg_plot_silhouette(cl_hk)
seg_plot_silhouette(cl_pam$solutions$k3, ggtheme = theme_minimal())

# 9b. Several numbers of clusters, benchmark segmentation as external grouping
cl_km_set <- seg_cluster(prep_mice, "kmeans", k = 2:6, plots = FALSE)
val_km <- seg_validation(cl_km_set, external = "cluster_benchmark")

val_km$plot # all measures over k
val_km$plot_silhouette # silhouette plots of all solutions
val_km$plots$measures$`Corrected Rand` # individual measure
val_km$optimal # best solution per measure
val_km$crosstabs$`k-means, k = 4` # clusters vs. benchmark segments

# 9c. Several algorithms (named list -> names in the plots), benchmark as
# seg_cluster object (from seg_as_cluster()) for the external measures
val_all <- seg_validation(
  list(
    `Hierarchical k-means` = seg_cluster(
      prep_mice,
      k = 2:6,
      plots = FALSE,
      verbose = FALSE
    ),
    `k-means` = cl_km_set,
    PAM = cl_pam,
    Benchmark = cl_benchmark
  ),
  external = cl_benchmark,
  silhouette_plots = FALSE # faster
)
val_all$plot
val_all$summary |> arrange(desc(silhouette))

# External grouping as a vector, e.g. a sociodemographic variable
seg_validation(
  cl_hk,
  external = prep_mice$data_full$cluster_benchmark,
  external_name = "Benchmark"
)

# 9d. Sanity check: data with known clusters (see section 8)
# iris k-means (cf. datanovia): silhouette 0.46, Dunn 0.027, corrected Rand 0.62, VI 0.75
val_iris <- seg_validation(
  seg_cluster(prep_iris, "kmeans", k = 2:5, plots = FALSE, verbose = FALSE),
  external = "Species"
)
val_iris$plot
val_iris$plot_silhouette

# Simulated segments: clear structure, near-perfect recovery at k = 3
val_sim <- seg_validation(
  seg_cluster(prep_sim, k = 2:5, plots = FALSE, verbose = FALSE),
  external = "segment"
)
val_sim$plot
val_sim$crosstabs$`Hierarchical k-means, k = 3`

# Density-based clustering: noise (cluster 0) is excluded from the internal
# measures and treated as a group of its own for the external measures
seg_cluster(
  prep_iris,
  method = "dbscan",
  eps = 0.8,
  min_pts = 8,
  plots = FALSE,
  verbose = FALSE
) |>
  seg_validation(external = "Species")

# ---- 10. Descriptive statistics and plots by cluster (eda_) ------------------
# (R/eda_interactive.R; eda_explore() needs shiny, bslib and DT, the detailed
# test plots in its "Tests" tab ggstatsplot)

items <- paste0("F50_0_", 1:6)

# 10a. Descriptive statistics: means of numeric items, distributions of
# categorical variables (auto: numeric if >= 5 value labels or values)
eda_describe(sm_synthetic, vars = starts_with("F50_0_"))
eda_describe(
  sm_synthetic,
  vars = c(items, "gender", "education"),
  group = "cluster_benchmark",
  weight = "weight",
  total = TRUE,
  test = TRUE
)

# 10b. Tests of group differences: omnibus ANOVA / Kruskal-Wallis /
# chi-square; contrasts with modelbased::estimate_contrasts() (robust SE,
# Holm-adjusted): vs. total incl. the group (default), rest of the sample,
# mean of the group means, or all pairs of groups (see ?eda_test)
eda_test(
  sm_synthetic,
  vars = items,
  group = "cluster_benchmark",
  weight = "weight"
)
eda_test(
  sm_synthetic,
  vars = items,
  group = "cluster_benchmark",
  reference = "rest"
) # same p as "total"
eda_test(
  sm_synthetic,
  vars = items,
  group = "cluster_benchmark",
  reference = "meandev"
)
eda_test(
  sm_synthetic,
  vars = items,
  group = "cluster_benchmark",
  reference = "groups"
)
eda_test(
  sm_synthetic,
  vars = items,
  group = "cluster_benchmark",
  method = "nonparametric"
)

# 10c. Plots of several variables in one plot
eda_plot(sm_synthetic, vars = items)
eda_plot(
  sm_synthetic,
  vars = items,
  group = "cluster_benchmark",
  weight = "weight",
  show_sig = TRUE, # default: higher / lower than the total
  total = TRUE
)
# Letters for the differences between the groups, nonparametric tests
eda_plot(
  sm_synthetic,
  vars = items,
  group = "cluster_benchmark",
  show_sig = TRUE,
  reference = "groups",
  test_method = "nonparametric"
)
eda_plot(
  sm_synthetic,
  vars = items,
  group = "cluster_benchmark",
  orientation = "vertical",
  error = "se"
)
eda_plot(
  sm_synthetic,
  vars = items,
  group = "cluster_benchmark",
  type = "box",
  show_sig = TRUE
)
eda_plot(
  sm_synthetic,
  vars = c("F50_0_1", "age"),
  group = "cluster_benchmark",
  facet = TRUE
)
eda_plot(
  sm_synthetic,
  vars = c("gender", "education"),
  group = "cluster_benchmark"
)
eda_plot(sm_synthetic, vars = items[1:3], type = "stacked") # 1-10 scale as distribution

# 10d. Cluster solutions as grouping variables: a seg_cluster(_set) supplies
# its original data (data_full) plus one variable per solution (cluster_k2, ...)
eda_plot(cl_hk, vars = items, group = "cluster_k4", show_sig = TRUE)
eda_describe(
  cl_km_set,
  vars = c(items, "gender"),
  group = "cluster_k3",
  test = TRUE
)

# 10e. Detailed plot of one variable with ggstatsplot tests
eda_plot_detail(sm_synthetic, var = "F50_0_1", group = "cluster_benchmark")
eda_plot_detail(
  sm_synthetic,
  var = "F50_0_1",
  group = "cluster_benchmark",
  type = "robust",
  violin = FALSE,
  points = FALSE,
  pairwise_display = "all"
)
eda_plot_detail(cl_hk, var = "gender", group = "cluster_k4")

# 10f. Interactive gadget (viewer pane; "Done" returns plot, statistics, code)
res <- eda_explore(cl_km_set)
res$plot
res$describe
cat(res$code)
eda_explore(viewer = "browser") # all data frames / seg_cluster outputs in the session
