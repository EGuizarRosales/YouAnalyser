# Package index

## Data Processing

Function to process survey data, including adding and inspecting
variable and value labels.

- [`dp_convert_to_labelled()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_convert_to_labelled.md)
  : Convert a data frame to a labelled data frame using a codebook
- [`dp_copy_codebook_template()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_copy_codebook_template.md)
  : Copy a codebook template to a specified file path
- [`dp_inspect_codebook()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_inspect_codebook.md)
  : Inspect the codebook of a labelled data frame
- [`dp_label_automatically()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_label_automatically.md)
  : Automatically label a data frame
- [`dp_recode_missing()`](https://eguizarrosales.github.io/YouAnalyser/reference/dp_recode_missing.md)
  : Recode user-defined missing values to NA

## Exploratory Data Analysis (EDA)

Functions to perform exploratory data analysis (EDA) on survey data,
including summary statistics, correlations, descriptive statistics,
tests and plots of several variables by group (e.g. clusters), and an
interactive Shiny gadget
([`eda_explore()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_explore.md)).

- [`eda_correlation()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_correlation.md)
  : Exploratory data analysis: correlation
- [`eda_describe()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_describe.md)
  : Exploratory data analysis: descriptive statistics of several
  variables
- [`eda_explore()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_explore.md)
  : Explore data interactively
- [`eda_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot.md)
  : Exploratory data analysis: plot several variables in one plot
- [`eda_plot_detail()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot_detail.md)
  : Exploratory data analysis: detailed plot of one variable by group
- [`eda_summary()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_summary.md)
  : Exploratory data analysis: Summary of data
- [`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md)
  : Exploratory data analysis: test group differences of several
  variables

## Key Driver Analysis (KDA)

Functions to perform KDA on survey data.
[`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
is the main end-to-end function that runs the entire KDA process, while
the other functions are helper functions that can be used to run
specific steps of the KDA process.

- [`kda_copy_pptx_template()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_copy_pptx_template.md)
  : Copy PowerPoint template to specified file path
- [`kda_data_is_haven_labelled()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_data_is_haven_labelled.md)
  : Check whether all variables are haven-labelled and include
  variable/value labels
- [`kda_forestPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_forestPlot.md)
  : Create a forest plot for model coefficients
- [`kda_importance_barPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_barPlot.md)
  : Create KDA importance bar plot
- [`kda_importance_domir()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_domir.md)
  : Perform KDA dominance analysis
- [`kda_importance_jrw()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_jrw.md)
  : Calculate Importance using Johnson's Relative Weights
- [`kda_importance_sumOfCoefficients()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_importance_sumOfCoefficients.md)
  : Calculate feature importance using sum of coefficients
- [`kda_interactive_workflow()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_interactive_workflow.md)
  : Conduct an interactive KDA workflow in the console
- [`kda_ipma()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_ipma.md)
  : Importance-Performance Matrix Analysis
- [`kda_ipma_scatterPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_ipma_scatterPlot.md)
  : Create an Importance-Performance Matrix Analysis scatter plot
- [`kda_performance()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_performance.md)
  : Calculate KDA performance
- [`kda_performance_barPlot()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_performance_barPlot.md)
  : Create a KDA performance bar plot
- [`kda_regression()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression.md)
  : Conduct KDA regression analysis
- [`kda_regression_with_imputation()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_regression_with_imputation.md)
  : Conduct KDA with imputation of missing values
- [`kda_save_data_for_chart()`](https://eguizarrosales.github.io/YouAnalyser/reference/kda_save_data_for_chart.md)
  : Save KDA data for chart in Excel template

## Price Sensitivity Meter (PSM)

Functions to perform Van Westendorp Price Sensitivity Meter Analysis,
including the Newton Miller Smith Extension (NMS-Extension).

- [`psm_copy_pptx_template()`](https://eguizarrosales.github.io/YouAnalyser/reference/psm_copy_pptx_template.md)
  : Copy PowerPoint template to specified file path
- [`psm_design_for_weighted()`](https://eguizarrosales.github.io/YouAnalyser/reference/psm_design_for_weighted.md)
  : Build a survey design object for weighted PSM analysis
- [`psm_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/psm_plot.md)
  : Plot Price Sensitivity Meter (van Westendorp) results
- [`psm_save_data_for_chart()`](https://eguizarrosales.github.io/YouAnalyser/reference/psm_save_data_for_chart.md)
  : Save PSM data for chart in Excel template

## Segmentation (SEG)

Functions to perform segmentation (cluster analysis) on survey data:
preparation of the data and distance matrices, assessment of the
clustering tendency, number of clusters and choice of the algorithm,
cluster analysis with different algorithms, returning standardized
solutions with visualizations, and validation of the cluster solutions
with internal measures (silhouette width, Dunn index) and external
measures (agreement with a reference grouping).

- [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
  : Prepare survey data for cluster analysis
- [`seg_distance()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_distance.md)
  : Compute a distance matrix for cluster analysis
- [`seg_clustering_tendency()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_clustering_tendency.md)
  : Assess the clustering tendency of the data
- [`seg_optimal_clusters()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_optimal_clusters.md)
  : Determine the optimal number of clusters
- [`seg_nbclust_gap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_gap.md)
  : Optimal number of clusters: Gap statistic
- [`seg_nbclust_indices()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_indices.md)
  : Optimal number of clusters: NbClust indices
- [`seg_nbclust_silhouette()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_silhouette.md)
  : Optimal number of clusters: Average silhouette method
- [`seg_nbclust_wss()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_wss.md)
  : Optimal number of clusters: Elbow method (WSS)
- [`seg_compare_algorithms()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_compare_algorithms.md)
  : Compare clustering algorithms
- [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md)
  : Cluster analysis (segmentation)
- [`seg_cluster_density()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_density.md)
  : Density-based clustering: DBSCAN and HDBSCAN
- [`seg_cluster_fuzzy()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_fuzzy.md)
  : Fuzzy clustering
- [`seg_cluster_hierarchical()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hierarchical.md)
  : Hierarchical clustering: AGNES and DIANA
- [`seg_cluster_hkmeans()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hkmeans.md)
  : Hierarchical k-means clustering
- [`seg_cluster_model()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_model.md)
  : Model-based clustering
- [`seg_cluster_partitioning()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_partitioning.md)
  : Partitioning clustering: k-means and PAM
- [`seg_dbscan_eps()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_dbscan_eps.md)
  : Choose eps for DBSCAN: k-nearest-neighbor distance plot
- [`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md)
  : Convert an existing segmentation to a cluster solution
- [`seg_plot_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_cluster.md)
  : Plot a cluster solution in the space of the principal components
- [`seg_plot_dend()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_dend.md)
  : Plot the dendrogram of a hierarchical cluster solution
- [`seg_plot_heatmap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_heatmap.md)
  : Heatmap of a cluster solution
- [`seg_plot_centers()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_centers.md)
  : Plot the cluster centers of a solution
- [`seg_validation()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_validation.md)
  : Validate cluster solutions
- [`seg_plot_silhouette()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_silhouette.md)
  : Silhouette plot of a cluster solution
- [`seg_agreement()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_agreement.md)
  : Agreement between cluster solutions
- [`predict(`*`<seg_cluster>`*`)`](https://eguizarrosales.github.io/YouAnalyser/reference/predict.seg_cluster.md)
  [`predict(`*`<seg_cluster_set>`*`)`](https://eguizarrosales.github.io/YouAnalyser/reference/predict.seg_cluster.md)
  : Assign new respondents to the clusters of a solution

## YouAnalyser (YA) Utility Functions

Miscellaneous utility functions for the YouAnalyser package.

- [`ya_choose_file()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_choose_file.md)
  : Choose a file and return its path
- [`ya_choose_file_path()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_choose_file_path.md)
  : Choose an existing directory and define a new file in this
  directory, returning the full file path
- [`ya_save_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_save_plot.md)
  : Save a plot to JPEG
- [`ya_setup_folder_structure()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_setup_folder_structure.md)
  : Set up a standardized folder structure for a project

## Example Data

Example datasets included in the YouAnalyser package.

- [`bkw_bin`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_bin.md)
  : Synthetic BKW Employer Brand Positioning Study Data (Binary)
- [`bkw_bin_outcome`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_bin_outcome.md)
  : BKW Employer Brand Positioning Study Data (Binary Outcome)
- [`bkw_bin_predictors`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_bin_predictors.md)
  : BKW Employer Brand Positioning Study Data (Binary Predictors)
- [`bkw_labels`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_labels.md)
  : BKW Employer Brand Positioning Study Data (Variable and Value
  Labels)
- [`bkw_missings`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_missings.md)
  : Synthetic BKW Employer Brand Positioning Study Data (With Missing
  Values)
- [`bkw_processed`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_processed.md)
  : Synthetic BKW Employer Brand Positioning Study Data (Processed)
- [`bkw_synthetic`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_synthetic.md)
  : Synthetic BKW Employer Brand Positioning Study Data (Synthetic)
- [`bkw_unlabelled`](https://eguizarrosales.github.io/YouAnalyser/reference/bkw_unlabelled.md)
  : BKW Employer Brand Positioning Study Data (Unlabelled Data)
- [`deka_sample`](https://eguizarrosales.github.io/YouAnalyser/reference/deka_sample.md)
  : Anonymized Random Subsample of a DEKA Study
- [`chm_synthetic`](https://eguizarrosales.github.io/YouAnalyser/reference/chm_synthetic.md)
  : Synthetic CH Media Oneplus Streaming Study Data (Synthetic)
- [`sm_synthetic`](https://eguizarrosales.github.io/YouAnalyser/reference/sm_synthetic.md)
  : Synthetic Swissmilk Milch & Umwelt Study Data (Synthetic)
- [`sim_segments`](https://eguizarrosales.github.io/YouAnalyser/reference/sim_segments.md)
  : Simulated Survey Data with a Clear Segment Structure

## Other Functions

Other functions or data that do not fit into the above categories.

- [`yougov_colors`](https://eguizarrosales.github.io/YouAnalyser/reference/yougov_colors.md)
  : YouGov Colors
- [`yougov_palette`](https://eguizarrosales.github.io/YouAnalyser/reference/yougov_palette.md)
  : YouGov Palette
