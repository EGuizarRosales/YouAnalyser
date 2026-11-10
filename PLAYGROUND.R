# Playground for the segmentation (seg_) functions in R/seg_prep.R
# (preparation, clustering tendency, number of clusters, algorithms) and
# R/seg_cluster.R (clustering).
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
cl_benchmark <- seg_as_cluster(prep_mice, "cluster_benchmark", name = "Benchmark 2024")
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
