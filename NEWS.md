# YouAnalyser 0.9.3

* Started a Segmentation (cluster analysis) module:
  * `seg_prep_data()` prepares survey data for cluster analysis: selects the clustering variables, handles missing values (listwise deletion, mean/median imputation, single `mice` imputation, or keeping them for Gower distance), optionally removes respondents above a missing-value threshold, rescales the variables (z-standardization or min-max), and computes a distance matrix.
  * `seg_distance()` computes distance matrices with a common interface to `factoextra::get_dist()` and `cluster::daisy()` (incl. Gower distance).
  * `seg_clustering_tendency()` assesses whether the data contains meaningful clusters by comparing the actual data with a uniformly distributed random dataset, using the (corrected) Hopkins statistic and VAT plots (`factoextra::get_clust_tendency()`, `factoextra::fviz_dist()`).
  * `seg_optimal_clusters()` determines the optimal number of clusters with the elbow method (WSS), the average silhouette method, the gap statistic and the majority vote of 26 NbClust indices, and summarizes their suggestions. The individual methods are also available as `seg_nbclust_wss()`, `seg_nbclust_silhouette()`, `seg_nbclust_gap()` and `seg_nbclust_indices()`.
  * `seg_compare_algorithms()` compares clustering algorithms (hierarchical, k-means, PAM, DIANA, CLARA) and numbers of clusters with the internal and stability validation measures of the `clValid` package, reports the size of the smallest cluster of each solution, and plots all measures with ggplot2.
  * `seg_cluster()` runs a cluster analysis with hierarchical k-means (default), k-means, PAM, AGNES, DIANA, fuzzy clustering, model-based clustering, DBSCAN or HDBSCAN, for one or several numbers of clusters. All methods return a standardized solution (cluster assignment renumbered by size, membership degrees/probabilities, cluster sizes and centers, the prepared and original data) with a cluster plot in the space of the principal components, a dendrogram (hierarchical methods) and a heatmap. The method families are also available as `seg_cluster_partitioning()`, `seg_cluster_hkmeans()`, `seg_cluster_hierarchical()`, `seg_cluster_fuzzy()`, `seg_cluster_model()` and `seg_cluster_density()`.
  * `seg_dbscan_eps()` suggests `eps` for DBSCAN from the k-nearest-neighbor distances.
  * `seg_as_cluster()` converts an existing segmentation (e.g. from a previous wave) into the same format, so that it can be visualized, profiled and validated like new solutions.
  * `seg_plot_cluster()`, `seg_plot_dend()` and `seg_plot_heatmap()` (re)create the plots of a solution, passing further arguments to `factoextra::fviz_cluster()` and `factoextra::fviz_dend()`. The heatmap is built with ggplot2 for a random sample of respondents, with dendrograms of the variables and the respondents and a cluster color bar; respondents can be grouped by cluster or ordered by a hierarchical clustering.
  * `seg_validation()` validates one or several cluster solutions (several numbers of clusters and/or algorithms) with internal measures (average silhouette width, share of negative silhouette widths, Dunn index and further statistics of `fpc::cluster.stats()`) and, if a reference grouping is supplied (a vector, a column of the original data or an existing segmentation), external measures (corrected Rand index, Meila's variation of information) with cross tabulations. It returns silhouette plots (`factoextra::fviz_silhouette()`) and ggplot2 plots of all measures over the number of clusters, and reports the best solution per measure.
  * `seg_plot_silhouette()` (re)creates the silhouette plot of a solution.
* `fpc` is now imported (for `fpc::cluster.stats()`).
* `mclust` and `dbscan` are suggested for model-based and density-based clustering.
* Added `yougov_palette`, an unnamed vector of YouGov colors for plots with groups (e.g. clusters), to be used e.g. instead of the `"jco"` palette in factoextra.
* `factoextra`, `cluster`, `NbClust` and `clValid` are now imported. `ggplot2`, which was already used, is now declared in Imports.
* Added `sim_segments`, simulated survey data with three well separated segments on 20 rating items (and the true segment membership), to illustrate the segmentation functions on data with a clear cluster structure.
* Added `sm_synthetic`, a synthetic dataset (based on the 2024 Swissmilk "Milch & Umwelt" study) with the 20 nutrition attitude items used for the segmentation, the original segment membership (`cluster_benchmark`), profiling variables and sociodemographics, for use in upcoming segmentation (cluster analysis) functions.

# YouAnalyser 0.9.2

* Added a Price Sensitivity Meter (PSM) module, wrapping the `pricesensitivitymeter` package and adding YouGov-specific reporting helpers:
  * Re-exported `psm_analysis()` and `psm_analysis_weighted()` from `pricesensitivitymeter` for the (unweighted and weighted) van Westendorp analysis, including the Newton-Miller-Smith (NMS) extension.
  * `psm_design_for_weighted()` builds an unclustered `survey.design` object from a weight column, for use with `psm_analysis_weighted()`.
  * `psm_plot()` creates the classic van Westendorp price sensitivity plot (with the four cumulative distribution curves, indifference and optimal price points, and acceptable price range), plus reach and revenue optimization plots when the NMS extension was used.
  * `psm_save_data_for_chart()` and `psm_copy_pptx_template()` export PSM results into standardized Excel and PowerPoint templates, mirroring the existing KDA reporting workflow.
* Added a new vignette, `vignette("psm")`, demonstrating the PSM workflow end to end.
* Added `chm_synthetic`, a synthetic dataset (based on the 2025 CH Media Oneplus Streaming Markenstudie) with the four basic van Westendorp questions and the two NMS purchase-intention questions, for use in examples and the PSM vignette.

# YouAnalyser 0.9.1

* Initial submission.
* First version of the package, introducing:
  * Data processing (`dp_*`) functions for preparing and cleaning survey data (e.g., labelling, recoding missing values).
  * Exploratory data analysis (`eda_*`) functions for summarizing and visualizing survey data.
  * Key Driver Analysis (`kda_*`) functions, including regression-based importance metrics, handling of missing data via imputation, and standardized Excel/PowerPoint reporting templates.
